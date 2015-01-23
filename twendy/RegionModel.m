//
//  RegionModel.m
//  twendy
//
//  Created by Macadamian on 1/22/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//

#import "RegionModel.h"
#import "TwitterFetch.h"
#import "OAuthConsumer.h"


@implementation RegionModel
static BOOL initialized = NO;
static NSMutableArray* regionDB;

+(void)initialize
{
  if(!initialized)
  {
    initialized = YES;
    regionDB = [[NSMutableArray alloc] init ];
  }
}

-(id)init
{
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload:) name:@"LoginSucceed" object:nil];
  return self;
}


- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+(NSInteger)count
{
  return regionDB.count;
}

+(Region*)get:(NSUInteger)index
{
  if (index >= regionDB.count || regionDB.count ==0) {
    return nil;
  } else {
    return regionDB[index];
  }
}

-(void)reload:(NSNotification *)notification
{
  if (regionDB.count == 0) {
    [TwitterFetch fetch:self url:@"https://api.twitter.com/1.1/trends/available.json" didFinishSelector:@selector(didReceiveRegion:data:) didFailSelector:@selector(didNotReceiveUserData:error:)];

  }
}

- (void)didNotReceiveUserData:(OAServiceTicket*)ticket error:(NSError*)error {
  NSLog(@"Failed User Data Fetch %@", error);
}

- (void)didReceiveRegion:(OAServiceTicket*)ticket data:(NSData*)data {
  //NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  //NSLog(@"didReceiveRegion%@", httpBody);
  id tmp = [[[NSUserDefaults standardUserDefaults] objectForKey:@"configRegion"] mutableCopy];
  NSMutableDictionary* configRegionDict;
  if (tmp == nil) {
    configRegionDict = [[NSMutableDictionary alloc]init];
  }else {
    configRegionDict = tmp;
  }
  
  NSArray *twitterRegions = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers       error:nil];
  
  for (NSDictionary *region in twitterRegions) {
    Region *regionObj = [Region alloc];
    
    regionObj.city = [region objectForKey:@"name"];
    regionObj.country = [region objectForKey:@"country"];
    regionObj.woeid = [[region objectForKey:@"woeid"] intValue];
    
    NSInteger woeid = [[configRegionDict objectForKey:regionObj.city] intValue];
    
    if (woeid == regionObj.woeid) {
      regionObj.selected = YES;
    }
    
    [regionDB addObject:regionObj];
  }
  
}


@end
