//
//  AuthenticationData.h
//  twendy
//
//  Created by Scott Larribeau on 1/21/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthConsumer.h"

@interface AuthenticationModel : NSObject
+(BOOL) isLoggedIn;
+(void) setIsLoggedIn:(BOOL)status;
+(OAToken*) getAccessToken;
+(void) setRequestToken:(OAToken*)token;
+(OAToken*) getRequestToken;
+(void) setAccessToken:(OAToken*)token;
+(OAConsumer *) getConsumer;
+(NSString *) getCallback;

@end
