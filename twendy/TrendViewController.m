//
//  TrendViewController.m
//  twendy
//
//  Created by Macadamian on 1/9/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//

#import "TrendViewController.h"

@interface TrendViewController ()
@property (nonatomic, weak) IBOutlet UIWebView *webview;
@end

@implementation TrendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  NSLog(@"Here is me URL %@", self.trendUrl);
  
  [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.trendUrl]]];
  
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
  return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
  webView.scalesPageToFit = YES;
  webView.contentMode = UIViewContentModeScaleAspectFit;
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
}

@end
