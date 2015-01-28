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
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation LocationModel
static NSInteger woeid = 0;
static float longtitude = 0;
static float lattitude = 0;
+(NSInteger)getWoeid
{
  return woeid;
}

+(void)setWoeid:(NSInteger)woeidIn
{
  woeid = woeidIn;
}

-(id)init
{
    // ** Don't forget to add NSLocationWhenInUseUsageDescription in MyApp-Info.plist and give it a string
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
      [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    
    return self;
}


+(float)getCurrentLongitude
{
  if (longtitude == 0) {
    //assert(0);
    return -122.0419; //Default to cupertiono, CA, USA
    
  } else {
    return longtitude;
  }
}
+(float)getCurrentLatitude
{
  if (lattitude == 0) {
    //assert(0);
    return 37.3175; //Default to cupertiono, CA, USA
  } else {
    return lattitude;
  }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
  //NSLog(@"locationManager CALLBACK %@", [locations lastObject]);
  CLLocation *myLocation = [locations lastObject];
  longtitude = myLocation.coordinate.longitude;
  lattitude = myLocation.coordinate.latitude;
}


@end
