//
//  TwitterFetch.m
//  twendy
//
//  Created by Macadamian on 1/21/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//

#import "TwitterFetch.h"
#import "AuthenticationModel.h"

@implementation TwitterFetch
+ (void) fetch:(id)delegate url:(NSString *)url didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector
{
  OAConsumer* consumer = [AuthenticationModel getConsumer];
  OAToken* accessToken = [AuthenticationModel getAccessToken];
  
  if (accessToken) {
    NSURL* userdatarequestu = [NSURL URLWithString:url];
    
    OAMutableURLRequest* requestTokenRequest;
    requestTokenRequest = [[OAMutableURLRequest alloc]
                           initWithURL:userdatarequestu
                           
                           consumer:consumer
                           
                           token:accessToken
                           
                           realm:nil
                           
                           signatureProvider:nil];
    
    [requestTokenRequest setHTTPMethod:@"GET"];
    
    OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
    
    [dataFetcher fetchDataWithRequest:requestTokenRequest
                             delegate:delegate
                    didFinishSelector:finishSelector
                      didFailSelector:failSelector];
     } else {
      NSLog(@"ERROR!!");
    }
}

@end
