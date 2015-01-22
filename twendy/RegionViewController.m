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

@interface RegionViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tblRegion;
@end

@implementation RegionViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.tblRegion.delegate = self;
  self.tblRegion.dataSource = self;
 
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

  [[NSNotificationCenter defaultCenter] postNotificationName:@"MenuHasChanged" object:nil];

}
@end