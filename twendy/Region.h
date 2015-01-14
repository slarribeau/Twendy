//
//  Region.h
//  twendy
//
//  Created by Macadamian on 1/14/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Region : NSObject 
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *woeid;
@property (nonatomic, assign) BOOL selected;

@end
