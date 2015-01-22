//
//  AuthenticationData.m
//  twendy
//
//  Created by Scott Larribeau on 1/21/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//

#import "AuthenticationModel.h"

@implementation AuthenticationModel
static BOOL isLoggedInBOOL;

+(void)initialize
{
  static BOOL initialized = NO;
  if(!initialized)
  {
    initialized = YES;
    isLoggedInBOOL = NO;
  }
}

+(BOOL) isLoggedIn
{
  return isLoggedInBOOL;
}

+(void) setIsLoggedIn:(BOOL)status
{
   isLoggedInBOOL = status;
}

@end
