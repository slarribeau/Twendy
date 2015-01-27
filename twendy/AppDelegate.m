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

@interface AppDelegate ()

@end

@implementation AppDelegate
#define IOS_VERSION [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] firstObject] intValue]

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

  UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
  NSLog(@"SVC controllers = %@", splitViewController.viewControllers);

  [[AuthenticationModel alloc] init];
  [[RegionModel alloc] init];
  [[LocationModel alloc] init];

  
  if (IOS_VERSION >= 8) {
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
  }

  
#if 0
  ACAccountStore *account = [[ACAccountStore alloc] init];
  NSArray *debug = [account accounts];
  ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
  //NSString *message = _textView.text;
  //hear before posting u can allow user to select the account
  NSArray *arrayOfAccons = [account accountsWithAccountType:accountType];
  for(ACAccount *acc in arrayOfAccons)
  {
    NSLog(@"%@",acc.username); //in this u can get all accounts user names provide some UI for user to select,such as UITableview
  }
#endif
#if 0
  // Create an account store object.
  ACAccountStore *accountStore = [[ACAccountStore alloc] init];
  
  // Create an account type that ensures Twitter accounts are retrieved.
  ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
  
  // Request access from the user to use their Twitter accounts.
  [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
    if(granted) {
      NSLog(@"Granted!");
      // Get the list of Twitter accounts.
      NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
      
      NSLog(@"accounts = %@", accountsArray);
      if ([accountsArray count] > 0) {
        // Grab the initial Twitter account to tweet from.
        ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
        NSLog(@"TwitterAccount = %@", twitterAccount);
        //TWRequest *postRequest = nil;
        
        //postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"] parameters:[NSDictionary dictionaryWithObject:[self stringToPost] forKey:@"status"] requestMethod:TWRequestMethodPOST];
        
        
        
        // Set the account used to post the tweet.
       // [postRequest setAccount:twitterAccount];
        
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        //  [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        //    dispatch_async(dispatch_get_main_queue(), ^(void) {
          //    if ([urlResponse statusCode] == 200) {
            //    Alert(0, nil, @"Tweet Successful", @"Ok", nil);
             // }else {
                
                //Alert(0, nil, @"Tweet failed", @"Ok", nil);
              //}
          //  });
         // }];
        //});
        
      }
      else
      {
        NSLog(@"Denied!");

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=TWITTER"]];
      }
    }
  }
   ];
#endif
  return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
  UIApplicationState state = [application applicationState];
  if (state == UIApplicationStateActive) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder"
                                                    message:notification.alertBody
                                                   delegate:self cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
  }
  
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
