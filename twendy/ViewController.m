//
//  TrendingListViewController.m
//  twendy
//
//  Created by Macadamian on 1/9/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//

#import "ViewController.h"
#import "TrendViewController.h"
#import "RegionViewController.h"
#import "Region.h"


@interface ViewController ()
//This is an extension not a category.
@property (nonatomic, strong) NSArray *arrPeopleInfo;
@property (nonatomic, strong) NSArray *trendUrlInfo;
@property (nonatomic) NSInteger recordIDToEdit;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) float longtitude;
@property (nonatomic, assign) float lattitude;

@end

@implementation ViewController

static NSInteger  const kLocationHome = 2488042;
static NSString * const kMenuSelectionMark = @"*";
static NSString * const kMenuUnSelectionMark = @" ";

static int const kButtonWidth = 100;


-(IBAction)login:(id)sender {
  [self performSegueWithIdentifier:@"idSegueAuth" sender:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
  [self initGeo];
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

-(void)initGeo
{
  
  self.longtitude = 0;
  self.lattitude = 0;

  // ** Don't forget to add NSLocationWhenInUseUsageDescription in MyApp-Info.plist and give it a string
  
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self;
  // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
  if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
    [self.locationManager requestWhenInUseAuthorization];
  }
  [self.locationManager startUpdatingLocation];
  
  
  float latitude = self.locationManager.location.coordinate.latitude;
  float longitude = self.locationManager.location.coordinate.longitude;
  NSLog(@"long %f lat %f", longitude, latitude);

}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
  if (self.recordIDToEdit > 0) {
    TrendViewController *trendViewController = [segue destinationViewController];
    trendViewController.trendUrl = self.trendUrlInfo[self.recordIDToEdit];
    self.recordIDToEdit = -1;
  } else {
    //RegionViewController *regionViewController = [segue destinationViewController];
    //regionViewController.delegate = self;
  }
}

