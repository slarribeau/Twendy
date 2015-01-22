//
//  RegionModel.m
//  twendy
//
//  Created by Macadamian on 1/22/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//

#import "RegionModel.h"
#import "Region.h"

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
    
  }
}

@end
