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
  
  self.tblPeople.delegate = self;
  self.tblPeople.dataSource = self;

  self.recordIDToEdit = -1;
  self.arrPeopleInfo = [self.delegate getTrendArray];
  self.trendUrlInfo = [self.delegate getUrlArray];
  self.regionArray = [[NSMutableArray alloc] init];

  // Reload the table view.
  [self.tblPeople reloadData];

  [self createScrollMenu];
  
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

#pragma mark - RegionViewControllerDelegate
-(NSArray*)getRegionArray{
  return self.regionArray;
}

-(void)menuHasChanged {
  [self createScrollMenu];
}

#pragma mark - UITableView Delegates
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
  return self.arrPeopleInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCellRecord" forIndexPath:indexPath];
  
  cell.textLabel.text = self.arrPeopleInfo[indexPath.row];
  //cell.detailTextLabel.text = @"text";
  return cell;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
  // Get the record ID of the selected name and set it to the recordIDToEdit property.
  self.recordIDToEdit = indexPath.row;
  
  // Perform the segue.
  [self performSegueWithIdentifier:@"idSegueTrend" sender:self];
  
  self.recordIDToEdit = -1; //This will be checked later in prepareSeque method
}

#pragma - mark button management
-(void)addScrollButton:(int)offset name:(NSString *)name action:(SEL)action
{
  int x = kButtonWidth * offset;
  UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, 0, kButtonWidth, 100)];
  [button setTitle:name forState:UIControlStateNormal];
  [button setTitle:[name uppercaseString] forState:UIControlStateHighlighted];
  
  [button addTarget:self action:action forControlEvents:UIControlEventTouchDown];
  [self.scrollMenu addSubview:button];
}

- (void)createScrollMenu //TODO -> Leaky!
{
  //Clean up in case this is being called after first time
  for (UIView *view in [self.scrollMenu subviews])
  {
    [view removeFromSuperview];
  }
  
  int x = 0;
  [self addScrollButton:x name:@"Home" action:@selector(getHomeTrendDataButton:)];
  x++;
  
  for (Region *region in self.regionArray) {
    if (region.selected == YES) {
      [self addScrollButton:x name:region.city action:@selector(getGenericTrendDataButton:)];
      x++;
    }
  }
  [self addScrollButton:x name:@"World" action:@selector(getWorldTrendDataButton:)];
  x++;
  [self addScrollButton:x name:@"Add" action:@selector(getRegionsDataButton:)];
  
  
  x++; //Need an extra increment so that we can scroll to end of last button
  self.scrollMenu.contentSize = CGSizeMake(kButtonWidth*x, self.scrollMenu.frame.size.height);
  self.scrollMenu.backgroundColor = [UIColor redColor];
}


#pragma mark - request data from twitter api
-(IBAction)getGenericTrendDataButton:(id)sender {
  NSString *title = [(UIButton *)sender currentTitle];
  
  for (Region *region in self.regionArray) {
    if ([region.city isEqualToString:title]) {
      [self getTrendData:region.woeid];
      break;
    }
  }
}

-(IBAction)getHomeTrendDataButton:(id)sender{
  for (id object in [self.scrollMenu subviews])  {
    if ([object isMemberOfClass:[UIButton class]]) {
      UIButton *button = (UIButton*)object;
      
      [button setTitle:[NSString stringWithFormat:@"%@%@", @"*", [button currentTitle]] forState:UIControlStateNormal];
    }
  }
  [self getTrendData:kLocationHome];
}

-(IBAction)getWorldTrendDataButton:(id)sender{
  [self getTrendData:kLocationWorld];
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

-(IBAction)getRegionsDataButton:(id)sender {
  
  
  if (self.regionArray.count > 0) {
    //Only fetch the region data once
    [self performSegueWithIdentifier:@"idSegueRegion" sender:self];
    NSLog(@"We are back");
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

#pragma mark - handle data returned from twitter api
- (void)didReceiveRegion:(OAServiceTicket*)ticket data:(NSData*)data {
  NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
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
  [self performSegueWithIdentifier:@"idSegueRegion" sender:self];
}

- (void)didReceiveRateLimit:(OAServiceTicket*)ticket data:(NSData*)data {
  NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  NSLog(@"++++++++++++++++++++++++++++");
  NSLog(@"didReceive %@", httpBody);
}

- (void)didReceiveuserdata:(OAServiceTicket*)ticket data:(NSData*)data {
  NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  NSLog(@"didReceive %@", httpBody);
  
  NSArray *twitterTrends   = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers       error:nil];
  NSArray *trends  = [[twitterTrends objectAtIndex:0] objectForKey:@"trends"];
  
  self.arrPeopleInfo = [self.delegate getTrendArray];
  self.trendUrlInfo = [self.delegate getUrlArray];
  // Reload the table view.
  //[self.tblPeople reloadData];
  
  //FIX ME - this should be a single array of objects, not two arrays
  NSMutableArray *trendNameArray = [[NSMutableArray alloc] init];
  NSMutableArray *trendUrlArray = [[NSMutableArray alloc] init];
  
  
  for (NSDictionary *trend in trends) {
    NSLog(@"trend = %@", trend);
    
    NSString *names = [trend objectForKey:@"name"];
    
    NSString *urls = [trend objectForKey:@"url"];
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
