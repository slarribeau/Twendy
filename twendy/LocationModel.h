//
//  LocationModel.h
//  twendy
//
//  Created by Macadamian on 1/22/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@import CoreLocation;


@interface LocationModel : NSObject <CLLocationManagerDelegate>
+(NSInteger)getWoeid;
+(void)setWoeid:(NSInteger)woeid;
+(float)getCurrentLongitude;
+(float)getCurrentLatitude;

@end
