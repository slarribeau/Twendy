//
//  RegionViewController.h
//  twendy
//
//  Created by Macadamian on 1/13/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuthConsumer.h"


@protocol RegionViewControllerDelegate
-(NSMutableArray*)getRegionArray;
@end


@interface RegionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tblRegion;
@property (nonatomic, weak) id <RegionViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *regionArray;

@end
