//
//  TrendingListViewController.m
//  twendy
//
//  Created by Macadamian on 1/9/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//

#import "TrendingListViewController.h"
#import "TrendViewController.h"

@interface TrendingListViewController ()
@property (nonatomic, strong) NSArray *arrPeopleInfo;
@property (nonatomic, strong) NSArray *trendUrlInfo;
@property (nonatomic) NSInteger recordIDToEdit;

@end

@implementation TrendingListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  self.tblPeople.delegate = self;
  self.tblPeople.dataSource = self;

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

  [NSTimer scheduledTimerWithTimeInterval:(60.0 * 60.0)target:self
                                  selector:@selector(getTrendDataAndNotify) userInfo:nil repeats:YES];
  

  

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
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
 TrendViewController *trendViewController = [segue destinationViewController];
  trendViewController.trendUrl = self.trendUrlInfo[self.recordIDToEdit];
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

-(IBAction)getTrendDataButton:(id)sender {
  [self getTrendData];
}

-(void)getTrendDataAndNotify
{
  //[self getTrendData];
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
-(void)getTrendData {
   OAConsumer* consumer = [self.delegate getConsumer];
   OAToken* accessToken = [self.delegate getAccessToken];

  if (accessToken) {
    // NSURL* userdatarequestu = [NSURL URLWithString:@"https://api.twitter.com/1.1/account/verify_credentials.json"];
    
    NSURL* userdatarequestu = [NSURL URLWithString:@"https://api.twitter.com/1.1/trends/place.json?id=2488042"];
    
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

@end
