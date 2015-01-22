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

NSString *client_id = @"2sVEcZDhudTeScaMShpd3w";
NSString *secret = @"CVqonV4B8wDxSnwzzXCC2uhak8H22R1gXhbsCSF1400"; //codegerms
NSString *callback = @"http://nowandzen.com/callback";

@interface AuthenticationViewController ()

@end

@implementation AuthenticationViewController
@synthesize webview, accessToken, trendNameArray;


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
  

  

  
  
  
  consumer = [[OAConsumer alloc] initWithKey:client_id secret:secret realm:nil];

  NSURL* requestTokenUrl = [NSURL URLWithString:@"https://api.twitter.com/oauth/request_token"];
  OAMutableURLRequest* requestTokenRequest = [[OAMutableURLRequest alloc] initWithURL:requestTokenUrl
                                                                             consumer:consumer
                                                                                token:nil
                                                                                realm:nil
                                                                    signatureProvider:nil];
  OARequestParameter* callbackParam = [[OARequestParameter alloc] initWithName:@"oauth_callback" value:callback];
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
  requestToken = [[OAToken alloc] initWithHTTPResponseBody:httpBody];
  
  NSURL* authorizeUrl = [NSURL URLWithString:@"https://api.twitter.com/oauth/authorize"];
  OAMutableURLRequest* authorizeRequest = [[OAMutableURLRequest alloc] initWithURL:authorizeUrl
                                                                          consumer:nil
                                                                             token:nil
                                                                             realm:nil
                                                                 signatureProvider:nil];
  NSString* oauthToken = requestToken.key;
  OARequestParameter* oauthTokenParam = [[OARequestParameter alloc] initWithName:@"oauth_token" value:oauthToken];
  [authorizeRequest setParameters:[NSArray arrayWithObject:oauthTokenParam]];
  
  [webview loadRequest:authorizeRequest];
}

- (void)didReceiveAccessToken:(OAServiceTicket*)ticket data:(NSData*)data {
  
  NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  accessToken = [[OAToken alloc] initWithHTTPResponseBody:httpBody];
  
  if (accessToken == nil) {
    NSLog(@"Unexpected result received from twitter: Missing access token.");
  } else {
  
    
    
    [self.navigationController popViewControllerAnimated:YES];

    return;
    
    
    
    
    NSInteger selectedConfigRegionWoeid = [[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedConfigRegion"] intValue];

    NSURL* userdatarequestu;
    if (selectedConfigRegionWoeid == 0) {
      userdatarequestu = [NSURL URLWithString:@"https://api.twitter.com/1.1/trends/place.json?id=2487956"];
    } else {
      userdatarequestu = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/trends/place.json?id=%@", [NSString stringWithFormat:@"%d",selectedConfigRegionWoeid]]];

    }
    
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
                             delegate:self
                    didFinishSelector:@selector(didReceiveUserData:data:)
                      didFailSelector:@selector(didNotReceiveUserData:error:)];
  }
}


- (void)didReceiveUserData:(OAServiceTicket*)ticket data:(NSData*)data {
  NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  
  NSLog(@"didReceie %@", httpBody); //TODO - this may contan an error if rate limit exceeded
  
  NSArray *twitterTrends   = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers       error:nil];
  NSArray *trends  = [[twitterTrends objectAtIndex:0] objectForKey:@"trends"];
  
  
  trendNameArray = [[NSMutableArray alloc] init]; //TODO? Why not self.trendNameArray of _trendNameArray?
  trendUrlArray = [[NSMutableArray alloc] init];

  
  for (NSDictionary *trend in trends) {
    NSString *names = [trend objectForKey:@"name"];
    NSString *urls = [trend objectForKey:@"url"];
    
    [trendNameArray addObject:names];
    [trendUrlArray addObject:urls];

    
  }
  [self performSegueWithIdentifier:@"idSegueTrendingList" sender:self];

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
  NSRange textRange = [[temp lowercaseString] rangeOfString:[callback lowercaseString]];
  
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
      OAMutableURLRequest* accessTokenRequest = [[OAMutableURLRequest alloc] initWithURL:accessTokenUrl consumer:consumer token:requestToken realm:nil signatureProvider:nil];
      OARequestParameter* verifierParam = [[OARequestParameter alloc] initWithName:@"oauth_verifier" value:verifier];
      [accessTokenRequest setHTTPMethod:@"POST"];
      [accessTokenRequest setParameters:[NSArray arrayWithObject:verifierParam]];
      OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
      [dataFetcher fetchDataWithRequest:accessTokenRequest
                               delegate:self
                      didFinishSelector:@selector(didReceiveAccessToken:data:)
                        didFailSelector:@selector(didNotReceiveAccessToken:error:)];
    }
    
    [webView removeFromSuperview];
    
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
  UINavigationController *nc =
  (UINavigationController *)segue.destinationViewController;

  ViewController *trendingListViewController = (ViewController*)[nc topViewController];
  trendingListViewController.delegate = self;
}

-(NSArray*)getTrendArray{
  return trendNameArray;
}

-(NSArray*)getUrlArray{
  return trendUrlArray;
}

-(OAToken*)getAccessToken{
  return accessToken;
}

-(OAConsumer*) getConsumer {
  return consumer;
}


@end
