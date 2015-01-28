//
//  RegionViewController.h
//  twendy
//
//  Created by Macadamian on 1/13/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuthConsumer.h"

@interface RegionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

-(IBAction)sort:(id)sender;

-(IBAction)sortCountryAscend:(id)sender;
-(IBAction)sortCountryDescend:(id)sender;
-(IBAction)sortCityAscend:(id)sender;
-(IBAction)sortCityDescend:(id)sender;
-(IBAction)sortSelectedAscend:(id)sender;
-(IBAction)sortSelectedDescend:(id)sender;

@end
