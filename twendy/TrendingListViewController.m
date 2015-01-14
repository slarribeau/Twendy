//
//  TrendingListViewController.m
//  twendy
//
//  Created by Macadamian on 1/9/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//

#import "TrendingListViewController.h"
#import "TrendViewController.h"
#import "RegionViewController.h"
#import "Region.h"

@interface TrendingListViewController ()
@property (nonatomic, strong) NSArray *arrPeopleInfo;
@property (nonatomic, strong) NSArray *trendUrlInfo;
@property (nonatomic) NSInteger recordIDToEdit;

@end

@implementation TrendingListViewController
static NSString * const kLocationHome = @"2488042";
static NSString * const kLocationSF = @"2487956";
static NSString * const kLocationWorld = @"1";
static NSString * const kLocationNY = @"2459115";
static NSString * const kLocationLA = @"2442047";
static int const kButtonWidth = 100;



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  self.tblPeople.delegate = self;
  self.tblPeople.dataSource = self;

  self.recordIDToEdit = -1;
  // Get the results.
  if (self.arrPeopleInfo != nil) {
    self.arrPeopleInfo = nil;
  }
  
  self.arrPeopleInfo = [self.delegate getTrendArray];
  
  // Get the results.
  if (self.trendUrlInfo != nil) {
    self.trendUrlInfo = nil;
  }
  
  self.trendUrlInfo = [self.delegate getUrlArray];


  // Reload the table view.
  [self.tblPeople reloadData];

  [NSTimer scheduledTimerWithTimeInterval:(60.0 * 59.0)target:self
                                  selector:@selector(getTrendDataAndNotify) userInfo:nil repeats:YES];
  

  [NSTimer scheduledTimerWithTimeInterval:(60.0 * 15.0)target:self
                                 selector:@selector(getTrendDeltaAndNotify) userInfo:nil repeats:YES];
  [self createScrollMenu];
  
  self.regionArray = [[NSMutableArray alloc] init];


}

-(void)addScrollButton:(int)offset name:(NSString *)name action:(SEL)action
{
  int x = kButtonWidth * offset;
  UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, 0, kButtonWidth, 100)];
  [button setTitle:name forState:UIControlStateNormal];
  [button addTarget:self action:action forControlEvents:UIControlEventTouchDown];
  [self.scrollMenu addSubview:button];
}
- (void)createScrollMenu
{
  int x = 0;
  [self addScrollButton:x name:@"home" action:@selector(getHomeTrendDataButton:)];
  x++;
  [self addScrollButton:x name:@"San Francisco" action:@selector(getSFTrendDataButton:)];
  x++;
  [self addScrollButton:x name:@"LA" action:@selector(getLATrendDataButton:)];
  x++;
  [self addScrollButton:x name:@"New York" action:@selector(getNYTrendDataButton:)];
  x++;
  [self addScrollButton:x name:@"World" action:@selector(getWorldTrendDataButton:)];
  x++;
  [self addScrollButton:x name:@"Add" action:@selector(getRegions:)];


  x++; //Need an extra increment so that we can scroll to end of last button
  self.scrollMenu.contentSize = CGSizeMake(kButtonWidth*x, self.scrollMenu.frame.size.height);
  self.scrollMenu.backgroundColor = [UIColor redColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
  NSLog(@"array=%@ count=%lu", self.arrPeopleInfo, (unsigned long)self.arrPeopleInfo.count);
 // return 10;
  return self.arrPeopleInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCellRecord" forIndexPath:indexPath];
  
  cell.textLabel.text = self.arrPeopleInfo[indexPath.row];
  
  cell.detailTextLabel.text = @"text";
  return cell;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
  // Get the record ID of the selected name and set it to the recordIDToEdit property.
  self.recordIDToEdit = indexPath.row;
  
  // Perform the segue.
  [self performSegueWithIdentifier:@"idSegueTrend" sender:self];
  
  self.recordIDToEdit = -1; //why? TODO

}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
  if (self.recordIDToEdit > 0) {
    TrendViewController *trendViewController = [segue destinationViewController];
    trendViewController.trendUrl = self.trendUrlInfo[self.recordIDToEdit];
    self.recordIDToEdit = -1;
  } else {
    RegionViewController *regionViewController = [segue destinationViewController];
    regionViewController.delegate = self;
  }
}

