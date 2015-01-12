//
//  TrendingListViewController.m
//  twendy
//
//  Created by Macadamian on 1/9/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//

#import "TrendingListViewController.h"
#import "TrendViewController.h"

@interface TrendingListViewController ()
@property (nonatomic, strong) NSArray *arrPeopleInfo;
@property (nonatomic, strong) NSArray *trendUrlInfo;
@property (nonatomic) int recordIDToEdit;

@end

@implementation TrendingListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  self.tblPeople.delegate = self;
  self.tblPeople.dataSource = self;

  // Get the results.
  if (self.arrPeopleInfo != nil) {
    self.arrPeopleInfo = nil;
  }
  
  self.arrPeopleInfo = [self.delegate getTrendArray];
  
  // Get the results.
  if (self.trendUrlInfo != nil) {
    self.trendUrlInfo = nil;
  }
  
  self.trendUrlInfo = [self.delegate getUrlArray];


  // Reload the table view.
  [self.tblPeople reloadData];


  
  

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
  NSLog(@"array=%@ count=%lu", self.arrPeopleInfo, (unsigned long)self.arrPeopleInfo.count);
 // return 10;
  return self.arrPeopleInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCellRecord" forIndexPath:indexPath];

  //[tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"
                               //   forIndexPath:indexPath];
  
  
  //CREATE TABLE serverdb(serverdbID integer primary key, baseUrl text, parameters text, nickname text,  active integer);
  
  
  cell.textLabel.text = self.arrPeopleInfo[indexPath.row];
  
  cell.detailTextLabel.text = @"bar";
  return cell;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
  // Get the record ID of the selected name and set it to the recordIDToEdit property.
  self.recordIDToEdit = indexPath.row;
  
  // Perform the segue.
  [self performSegueWithIdentifier:@"idSegueTrend" sender:self];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  TrendViewController *trendViewController = [segue destinationViewController];
  //[trendViewController foo:self.trendUrlInfo[self.recordIDToEdit]];
}

@end