-(float)getCurrentLongitude
{
  if (self.longtitude == 0) {
    return -122.0419; //Default to cupertiono, CA, USA

  } else {
    return self.longtitude;
  }
}
-(float)getCurrentLatitude
{
  if (self.lattitude == 0) {
    return 37.3175; //Default to cupertiono, CA, USA
  } else {
    return self.lattitude;
  }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
  NSLog(@"%@", [locations lastObject]);
  CLLocation *myLocation = [locations lastObject];
  NSLog(@"lat = %f", myLocation.coordinate.latitude);
  NSLog(@"long = %f", myLocation.coordinate.longitude);
  
  self.longtitude = myLocation.coordinate.longitude;
  self.lattitude = myLocation.coordinate.latitude;
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
-(BOOL)doesString:(NSString *)string containCharacter:(char)character
{
  if ([string rangeOfString:[NSString stringWithFormat:@"%c",character]].location != NSNotFound)
  {
    return YES;
  }
  return NO;
}

-(void)saveMenuSelection:(NSInteger)woeid
{
  NSInteger  selectedConfigRegionWoeid = [[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedConfigRegion"] intValue];

  NSLog(@"selectedConfigRegion before %ld",(long)selectedConfigRegionWoeid);
  
  [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:woeid] forKey:@"selectedConfigRegion"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  selectedConfigRegionWoeid = [[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedConfigRegion"] intValue];
  
  NSLog(@"selectedConfigRegion after %ld",(long)selectedConfigRegionWoeid);
}

-(void)setMenuSelection:(UIButton*)button
{
  NSLog(@"Before set: [%@]", [button currentTitle]);

  [button setTitle: [[button currentTitle] stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:kMenuSelectionMark] forState:UIControlStateNormal];

  NSLog(@"After set: [%@]", [button currentTitle]);
  [self saveMenuSelection:button.tag];
}

-(void)removeMenuSelection
{
  for (id object in [self.scrollMenu subviews])  {
    if ([object isMemberOfClass:[UIButton class]]) {
      UIButton *button = (UIButton*)object;
      NSString *title = [button currentTitle];
      
      if ([title hasPrefix:kMenuSelectionMark] && [title length] > 1) {

      
         NSLog(@"Before remove: [%@]", [button currentTitle]);

        [button setTitle: [title stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:kMenuUnSelectionMark] forState:UIControlStateNormal];

        NSLog(@"after remove: [%@]", [button currentTitle]);
      

        break;
      }
    }
  }
}

-(void)addScrollButton:(int)offset name:(NSString *)name action:(SEL)action tag:(NSInteger)tag
{
  int x = kButtonWidth * offset;
  UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, 0, kButtonWidth, 100)];
  [button setTitle:name forState:UIControlStateNormal];
  
  [button addTarget:self action:action forControlEvents:UIControlEventTouchDown];
  [self.scrollMenu addSubview:button];
  button.tag = tag;
}

- (void)createScrollMenu //TODO -> Leaky!
{
  //Clean up in case this is being called after first time
  for (UIView *view in [self.scrollMenu subviews])
  {
    [view removeFromSuperview];
  }
  
  int x = 0;
  
  [self addScrollButton:x name:[NSString stringWithFormat:@"%@%@",kMenuUnSelectionMark,@"Home" ] action:@selector(getHomeTrendDataButton:) tag:0]; //Tag for home is zero.

  x++;
  
  id tmp = [[[NSUserDefaults standardUserDefaults] objectForKey:@"configRegion"] mutableCopy];
  NSMutableDictionary* configRegionDict;
  if (tmp == nil) {
    configRegionDict = [[NSMutableDictionary alloc]init];
  }else {
    configRegionDict = tmp;
    
    for(id key in configRegionDict) {
      NSInteger woedInt = [[configRegionDict objectForKey:key] intValue];

      [self addScrollButton:x name:[NSString stringWithFormat:@"%@%@",kMenuUnSelectionMark,key] action:@selector(getGenericTrendDataButton:) tag:woedInt];
      x++;
    }
  }

  [self addScrollButton:x name:[NSString stringWithFormat:@"%@%@",kMenuUnSelectionMark, @"Add"] action:@selector(getRegionsDataButton:) tag:-1];
  
  
  x++; //Need an extra increment so that we can scroll to end of last button
  self.scrollMenu.contentSize = CGSizeMake(kButtonWidth*x, self.scrollMenu.frame.size.height);
  self.scrollMenu.backgroundColor = [UIColor redColor];
  
  NSInteger selectedConfigRegionWoeid = [[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedConfigRegion"] intValue];

  //If selectedConfigRegionWoeid is set to zero, either user selected home or he has
  //selected nothing, in either case, set HOME as 'selected'
  //Find the button that matches selectedConfigRegionWoeid and 'select' it
  BOOL foundMatch = NO;
  UIButton *homeButton;
  for (id object in [self.scrollMenu subviews])  {
    if ([object isMemberOfClass:[UIButton class]]) {
      UIButton *button = (UIButton*)object;
      if (button.tag == 0) {
        homeButton = button;
      }
      if (button.tag == selectedConfigRegionWoeid) {
        [self setMenuSelection:button];
        foundMatch = YES;
        break;
      }
    }
  }
  if (foundMatch == NO) {
    //region in menu may have been unselected, set region to home
    [self getHomeTrendDataButton:homeButton];
  }
}


#pragma mark - request data from twitter api
-(IBAction)getGenericTrendDataButton:(id)sender {
  UIButton *button = (UIButton*)sender;
  [self removeMenuSelection];
  [self setMenuSelection:button];
  [self getTrendData:button.tag];
}

-(IBAction)getHomeTrendDataButton:(id)sender{
  UIButton *button = (UIButton*)sender;
  [self removeMenuSelection];
  [self setMenuSelection:button];
  [self getTrendData:kLocationHome];
}


-(void)getTrendData:(NSInteger)location {
  OAConsumer* consumer = [self.delegate getConsumer];
  OAToken* accessToken = [self.delegate getAccessToken];
  
  NSString *debug = [NSString stringWithFormat:@"https://api.twitter.com/1.1/trends/place.json?id=%@", [NSString stringWithFormat:@"%d",location]];
  
  if (accessToken) {
    NSURL* userdatarequestu = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/trends/place.json?id=%@", [NSString stringWithFormat:@"%d",location]]];
    
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


-(IBAction)getClosestRegionDataButton:(id)sender {
  

    OAConsumer* consumer = [self.delegate getConsumer];
    OAToken* accessToken = [self.delegate getAccessToken];
    
    if (accessToken) {
      NSURL* userdatarequestu = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/trends/closest.json?lat=%f&long=%f", [self getCurrentLatitude], [self getCurrentLongitude]]];
      
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
                      didFinishSelector:@selector(didReceiveClosestRegion:data:)
                        didFailSelector:@selector(didFailOAuth:error:)];    } else {
        NSLog(@"ERROR!!");
      }
}


#pragma mark - handle data returned from twitter api
- (void)didReceiveRegion:(OAServiceTicket*)ticket data:(NSData*)data {
  NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  NSLog(@"++++++++++++++++++++++++++++");
  NSLog(@"didReceive Region%@", httpBody);
  
  id tmp = [[[NSUserDefaults standardUserDefaults] objectForKey:@"configRegion"] mutableCopy];
  NSMutableDictionary* configRegionDict;
  if (tmp == nil) {
    configRegionDict = [[NSMutableDictionary alloc]init];
  }else {
    configRegionDict = tmp;
  }

  NSArray *twitterRegions = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers       error:nil];
  
  for (NSDictionary *region in twitterRegions) {
    Region *regionObj = [Region alloc];
    
    regionObj.city = [region objectForKey:@"name"];
    regionObj.country = [region objectForKey:@"country"];
    regionObj.woeid = [[region objectForKey:@"woeid"] intValue];

    NSInteger woeid = [[configRegionDict objectForKey:regionObj.city] intValue];

    if (woeid == regionObj.woeid) {
      regionObj.selected = YES;
    }

    [self.regionArray addObject:regionObj];
  }
  [self performSegueWithIdentifier:@"idSegueRegion" sender:self];
}

- (void)didReceiveRateLimit:(OAServiceTicket*)ticket data:(NSData*)data {
  NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  NSLog(@"++++++++++++++++++++++++++++");
  NSLog(@"didReceive rate limit %@", httpBody);
}

- (void)didReceiveClosestRegion:(OAServiceTicket*)ticket data:(NSData*)data {
  NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  NSLog(@"++++++++++++++++++++++++++++");
  NSLog(@"didReceiveClosestRegion %@", httpBody);
}

- (void)didReceiveuserdata:(OAServiceTicket*)ticket data:(NSData*)data {
  NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  NSLog(@"didReceive user data %@", httpBody);
  
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
