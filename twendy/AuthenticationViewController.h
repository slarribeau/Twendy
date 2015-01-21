//
//  ViewController.h
//  twendy
//
//  Created by Macadamian on 1/9/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//

//  Created by Ammad iOS on 06/12/2013.
//  Copyright (c) 2013 Techno. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuthConsumer.h"
#import "ViewController.h"

@interface AuthenticationViewController : UIViewController<UIWebViewDelegate, TrendingListViewControllerDelegate>
{
  IBOutlet UIWebView *webview;
  OAConsumer* consumer;
  OAToken* requestToken;
  OAToken* accessToken;
  NSMutableArray *trendNameArray;
  NSMutableArray *trendUrlArray;

  
}
@property (nonatomic,strong) OAToken* accessToken;
@property (nonatomic, retain) IBOutlet UIWebView *webview;
@property (nonatomic, retain) NSString *isLogin;
@property (nonatomic, strong) NSMutableArray *trendNameArray;
@property (nonatomic, strong) NSMutableArray *trendUrlArray;
@end
