//
//  TrendViewController.h
//  twendy
//
//  Created by Macadamian on 1/9/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrendViewController : UIViewController
//{
  //IBOutlet UIWebView *webview;
  //NSString* trendUrl; what is an ivar?
//http://stackoverflow.com/questions/7057934/property-vs-instance-variable

//}
@property (retain, nonatomic) NSString *trendUrl;
@property (nonatomic, weak) IBOutlet UIWebView *webview;
@end

