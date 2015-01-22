//
//  LocationModel.m
//  twendy
//
//  Created by Macadamian on 1/22/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//

#import "LocationModel.h"
#import "TwitterFetch.h"
#import "OAuthConsumer.h"



@interface LocationModel ()
@property (nonatomic, assign) float longtitude;
@property (nonatomic, assign) float lattitude;
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation LocationModel
static NSInteger woeid = 0;
+(NSInteger)getWoeid
{
  return woeid;
}

-(id)init
{
    self.longtitude = 0;
    self.lattitude = 0;
    
    // ** Don't forget to add NSLocationWhenInUseUsageDescription in MyApp-Info.plist and give it a string
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
      [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    
    float latitude = self.locationManager.location.coordinate.latitude;
    float longitude = self.locationManager.location.coordinate.longitude;
    NSLog(@"long %f lat %f", longitude, latitude);
    


  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchClosestRegion:) name:@"LoginSucceed" object:nil];
  return self;
}

-(void)fetchClosestRegion:(NSNotification *)notification
{
    NSString *url = [NSString stringWithFormat:@"https://api.twitter.com/1.1/trends/closest.json?lat=%f&long=%f", [self getCurrentLatitude], [self getCurrentLongitude]];
    
    [TwitterFetch fetch:self url:url didFinishSelector:@selector(didReceiveClosestRegion:data:) didFailSelector:@selector(didFailOauth:error:)];
  
}
- (void)didFailOauth:(OAServiceTicket*)ticket error:(NSError*)error {
  NSLog(@"OauthFail %@", error);
}

- (void)didReceiveClosestRegion:(OAServiceTicket*)ticket data:(NSData*)data {
  NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  NSLog(@"++++++++++++++++++++++++++++");
  NSLog(@"didReceiveClosestRegion %@", httpBody);
  
  NSArray *twitterTrends   = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers       error:nil];
  
  for (NSDictionary *trend in twitterTrends) { //FIX ME
    NSLog(@"%@", trend);
    NSLog(@"promise %@", [trend objectForKey:@"woeid"]);
    woeid = [[trend objectForKey:@"woeid"] integerValue];
  }
}

-(float)getCurrentLongitude
{
  NSLog(@"getCurrentLongitude == XXX %f", self.longtitude);
  if (self.longtitude == 0) {
    return -122.0419; //Default to cupertiono, CA, USA
    
  } else {
    return self.longtitude;
  }
}
-(float)getCurrentLatitude
{
  if (self.lattitude == 0) {
    return 37.3175; //Default to cupertiono, CA, USA
  } else {
    return self.lattitude;
  }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
  NSLog(@"%@", [locations lastObject]);
  CLLocation *myLocation = [locations lastObject];
  NSLog(@"lat = %f", myLocation.coordinate.latitude);
  NSLog(@"long = %f", myLocation.coordinate.longitude);
  
  self.longtitude = myLocation.coordinate.longitude;
  self.lattitude = myLocation.coordinate.latitude;
}


@end
