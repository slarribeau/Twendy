//
//  TrendViewController.m
//  twendy
//
//  Created by Macadamian on 1/9/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//

#import "TrendViewController.h"

@interface TrendViewController ()

@end

@implementation TrendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  NSLog(@"Here is me URL %@", self.trendUrl);
  [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.trendUrl]]];
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)foo: (NSString*)bar
{
  self.trendUrl = bar;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
