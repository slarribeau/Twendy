//
//  TwitterFetch.h
//  twendy
//
//  Created by Macadamian on 1/21/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterFetch : NSObject
+ (void) fetch:(id)delegate url:(NSString *)url didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector;
@end
