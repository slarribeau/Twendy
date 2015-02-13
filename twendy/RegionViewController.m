//
//  RegionViewController.m
//  twendy
//
//  Created by Macadamian on 1/13/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//


#import "RegionViewController.h"
#import "RegionModel.h"
#import "TwitterFetch.h"
#import "Notifications.h"

@interface RegionViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tblRegion;
@property (strong, nonatomic) IBOutlet UISearchBar *search;
@property (assign, nonatomic) BOOL isSearching;
@property (strong, nonatomic) NSMutableDictionary *names;
@property (strong, nonatomic) NSMutableArray *keys;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

-(IBAction)cancelSearchButton:(id)sender;
-(IBAction)sortSelectedDescend:(id)sender;



@end

@implementation RegionViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.tblRegion.delegate = self;
  self.tblRegion.dataSource = self;
 
  [self.tblRegion reloadData];
}

- (void)resetSearch {
  NSMutableArray *keyArray = [[NSMutableArray alloc] init];
  [keyArray addObject:UITableViewIndexSearch];
}

- (void)handleSearchForTerm:(NSString *)searchTerm {
  
  [RegionModel startSearch:searchTerm];
  [self.tblRegion reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
  return [RegionModel count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
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

  [[NSNotificationCenter defaultCenter] postNotificationName:MenuHasChanged object:nil];
  
  [RegionModel endSearch];
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


@end