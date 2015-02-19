//
//  RightViewController.m
//  twendy
//
//  Created by Macadamian on 1/27/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//

#import "RightViewController.h"
#import "AuthenticationModel.h"
#import "Notifications.h"
#import "RegionModel.h"
#import "Trend.h"
#import "TwitterFetch.h"

@interface RightViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tblPeople; //FIX ME rename
@property (nonatomic, strong) NSMutableArray *trendDB;
@property (nonatomic) NSInteger recordIDToEdit;

@end
@implementation RightViewController

#pragma mark - View Lifecycle
- (id)init
{
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.tblPeople.delegate = self;
  self.tblPeople.dataSource = self;
  
  self.recordIDToEdit = -1;
  
  
  if ([AuthenticationModel isLoggedIn] == YES) {
    // Reload the table view.
    [self.tblPeople reloadData];
  }
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedOut:) name:LogoutSucceed object:nil];

}

-(void)userLoggedOut:(NSNotification*)obj {
  [RegionModel reset];
  self.trendDB = [[NSMutableArray alloc] init];
  [self.tblPeople reloadData];
}


#pragma mark - UITableView Delegates
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
  return self.trendDB.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCellRecord2" forIndexPath:indexPath];
  
  Trend *trendObj = self.trendDB[indexPath.row];
  cell.textLabel.text = trendObj.name;
  //cell.detailTextLabel.text = @"text";
  return cell;
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   //Use storyboards and prepareForSeque instead of this method
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

  UINavigationController *nc =
  (UINavigationController *)segue.destinationViewController;
  
  TrendViewController *trendViewController =
  (TrendViewController *)[nc topViewController];
  
  NSIndexPath *selectedIndexPath = [self.tblPeople indexPathForSelectedRow];
  self.recordIDToEdit = selectedIndexPath.row;
  
  Trend *trendObj = self.trendDB[self.recordIDToEdit];
    
  trendViewController.trendUrl = trendObj.url;
}


#pragma mark - Overridden setters

-(void)setNavigationItemTitle:(NSString *)title
{
  //strip first chracter.
  self.navigationItem.title = title;
}

-(void)setWoeid:(NSInteger)monster city:(NSString*)city
{
  [self getTrendData:monster];
  if (_popover != nil) {
    [_popover dismissPopoverAnimated:YES];
  }
  
  [self setNavigationItemTitle:city];

}

#pragma mark - New Methods

-(void)notifyUser
{
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder"
                                                  message:@"You need to login before using this app."
                                                 delegate:self cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
  [alert show];
  
}

-(void)getTrendData:(NSInteger)location {
  
  if (location == 0) { //There are some race conditions where we don't yet have home woeid at start
    return;
  }
  
  if ([AuthenticationModel isLoggedIn] == NO) {
    [self notifyUser];
    return;
  }
  
  NSString *url = [NSString stringWithFormat:@"https://api.twitter.com/1.1/trends/place.json?id=%@", [NSString stringWithFormat:@"%ld",(long)location]];
  
  [TwitterFetch fetch:self url:url didFinishSelector:@selector(didReceiveuserdata2:data:) didFailSelector:@selector(didFailOauth:error:)];
  
}

- (void)didReceiveuserdata2:(OAServiceTicket*)ticket data:(NSData*)data {
  //NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  //NSLog(@"didReceive user data %@", httpBody);
  
  NSArray *twitterTrends   = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers       error:nil];
  NSArray *trendArray  = [[twitterTrends objectAtIndex:0] objectForKey:@"trends"];
  
  self.trendDB = [[NSMutableArray alloc] init];
  
  for (NSDictionary *trend in trendArray) {
    Trend *trendObj = [Trend alloc];
    trendObj.name = [trend objectForKey:@"name"];
    trendObj.url = [trend objectForKey:@"url"];
    [self.trendDB addObject:trendObj];
  }
  
  // Reload the table view.
  [self.tblPeople reloadData];
}

- (void)didFailOauth:(OAServiceTicket*)ticket error:(NSError*)error {
  NSLog(@"OauthFail %@", error);
}



//Enter portrait mode
#pragma mark - UISplitViewDelegate methods
-(void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
  //Grab a reference to the popover
  self.popover = pc;
  
  //Set the title of the bar button item
 //barButtonItem.title = @"Regions";
  
  //Set the bar button item as the Nav Bar's leftBarButtonItem
//[_navBarItem setLeftBarButtonItem:barButtonItem animated:YES];
}

//Enter landscape mode
-(void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
  //Remove the barButtonItem.
  //[_navBarItem setLeftBarButtonItem:barButtonItem animated:YES];
  
  //Nil out the pointer to the popover.
  _popover = nil;
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
collapseSecondaryViewController:(UIViewController *)secondaryViewController
  ontoPrimaryViewController:(UIViewController *)primaryViewController
{
  //Note, this does not get called on ipad. It may only be for iphone 6 (?)
  return YES; //Default Value
}
@end

