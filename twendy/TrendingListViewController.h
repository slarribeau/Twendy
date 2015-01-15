//
//  TrendingListViewController.h
//  twendy
//
//  Created by Macadamian on 1/9/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuthConsumer.h"
#import "RegionViewController.h"

@protocol TrendingListViewControllerDelegate
-(NSArray*)getTrendArray;
-(NSArray*)getUrlArray;
-(OAToken*)getAccessToken;
-(OAConsumer*) getConsumer;


@end

@interface TrendingListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, RegionViewControllerDelegate>
@property (nonatomic, weak) id <TrendingListViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *tblPeople; //FIX ME rename
@property (strong, nonatomic) IBOutlet UIScrollView *scrollMenu;
@property (nonatomic, strong) NSMutableArray *regionArray;

-(IBAction)getHomeTrendDataButton:(id)sender;
-(IBAction)getWorldTrendDataButton:(id)sender;
-(IBAction)getRateLimit:(id)sender;

@end



