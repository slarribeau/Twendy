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
#import "LocationModel.h"


@interface LeftViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tblRegion;
@property (assign, nonatomic) NSInteger selectedRegion;
@end

@implementation LeftViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.tblRegion.delegate = self;
  self.tblRegion.dataSource = self;
  
  [self.tblRegion reloadData];
  
  self.selectedRegion = -1;
}

-(void) viewDidAppear: (BOOL) animated {
  if (self.selectedRegion == -1) {
     if ([RegionModel count] > 0) {
       [self.tblRegion reloadData];

       NSLog(@"region model count = %d", [RegionModel count]);
       NSInteger woeidOffset = [RegionModel findWoeidOffset:[LocationModel getWoeid]];

       NSIndexPath *indexPath = [NSIndexPath indexPathForRow:woeidOffset inSection:0] ;
    
       [self.tblRegion selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
       
       Region *region = [RegionModel get:indexPath.row];
       
       RightViewController *rightViewController2 = (RightViewController*)self.delegate;
       [rightViewController2 setWoeid:region.woeid city:region.city];

    
     }
  }

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
  
  return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  Region *region = [RegionModel get:indexPath.row];
  
  RightViewController *rightViewController2 = (RightViewController*)self.delegate;
  [rightViewController2 setWoeid:region.woeid city:region.city];
  
  self.selectedRegion = indexPath.row;
}


- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
