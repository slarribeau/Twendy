//
//  AppDelegate.m
//  twendy
//
//  Created by Macadamian on 1/9/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//

#import "AppDelegate.h"
#import "Accounts/Accounts.h"
#import "AuthenticationModel.h"
#import "RegionModel.h"
#import "LocationModel.h"
#import "RightViewController.h"
#import "LeftViewController.h"


@interface AppDelegate ()

@end

@implementation AppDelegate
#define IOS_VERSION [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] firstObject] intValue]

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  //Currently using split view controller for both iphone and ipad. On iphone, having the SVC,
  //we start up in left controller instead of right controller which is a bit better looking for usr.
  /* if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) */{

  UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
  
  //Grab a reference to the RightViewController and set it as the SVC's delegate.
  UINavigationController *rightNavController = [splitViewController.viewControllers lastObject];

  rightNavController.topViewController.navigationItem.leftBarButtonItem =
  splitViewController.displayModeButtonItem;
  
  rightNavController.topViewController.navigationItem.leftItemsSupplementBackButton = true;


  RightViewController *rightViewController = (RightViewController *)[rightNavController topViewController];
  splitViewController.delegate = rightViewController;
  
  

  //Grab a reference to the LeftViewController and get the first monster in the list.
  UINavigationController *leftNavController = [splitViewController.viewControllers objectAtIndex:0];
  
  LeftViewController *leftViewController = (LeftViewController *)[leftNavController topViewController];
  
  //Set the RightViewController as the left's delegate.
  leftViewController.delegate2 = rightViewController;
  }
  
  
  [[AuthenticationModel alloc] init];
  [[RegionModel alloc] init];
  [[LocationModel alloc] init];

  
  if (IOS_VERSION >= 8) {
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
  }
  return YES;
}
@end
