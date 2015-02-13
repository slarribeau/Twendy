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

@end

@implementation RegionViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.tblRegion.delegate = self;
  self.tblRegion.dataSource = self;
 
  [self.tblRegion reloadData];
}

- (void)resetSearch {
  //self.names = [self.allNames mutableDeepCopy];
  NSMutableArray *keyArray = [[NSMutableArray alloc] init];
  [keyArray addObject:UITableViewIndexSearch];
  //[keyArray addObjectsFromArray:[[self.allNames allKeys]
   //                              sortedArrayUsingSelector:@selector(compare:)]];
  //self.keys = keyArray;
}

- (void)handleSearchForTerm:(NSString *)searchTerm {
  
  [RegionModel startSearch:searchTerm];
  [self.tblRegion reloadData];

  //NSMutableArray *sectionsToRemove = [[NSMutableArray alloc] init];
  //[self resetSearch];
  
  for (NSString *key in self.keys) {
  //  NSMutableArray *array = [names valueForKey:key];
    NSMutableArray *toRemove = [[NSMutableArray alloc] init];
   // for (NSString *name in array) {
    //  if ([name rangeOfString:searchTerm
    //                  options:NSCaseInsensitiveSearch].location == NSNotFound)
     //   [toRemove addObject:name];
    }
    //if ([array count] == [toRemove count])
    //  [sectionsToRemove addObject:key];
    
    //[array removeObjectsInArray:toRemove];
 // }
  //[self.keys removeObjectsInArray:sectionsToRemove];
  //[table reloadData];
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

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
  NSLog(@"Hullo?");
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

}

- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.search resignFirstResponder];
  self.isSearching = NO;
  self.search.text = @"";
  [tableView reloadData];
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
    //[self resetSearch];
    //[table reloadData];
    return;
  }
  [self handleSearchForTerm:searchTerm];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  self.isSearching = NO;
  self.search.text = @"";
//[self resetSearch];
 // [table reloadData];
  [RegionModel endSearch];
  [searchBar resignFirstResponder];
  [self.tblRegion reloadData];

}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
  self.isSearching = YES;
 // [table reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView
sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index {
  //NSString *key = [keys objectAtIndex:index];
  //if (key == UITableViewIndexSearch) {
    [tableView setContentOffset:CGPointZero animated:NO];
    return NSNotFound;
  //} else return index;
}

@end