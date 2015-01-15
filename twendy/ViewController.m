//
//  ViewController.m
//  TechnoGerms.com
//
//  Created by Ammad iOS on 06/12/2013.
//  Copyright (c) 2013 Techno. All rights reserved.
//
//http://codegerms.com/get-user-info-data-twitter-api-example-ios-objective-c/
//

#import "ViewController.h"

//NSString *client_id = @"2sVEcZDhudTeScaMShpd3w";
//NSString *secret = @"CVqonV4B8wDxSnwzzXCC2uhak8H22R1gXhbsCSF1400"; //codegerms
NSString *client_id = @"3gVLXgS5yRw9L1LwuO49mT2UN";
NSString *secret = @"cEsD1MLgWwgnkddxjyN41DkYiaaGS8Dt6jITfeb8UrW4L85MfU"; //Scott

NSString *callback = @"http://nowandzen.com/callback";


@interface ViewController ()

@end

@implementation ViewController
@synthesize webview, isLogin,accessToken, trendNameArray;

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
  [dataFetcher fetchDataWithRequest:requestTokenRequest
                           delegate:self
                  didFinishSelector:@selector(didReceiveRequestToken:data:)
                    didFailSelector:@selector(didFailOAuth:error:)];
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

#if 0
- (void)didReceiveAccessToken:(OAServiceTicket*)ticket data:(NSData*)data {
  NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  accessToken = [[OAToken alloc] initWithHTTPResponseBody:httpBody];
  // WebServiceSocket *connection = [[WebServiceSocket alloc] init];
  //  connection.delegate = self;
  NSString *pdata = [NSString stringWithFormat:@"type=2&token=%@&secret=%@&login=%@", accessToken.key, accessToken.secret, self.isLogin];
  // [connection fetch:1 withPostdata:pdata withGetData:@"" isSilent:NO];
  NSLog(@"%@",accessToken.secret);
  
  
  UIAlertView *alertView = [[UIAlertView alloc]
                            initWithTitle:@"Twitter Access Tooken"
                            message:pdata
                            delegate:nil
                            cancelButtonTitle:@"OK"
                            otherButtonTitles:nil];
  [alertView show];
  
  
}
#endif

- (void)didReceiveAccessToken:(OAServiceTicket*)ticket data:(NSData*)data {
  
  NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  accessToken = [[OAToken alloc] initWithHTTPResponseBody:httpBody];
  // WebServiceSocket *connection = [[WebServiceSocket alloc] init];
  //  connection.delegate = self;
  
  NSString *pdata = [NSString stringWithFormat:@"type=2&token=%@&secret=%@&login=%@", accessToken.key, accessToken.secret, self.isLogin];
  // [connection fetch:1 withPostdata:pdata withGetData:@"" isSilent:NO];
  NSLog(@"%@",accessToken.secret);
  
  //codegerms.com
  
  if (accessToken) {
    // NSURL* userdatarequestu = [NSURL URLWithString:@"https://api.twitter.com/1.1/account/verify_credentials.json"];
    
    NSURL* userdatarequestu = [NSURL URLWithString:@"https://api.twitter.com/1.1/trends/place.json?id=2487956"];
    
    //2488042 = 'San Jose CA USA'
    //2487956 = 'San Francisco CA USA'
    //http://woeid.rosselliot.co.nz/lookup/san%20francisco
    
    
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
                    didFinishSelector:@selector(didReceiveuserdata:data:)
                      didFailSelector:@selector(didFailOAuth:error:)];    } else {
      NSLog(@"ERROR!!");
    }
  
  
  
}


- (void)didReceiveuserdata:(OAServiceTicket*)ticket data:(NSData*)data {
  NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  
  NSLog(@"didReceie %@", httpBody); //TODO - this may contan an error if rate limit exceeded
  
  NSArray *twitterTrends   = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers       error:nil];
  NSArray *trends  = [[twitterTrends objectAtIndex:0] objectForKey:@"trends"];
  
  
  trendNameArray = [[NSMutableArray alloc] init];
  trendUrlArray = [[NSMutableArray alloc] init];

  
  for (NSDictionary *trend in trends) {
    NSLog(@"trend = %@", trend);
    
    NSString *names = [trend objectForKey:@"name"];
    
    NSString *urls = [trend objectForKey:@"url"];
    
    //NSString *label = [title objectForKey:@"label"];
    //PlaceDataObject *place = [PlaceDataObject alloc] initWithJSONData:eachPlace];
    
    [trendNameArray addObject:names];
    [trendUrlArray addObject:urls];

    
  }
  NSLog(@"Built me an trendNameArray:%lu", (unsigned long)trendNameArray.count);
  
  [self performSegueWithIdentifier:@"idSegueTrendingList" sender:self];

}

- (void)didFailOAuth:(OAServiceTicket*)ticket error:(NSError*)error {
  NSLog(@"Failed OAUTH");}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
  //  [indicator startAnimating];
  NSString *temp = [NSString stringWithFormat:@"shouldStartLoad %@",request];
  //  BOOL result = [[temp lowercaseString] hasPrefix:@"http://codegerms.com/callback"];
  // if (result) {
  NSRange textRange = [[temp lowercaseString] rangeOfString:[/*@"http://codegerms.com/callback"*/ callback lowercaseString]];
  
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
    
    if (verifier) {
      NSURL* accessTokenUrl = [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];
      OAMutableURLRequest* accessTokenRequest = [[OAMutableURLRequest alloc] initWithURL:accessTokenUrl consumer:consumer token:requestToken realm:nil signatureProvider:nil];
      OARequestParameter* verifierParam = [[OARequestParameter alloc] initWithName:@"oauth_verifier" value:verifier];
      [accessTokenRequest setHTTPMethod:@"POST"];
      [accessTokenRequest setParameters:[NSArray arrayWithObject:verifierParam]];
      OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
      [dataFetcher fetchDataWithRequest:accessTokenRequest
                               delegate:self
                      didFinishSelector:@selector(didReceiveAccessToken:data:)
                        didFailSelector:@selector(didFailOAuth:error:)];
    } else {
      // ERROR!
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
  // [indicator stopAnimating];
  NSLog(@"DidFinishLoad %@", webView.request.URL.absoluteString);
  
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
  UINavigationController *nc =
  (UINavigationController *)segue.destinationViewController;

  TrendingListViewController *trendingListViewController = (TrendingListViewController*)[nc topViewController];
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
