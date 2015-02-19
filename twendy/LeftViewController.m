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
#import "AuthenticationViewController.h"
#import "RegionModel.h"
#import "Notifications.h"
#import "LocationModel.h"


@interface LeftViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tblRegion;
@property (assign, nonatomic) NSInteger selectedRegion;
@property (strong, nonatomic) IBOutlet UISearchBar *search;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

-(IBAction)sortCountryAscend:(id)sender;
-(IBAction)sortCountryDescend:(id)sender;
-(IBAction)sortCityAscend:(id)sender;
-(IBAction)sortCityDescend:(id)sender;
-(IBAction)sortSelectedAscend:(id)sender;
-(IBAction)sortSelectedDescend:(id)sender;

@end

@implementation LeftViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.tblRegion.delegate = self;
  self.tblRegion.dataSource = self;
  
  [self.tblRegion reloadData];
  
  self.selectedRegion = -2;
}

-(void) viewDidAppear: (BOOL) animated {
  if (self.selectedRegion == -2) {
     if ([RegionModel count] > 0) {
       
       self.selectedRegion = -1;

       
       [self.tblRegion reloadData];

       NSLog(@"region model count = %d", [RegionModel count]);
       NSInteger woeidOffset = [RegionModel findWoeidOffset:[LocationModel getWoeid]];

       NSIndexPath *indexPath = [NSIndexPath indexPathForRow:woeidOffset inSection:0] ;
    
       [self.tblRegion selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
       
       Region *region = [RegionModel get:indexPath.row];
       
       RightViewController *rightViewController2 = (RightViewController*)self.delegate2;
       [rightViewController2 setWoeid:region.woeid city:region.city];

    
     }
  } else if (self.selectedRegion >= 0) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.selectedRegion inSection:0] ;

    [self.tblRegion selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
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
  //Use storyboards and prepareForSeque instead
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([[segue destinationViewController] isKindOfClass:[AuthenticationViewController class]]) {
    return;
  } else {
  UINavigationController *nc =
  (UINavigationController *)segue.destinationViewController;
  
  RightViewController *rightViewController =
  (RightViewController *)[nc topViewController];
  
  NSIndexPath *selectedIndexPath = [self.tblRegion indexPathForSelectedRow];
  self.selectedRegion = selectedIndexPath.row;
  
  Region *region = [RegionModel get:self.selectedRegion];
  
  [rightViewController setWoeid:region.woeid city:region.city];
  }
}


#pragma mark - Search and sort

- (void)resetSearch {
  NSMutableArray *keyArray = [[NSMutableArray alloc] init];
  [keyArray addObject:UITableViewIndexSearch];
}

- (void)handleSearchForTerm:(NSString *)searchTerm {
  
  [RegionModel startSearch:searchTerm];
  [self.tblRegion reloadData];
}

- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.search resignFirstResponder];
  self.search.text = @"";
  return indexPath;
}


-(IBAction)sortCountryAscend:(id)sender
{
  [RegionModel sortCountryAscend];
  [self.tblRegion reloadData];
}

-(IBAction)sortCountryDescend:(id)sender
{
  [RegionModel sortCountryDescend];
  [self.tblRegion reloadData];
}

-(IBAction)sortCityAscend:(id)sender
{
  [RegionModel sortCityAscend];
  [self.tblRegion reloadData];
}

-(IBAction)sortCityDescend:(id)sender
{
  [RegionModel sortCityDescend];
  [self.tblRegion reloadData];
}

-(IBAction)sortSelectedAscend:(id)sender
{
  [RegionModel sortSelectedAscend];
  [self.tblRegion reloadData];
}

-(IBAction)sortSelectedDescend:(id)sender
{
  [RegionModel sortSelectedDescend];
  [self.tblRegion reloadData];
}

#pragma mark Search Bar Delegate Methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  NSString *searchTerm = [searchBar text];
  [self handleSearchForTerm:searchTerm];
}

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchTerm {
  if ([searchTerm length] == 0) {
    [RegionModel endSearch];
    [self.tblRegion reloadData];
    [self.cancelButton setHighlighted:YES];
    return;
  }
  [self handleSearchForTerm:searchTerm];
}

- (IBAction)cancelSearchButton:(id)sender {
  self.search.text = @"";
  [RegionModel endSearch];
  [self.tblRegion reloadData];
  [self.search resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
  [self.cancelButton setHighlighted:NO];
}


- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
