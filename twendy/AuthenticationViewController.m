//
//  AuthenticationViewController.h
//  twendy
//
//  Created by Scott Larribeau
//  See below for Attribution to technogerms.com for OAUTH code.
//    Created by Ammad iOS on 06/12/2013.
//    Copyright (c) 2013 Techno. All rights reserved.
//
//http://codegerms.com/get-user-info-data-twitter-api-example-ios-objective-c/
//

#import "AuthenticationViewController.h"
#import "AuthenticationModel.h"
#import "TwitterFetch.h"
#import "LocationModel.h"



@interface AuthenticationViewController ()
@property (nonatomic, strong) IBOutlet UIWebView *webview; //FIX ME weak?
@property (nonatomic, strong) NSMutableArray *trendNameArray;
@property (nonatomic, strong) NSMutableArray *trendUrlArray;

@end

@implementation AuthenticationViewController
//@synthesize webview, accessToken, trendNameArray;


-(void) viewWillAppear: (BOOL) animated {
  //[self.tableView reloadData];
}


-(void) viewDidAppear: (BOOL) animated {
  //[self.tableView reloadData];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  

  NSURL* requestTokenUrl = [NSURL URLWithString:@"https://api.twitter.com/oauth/request_token"];
  OAMutableURLRequest* requestTokenRequest = [[OAMutableURLRequest alloc] initWithURL:requestTokenUrl
                                                                             consumer:[AuthenticationModel getConsumer]
                                                                                token:nil
                                                                                realm:nil
                                                                    signatureProvider:nil];
  OARequestParameter* callbackParam = [[OARequestParameter alloc] initWithName:@"oauth_callback" value:[AuthenticationModel getCallback]];
  [requestTokenRequest setHTTPMethod:@"POST"];
  [requestTokenRequest setParameters:[NSArray arrayWithObject:callbackParam]];
  OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
  
  NSLog(@" OAMutableURLRequest %@", requestTokenRequest);
  [dataFetcher fetchDataWithRequest:requestTokenRequest
                           delegate:self
                  didFinishSelector:@selector(didReceiveRequestToken:data:)
                    didFailSelector:@selector(didNotReceiveRequestToken:error:)];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)didReceiveRequestToken:(OAServiceTicket*)ticket data:(NSData*)data {
  NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  OAToken *requestToken = [[OAToken alloc] initWithHTTPResponseBody:httpBody];
  [AuthenticationModel setRequestToken:requestToken];
  NSURL* authorizeUrl = [NSURL URLWithString:@"https://api.twitter.com/oauth/authorize"];
  OAMutableURLRequest* authorizeRequest = [[OAMutableURLRequest alloc] initWithURL:authorizeUrl
                                                                          consumer:nil
                                                                             token:nil
                                                                             realm:nil
                                                                 signatureProvider:nil];
  NSString* oauthToken = requestToken.key;
  OARequestParameter* oauthTokenParam = [[OARequestParameter alloc] initWithName:@"oauth_token" value:oauthToken];
  [authorizeRequest setParameters:[NSArray arrayWithObject:oauthTokenParam]];
  
  [self.webview loadRequest:authorizeRequest];
}

- (void)didReceiveAccessToken:(OAServiceTicket*)ticket data:(NSData*)data {
  
  NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  OAToken *accessToken = [[OAToken alloc] initWithHTTPResponseBody:httpBody];
  
  if (accessToken == nil) {
    NSLog(@"Unexpected result received from twitter: Missing access token.");
  } else {
    [AuthenticationModel setAccessToken:accessToken];
    [AuthenticationModel setIsLoggedIn:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSucceed" object:nil];

    [self foo];
  }
}

-(void)foo
{
  NSString *url = [NSString stringWithFormat:@"https://api.twitter.com/1.1/trends/closest.json?lat=%f&long=%f", [LocationModel getCurrentLatitude], [LocationModel getCurrentLongitude]];
  
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
    [LocationModel setWoeid:[[trend objectForKey:@"woeid"] integerValue]];
  }
  [self.navigationController popViewControllerAnimated:YES];

}


- (void)didNotReceiveAccessToken:(OAServiceTicket*)ticket error:(NSError*)error {
  NSLog(@"Failed Access Token Fetch %@", error);
}
- (void)didNotReceiveRequestToken:(OAServiceTicket*)ticket error:(NSError*)error {
  NSLog(@"Failed Request Token Fetch %@", error);
}
- (void)didNotReceiveUserData:(OAServiceTicket*)ticket error:(NSError*)error {
  NSLog(@"Failed User Data Fetch %@", error);
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
  NSString *temp = [NSString stringWithFormat:@"shouldStartLoad %@",request];
  NSRange textRange = [[temp lowercaseString] rangeOfString:[[AuthenticationModel getCallback] lowercaseString]];
  
  if(textRange.location != NSNotFound){
    // Extract oauth_verifier from URL query
    NSString* verifier = nil;
    NSArray* urlParams = [[[request URL] query] componentsSeparatedByString:@"&"];
    for (NSString* param in urlParams) {
      NSArray* keyValue = [param componentsSeparatedByString:@"="];
      NSString* key = [keyValue objectAtIndex:0];
      if ([key isEqualToString:@"oauth_verifier"]) {
        verifier = [keyValue objectAtIndex:1];
        break;
      }
    }
    
    if (verifier == nil) {
      NSLog(@"Unexpected result received from twitter: Missing oauth_verifier.");
    } else {
      NSURL* accessTokenUrl = [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];
      OAMutableURLRequest* accessTokenRequest = [[OAMutableURLRequest alloc] initWithURL:accessTokenUrl consumer:[AuthenticationModel getConsumer] token:[AuthenticationModel getRequestToken] realm:nil signatureProvider:nil];
      OARequestParameter* verifierParam = [[OARequestParameter alloc] initWithName:@"oauth_verifier" value:verifier];
      [accessTokenRequest setHTTPMethod:@"POST"];
      [accessTokenRequest setParameters:[NSArray arrayWithObject:verifierParam]];
      OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
      [dataFetcher fetchDataWithRequest:accessTokenRequest
                               delegate:self
                      didFinishSelector:@selector(didReceiveAccessToken:data:)
                        didFailSelector:@selector(didNotReceiveAccessToken:error:)];
    }
    
    [self.webview removeFromSuperview];
    
    return NO;
  }
  return YES;
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error
{
  NSLog(@"Error! %@", webView.request.URL.absoluteString);
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
  NSLog(@"DidFinishLoad %@", webView.request.URL.absoluteString);
}




@end
