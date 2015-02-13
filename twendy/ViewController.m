//
//  TrendingListViewController.m
//  twendy
//
//  Created by Macadamian on 1/9/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//

#import "ViewController.h"
#import "TrendViewController.h"
#import "RegionViewController.h"
#import "Region.h"
#import "Trend.h"
#import "AuthenticationModel.h"
#import "TwitterFetch.h"
#import "LocationModel.h"
#import "Notifications.h"
#import "RegionModel.h"



@interface ViewController ()
//This is an extension not a category.
@property (nonatomic, strong) NSMutableArray *trendDB;
@property (nonatomic) NSInteger recordIDToEdit;
@property (nonatomic) NSInteger selected;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *loginButton;

@end

@implementation ViewController

static NSString * const kMenuSelectionMark = @"*";
static NSString * const kMenuUnSelectionMark = @" ";

static int const kButtonWidth = 100;

- (void)viewDidLoad {
    [super viewDidLoad];
  
  self.tblPeople.delegate = self;
  self.tblPeople.dataSource = self;

  self.recordIDToEdit = -1;
  self.selected = -1;


  
  if ([AuthenticationModel isLoggedIn] == NO) {
    [self login:nil];
  } else {
    // Reload the table view.
    [self.tblPeople reloadData];
    
    [self createScrollMenu];
  }
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuHasChanged:) name:MenuHasChanged object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedOut:) name:LogoutSucceed object:nil];

}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) viewDidAppear: (BOOL) animated {
  //[self.tableView reloadData];
}


-(void) viewWillAppear: (BOOL) animated {
  NSLog(@"ViewController:viewWillAppear enter");
  if ([AuthenticationModel isLoggedIn] == YES) {
    [self.loginButton setTitle:@"Logout"];
  } else {
    [self.loginButton setTitle:@"Login"];
  }
  
  if (self.trendDB.count == 0) {
    [self getTrendData:[LocationModel getWoeid]];
  } else {
    // Reload the table view.
    [self.tblPeople reloadData];
    [self createScrollMenu];
  }

  if (self.selected >= 0) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.selected inSection:0] ;

    [self.tblPeople selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
  }
  NSLog(@"ViewController:viewWillAppear exit");

}
-(IBAction)login:(id)sender {
  [self performSegueWithIdentifier:@"idSegueAuth" sender:self];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
  if (self.recordIDToEdit >= 0) {
    TrendViewController *trendViewController = [segue destinationViewController];
    Trend *trendObj = self.trendDB[self.recordIDToEdit];

    trendViewController.trendUrl = trendObj.url;
    self.recordIDToEdit = -1;
  }
}

-(void)userLoggedOut:(NSNotification*)obj {
  [RegionModel reset];
  self.trendDB = [[NSMutableArray alloc] init];
  [self.tblPeople reloadData];
  [self clearScrollMenu];
}

-(void)menuHasChanged:(NSNotification*)obj {
  [self createScrollMenu];
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
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCellRecord" forIndexPath:indexPath];
  
  Trend *trendObj = self.trendDB[indexPath.row];
  cell.textLabel.text = trendObj.name;
  //cell.detailTextLabel.text = @"text";
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
  // Get the record ID of the selected name and set it to the recordIDToEdit property.
  self.recordIDToEdit = indexPath.row;
  self.selected = indexPath.row;
  
  // Perform the segue.
  [self performSegueWithIdentifier:@"idSegueTrend" sender:self];
  
  self.recordIDToEdit = -1; //This will be checked later in prepareSeque method
}

#pragma - mark button management
-(BOOL)doesString:(NSString *)string containCharacter:(char)character
{
  if ([string rangeOfString:[NSString stringWithFormat:@"%c",character]].location != NSNotFound)
  {
    return YES;
  }
  return NO;
}

