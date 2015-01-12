//
//  TrendingListViewController.h
//  twendy
//
//  Created by Macadamian on 1/9/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TrendingListViewControllerDelegate
-(NSArray*)getTrendArray;
-(NSArray*)getUrlArray;

@end

@interface TrendingListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) id <TrendingListViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *tblPeople;

@end