-(IBAction)getRateLimit:(id)sender {
  OAConsumer* consumer = [self.delegate getConsumer];
  OAToken* accessToken = [self.delegate getAccessToken];
  
  if (accessToken) {
    NSURL* userdatarequestu = [NSURL URLWithString:@"https://api.twitter.com/1.1/application/rate_limit_status.json"];
    
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
                    didFinishSelector:@selector(didReceiveRateLimit:data:)
                      didFailSelector:@selector(didFailOAuth:error:)];    } else {
      NSLog(@"ERROR!!");
    }
}

-(IBAction)getRegions:(id)sender {
  
  
  if (self.regionArray.count > 0) {
    //Only fetch the region data once
    [self performSegueWithIdentifier:@"idSegueRegion" sender:self];
  } else {
  OAConsumer* consumer = [self.delegate getConsumer];
  OAToken* accessToken = [self.delegate getAccessToken];
  
  if (accessToken) {
    NSURL* userdatarequestu = [NSURL URLWithString:@"https://api.twitter.com/1.1/trends/available.json"];
    
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
                    didFinishSelector:@selector(didReceiveRegion:data:)
                      didFailSelector:@selector(didFailOAuth:error:)];    } else {
      NSLog(@"ERROR!!");
    }
  }
}


-(IBAction)getTrendDataButton:(id)sender {
  [self getTrendData:kLocationHome];
}

-(void)getTrendDeltaAndNotify
{
  [self getTrendDelta:kLocationHome];
}


-(IBAction)getHomeTrendDataButton:(id)sender{
  [self getTrendData:kLocationHome];
}

-(IBAction)getSFTrendDataButton:(id)sender{
    [self getTrendData:kLocationSF];
  }

-(IBAction)getWorldTrendDataButton:(id)sender{
      [self getTrendData:kLocationWorld];
    }

-(IBAction)getNYTrendDataButton:(id)sender{
        [self getTrendData:kLocationNY];
      }


-(IBAction)getLATrendDataButton:(id)sender{
  [self getTrendData:kLocationLA];
}



-(void)getTrendDataAndNotify
{
  [self getTrendData:kLocationHome];
  [self summaryNotification];
}

-(NSString *)buildTrendMsg
{
  NSString *retString = @"";
  
  for (NSString *trend in self.arrPeopleInfo) {
    NSInteger i= 0;
    retString = [NSString stringWithFormat:@"%@%@%s", retString, trend,  (i++ % 3) ? "\n":"  "];

  }
  return retString;
}
-(void)summaryNotification
{
  UILocalNotification* local = [[UILocalNotification alloc]init];
  if (local) {
    local.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    local.alertBody = @"Hey\n this\nis\n my\n first\n local\n notification\n!!!\n";
    local.alertBody = [self buildTrendMsg];

    
    //local.alertLaunchImage = @"sachin.png";
    //local.soundName = @"sachin.mp3";
    //local.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:local];
  }
}
-(void)getTrendData:(NSString*)location {
  OAConsumer* consumer = [self.delegate getConsumer];
  OAToken* accessToken = [self.delegate getAccessToken];
  
  if (accessToken) {
    NSURL* userdatarequestu = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/trends/place.json?id=%@", location]];
    
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

-(void)getTrendDelta:(NSString*)location {
  OAConsumer* consumer = [self.delegate getConsumer];
  OAToken* accessToken = [self.delegate getAccessToken];
  
  if (accessToken) {
    NSURL* userdatarequestu = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/trends/place.json?id=%@", location]];
                               
                               
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
                    didFinishSelector:@selector(didReceiveuserdelta:data:)
                      didFailSelector:@selector(didFailOAuth:error:)];    } else {
      NSLog(@"ERROR!!");
    }
  
  
  
}
- (void)didReceiveRegion:(OAServiceTicket*)ticket data:(NSData*)data {
  NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  
  NSLog(@"++++++++++++++++++++++++++++");
  NSLog(@"++++++++++++++++++++++++++++");
  NSLog(@"++++++++++++++++++++++++++++");
  
  NSLog(@"didReceive Region%@", httpBody);
  
  NSArray *twitterRegions = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers       error:nil];

  
  
  for (NSDictionary *region in twitterRegions) {
    Region *regionObj = [Region alloc];
    
    regionObj.city = [region objectForKey:@"name"];

    regionObj.woeid = [NSString stringWithFormat:@"%d",[[region objectForKey:@"woeid"] intValue]];
    regionObj.country = [region objectForKey:@"country"];
    
    [self.regionArray addObject:regionObj];
  }
  NSLog(@"done");
  
  [self performSegueWithIdentifier:@"idSegueRegion" sender:self];
                      return;

}