-(void)saveMenuSelection:(NSInteger)woeid
{
  NSInteger  selectedConfigRegionWoeid = [[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedConfigRegion"] intValue];

  NSLog(@"selectedConfigRegion before %ld",(long)selectedConfigRegionWoeid);
  
  [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:woeid] forKey:@"selectedConfigRegion"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  selectedConfigRegionWoeid = [[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedConfigRegion"] intValue];
  
  NSLog(@"selectedConfigRegion after %ld",(long)selectedConfigRegionWoeid);
}

-(void)setNavigationItemTitle:(NSString *)title
{
  //strip first chracter.
  self.navigationItem.title = [title substringWithRange:NSMakeRange(1, [title length]-1)];
}
-(void)setMenuSelection:(UIButton*)button
{
  [self setNavigationItemTitle:[button currentTitle]];
  NSLog(@"Before set: [%@]", [button currentTitle]);

  [button setTitle: [[button currentTitle] stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:kMenuSelectionMark] forState:UIControlStateNormal];

  NSLog(@"After set: [%@]", [button currentTitle]);
  [self saveMenuSelection:button.tag];
  [self setNavigationItemTitle:[button currentTitle]];
}

-(void)removeMenuSelection
{
  for (id object in [self.scrollMenu subviews])  {
    if ([object isMemberOfClass:[UIButton class]]) {
      UIButton *button = (UIButton*)object;
      NSString *title = [button currentTitle];
      
      if ([title hasPrefix:kMenuSelectionMark] && [title length] > 1) {

      
         NSLog(@"Before remove: [%@]", [button currentTitle]);

        [button setTitle: [title stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:kMenuUnSelectionMark] forState:UIControlStateNormal];

        NSLog(@"after remove: [%@]", [button currentTitle]);
      

        break;
      }
    }
  }
}

-(void)addScrollButton:(int)offset name:(NSString *)name action:(SEL)action tag:(NSInteger)tag
{
  int x = kButtonWidth * offset;
  UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, 0, kButtonWidth, 100)];
  [button setTitle:name forState:UIControlStateNormal];
  
  [button addTarget:self action:action forControlEvents:UIControlEventTouchDown];
  [self.scrollMenu addSubview:button];
  button.tag = tag;
}

-(void)clearScrollMenu
{
  for (UIView *view in [self.scrollMenu subviews])
  {
    [view removeFromSuperview];
  }
}
- (void)createScrollMenu //TODO -> Leaky!
{
  //Clean up in case this is being called after first time
  [self clearScrollMenu];
  int x = 0;
  
  [self addScrollButton:x name:[NSString stringWithFormat:@"%@%@",kMenuUnSelectionMark,@"Home" ] action:@selector(getHomeTrendDataButton:) tag:0]; //Tag for home is zero.

  x++;
  
  id tmp = [[[NSUserDefaults standardUserDefaults] objectForKey:@"configRegion"] mutableCopy];
  NSMutableDictionary* configRegionDict;
  if (tmp == nil) {
    configRegionDict = [[NSMutableDictionary alloc]init];
  }else {
    configRegionDict = tmp;
    
    for(id key in configRegionDict) {
      NSInteger woedInt = [[configRegionDict objectForKey:key] intValue];

      [self addScrollButton:x name:[NSString stringWithFormat:@"%@%@",kMenuUnSelectionMark,key] action:@selector(getGenericTrendDataButton:) tag:woedInt];
      x++;
    }
  }

  [self addScrollButton:x name:[NSString stringWithFormat:@"%@%@",kMenuUnSelectionMark, @"Add"] action:@selector(getRegions) tag:-1];
  
  
  x++; //Need an extra increment so that we can scroll to end of last button
  self.scrollMenu.contentSize = CGSizeMake(kButtonWidth*x, self.scrollMenu.frame.size.height);
  self.scrollMenu.backgroundColor = [UIColor redColor];
  
  NSInteger selectedConfigRegionWoeid = [[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedConfigRegion"] intValue];

  //If selectedConfigRegionWoeid is set to zero, either user selected home or he has
  //selected nothing, in either case, set HOME as 'selected'
  //Find the button that matches selectedConfigRegionWoeid and 'select' it
  BOOL foundMatch = NO;
  UIButton *homeButton;
  for (id object in [self.scrollMenu subviews])  {
    if ([object isMemberOfClass:[UIButton class]]) {
      UIButton *button = (UIButton*)object;
      if (button.tag == 0) {
        homeButton = button;
      }
      if (button.tag == selectedConfigRegionWoeid) {
        [self setMenuSelection:button];
        foundMatch = YES;
        break;
      }
    }
  }
  if (foundMatch == NO) {
    //region in menu may have been unselected, set region to home
    [self getHomeTrendDataButton:homeButton];
  }
}


#pragma mark - request data from twitter api
-(IBAction)getGenericTrendDataButton:(id)sender {
  UIButton *button = (UIButton*)sender;
  [self removeMenuSelection];
  [self setMenuSelection:button];
  [self getTrendData:button.tag];
}

-(IBAction)getHomeTrendDataButton:(id)sender{
  UIButton *button = (UIButton*)sender;
  [self removeMenuSelection];
  [self setMenuSelection:button];
  [self getTrendData:[LocationModel getWoeid]];
}

- (void)didFailOauth:(OAServiceTicket*)ticket error:(NSError*)error {
  NSLog(@"OauthFail %@", error);
}

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
  
  [TwitterFetch fetch:self url:url didFinishSelector:@selector(didReceiveuserdata:data:) didFailSelector:@selector(didFailOauth:error:)];
  
}

-(IBAction)getRateLimit:(id)sender {
  NSString *url = @"https://api.twitter.com/1.1/application/rate_limit_status.json";
  
  [TwitterFetch fetch:self url:url didFinishSelector:@selector(didReceiveRateLimit:data:) didFailSelector:@selector(didFailOauth:error:)];
}

-(void)getRegions
{
  [self performSegueWithIdentifier:@"idSegueRegion" sender:self];
}


#pragma mark - handle data returned from twitter api
- (void)didReceiveRateLimit:(OAServiceTicket*)ticket data:(NSData*)data {
  //NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  //NSLog(@"didReceive rate limit %@", httpBody);
}

- (void)didReceiveuserdata:(OAServiceTicket*)ticket data:(NSData*)data {
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
  [self createScrollMenu];
}

@end
