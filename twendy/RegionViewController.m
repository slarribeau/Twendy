//
//  RegionViewController.m
//  twendy
//
//  Created by Macadamian on 1/13/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//


#import "RegionViewController.h"
#import "Region.h"

@interface RegionViewController ()

@end

@implementation RegionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
  self.tblRegion.delegate = self;
  self.tblRegion.dataSource = self;

  self.regionArray = [self.delegate getRegionArray];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
  return self.regionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idRegionCellRecord" forIndexPath:indexPath];
  
  Region *region = self.regionArray[indexPath.row];
  cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", region.country, region.city];
  
  cell.detailTextLabel.text = @"text";
  

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
  Region *region = self.regionArray[indexPath.row];

  
  id tmp = [[[NSUserDefaults standardUserDefaults] valueForKey:@"configRegion"] mutableCopy];
  NSMutableArray* configRegionArray;
  if (tmp == nil) {
    configRegionArray = [[NSMutableArray alloc]init];
  }else {
     configRegionArray = tmp;
  }
  
  NSLog(@"configRegionArray before %@",configRegionArray);

  if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
    cell.accessoryType = UITableViewCellAccessoryNone;
    region.selected = NO;
    for (int i=configRegionArray.count-1; i>-1; i--) {
      if ([region.city isEqualToString:configRegionArray[i]]) {
         [configRegionArray removeObjectAtIndex:i];
      }
    }

  } else {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    region.selected = YES;
    [configRegionArray addObject:region.city];

  }
  [[NSUserDefaults standardUserDefaults] setValue:configRegionArray forKey:@"configRegion"];
  NSLog(@"configRegionArray after %@",configRegionArray);

  [self.delegate menuHasChanged];
}
@end