//
//  LeftViewController.m
//  twendy
//
//  Created by Macadamian on 1/27/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//

//
//  LeftViewController.m
//  MathMonsters
//
//  Created by Ellen Shapiro on 1/8/13.
//  Copyright (c) 2013 Designated Nerd Software. All rights reserved.
//

#import "LeftViewController.h"
#import "RightViewController.h"
#import "AuthenticationModel.h"
#import "RegionModel.h"
#import "Notifications.h"

@interface LeftViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tblRegion;
@end

@implementation LeftViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.tblRegion.delegate = self;
  self.tblRegion.dataSource = self;
  
  [self.tblRegion reloadData];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(regionsWereRetrieved:) name:RegionsRetrieved object:nil];
  
}

-(void) viewDidAppear: (BOOL) animated {
  [super viewDidAppear:animated];

}

-(void) viewWillAppear: (BOOL) animated {
  if ([AuthenticationModel isLoggedIn] == YES) {
    [self.tblRegion reloadData];
  } else {
      [self login:nil];
  }
  [super viewWillAppear:animated];
}

-(IBAction)login:(id)sender {
  [self performSegueWithIdentifier:@"idSegueAuth2" sender:self];
}

-(void)regionsWereRetrieved:(NSNotification*)obj
{
  [self.tblRegion reloadData];
}


-(void)userLoggedOut:(NSNotification*)obj {
  [RegionModel reset];
  [self.tblRegion reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [RegionModel count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idRegionCellRecord" forIndexPath:indexPath];
  
  Region *region = [RegionModel get:indexPath.row];
  cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", region.country, region.city];
  
  NSLog(@"table view region = %ld", (long)region.woeid);
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)region.woeid];
  
  
  if (region.selected == YES) {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  } else {
    cell.accessoryType = UITableViewCellAccessoryNone;
  }
  
  
  return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  Region *region = [RegionModel get:indexPath.row];
  
  NSLog(@"region = %ld", (long)region.woeid);
  id tmp = [[[NSUserDefaults standardUserDefaults] objectForKey:@"configRegion"] mutableCopy];
  
  NSMutableDictionary* configRegionDict;
  if (tmp == nil) {
    configRegionDict = [[NSMutableDictionary alloc]init];
  }else {
    configRegionDict = tmp;
  }
  
  NSLog(@"configRegionDict before %@",configRegionDict);
  
  if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
    cell.accessoryType = UITableViewCellAccessoryNone;
    region.selected = NO;
    [configRegionDict removeObjectForKey:region.city];
  } else {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    region.selected = YES;
    [configRegionDict setObject:[NSNumber numberWithInteger:region.woeid] forKey:region.city];
  }
  [[NSUserDefaults standardUserDefaults] setObject:configRegionDict forKey:@"configRegion"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  NSLog(@"configRegionDict after %@",configRegionDict);
  
 UIStoryboard *aStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];

 RightViewController *rightViewController = [aStoryboard instantiateViewControllerWithIdentifier:@"RightViewController"];

  [rightViewController getWoeid:region.woeid];
  
 // RightViewController *rightViewController2 = (RightViewController*)self.delegate;
 // [rightViewController2 getWoeid:region.woeid];

}


- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
