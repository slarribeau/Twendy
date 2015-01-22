//
//  AuthenticationData.h
//  twendy
//
//  Created by Scott Larribeau on 1/21/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthenticationModel : NSObject
+(BOOL) isLoggedIn;
+(void) setIsLoggedIn:(BOOL)status;
@end