- (void)didReceiveRateLimit:(OAServiceTicket*)ticket data:(NSData*)data {
  NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  
  NSLog(@"++++++++++++++++++++++++++++");
  NSLog(@"++++++++++++++++++++++++++++");
  NSLog(@"++++++++++++++++++++++++++++");
  
  NSLog(@"didReceive %@", httpBody);
}

- (void)didReceiveuserdata:(OAServiceTicket*)ticket data:(NSData*)data {
  NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  
  NSLog(@"++++++++++++++++++++++++++++");
  NSLog(@"++++++++++++++++++++++++++++");
  NSLog(@"++++++++++++++++++++++++++++");

  NSLog(@"didReceive %@", httpBody);
  
  NSArray *twitterTrends   = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers       error:nil];
  NSArray *trends  = [[twitterTrends objectAtIndex:0] objectForKey:@"trends"];
  
  // Get the results.
  if (self.arrPeopleInfo != nil) {
    self.arrPeopleInfo = nil;
  }
  
  
  // Get the results.
  if (self.trendUrlInfo != nil) {
    self.trendUrlInfo = nil;
  }
  
  self.arrPeopleInfo = [self.delegate getTrendArray];
  self.trendUrlInfo = [self.delegate getUrlArray];
  // Reload the table view.
  [self.tblPeople reloadData];
  


  NSMutableArray *trendNameArray = [[NSMutableArray alloc] init];
  NSMutableArray *trendUrlArray = [[NSMutableArray alloc] init];
  
  
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
  
  
  self.arrPeopleInfo = trendNameArray;
  self.trendUrlInfo = trendUrlArray;
  // Reload the table view.
  [self.tblPeople reloadData];

}

- (void)didReceiveuserdelta:(OAServiceTicket*)ticket data:(NSData*)data {
  NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  
  NSLog(@"++++++++++++++++++++++++++++");
  NSLog(@"++++++++++++++++++++++++++++");
  NSLog(@"++++++++++++++++++++++++++++");
  
  NSLog(@"didReceive %@", httpBody);
  
  NSArray *twitterTrends   = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers       error:nil];
  NSArray *trends  = [[twitterTrends objectAtIndex:0] objectForKey:@"trends"];
  
  NSMutableArray *trendNameArray = [[NSMutableArray alloc] init];
  
  for (NSDictionary *trend in trends) {
    NSString *names = [trend objectForKey:@"name"];
    [trendNameArray addObject:names];
  }
  NSLog(@"Before me an trendNameArray:%lu", (unsigned long)trendNameArray.count);
  
  
  [trendNameArray removeObjectsInArray: self.arrPeopleInfo];
  NSLog(@"After me an trendNameArray:%lu", (unsigned long)trendNameArray.count);

  
  NSString *retString = @"";
  
  for (NSString *trend in trendNameArray) {
    retString = [NSString stringWithFormat:@"%@++%@%s", retString, trend, "\n"];
  }
  UILocalNotification* local = [[UILocalNotification alloc]init];
  if (local) {
    local.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    local.alertBody = @"Hey\n this\nis\n my\n first\n local\n notification\n!!!\n";
    local.alertBody = retString;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:local];
  }
}

-(NSArray*)getRegionArray{
  return self.regionArray;
}

@end
