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
static NSString * const kMenuSelectionMark = @"*";
static NSString * const kMenuUnSelectionMark = @" ";

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
-(BOOL)doesString:(NSString *)string containCharacter:(char)character
{
  if ([string rangeOfString:[NSString stringWithFormat:@"%c",character]].location != NSNotFound)
  {
    return YES;
  }
  return NO;
}

-(void)saveMenuSelection:(UIButton *)button
{
#if 0

  NSString * selectedConfigRegionString = [[NSUserDefaults standardUserDefaults] valueForKey:@"selectedConfigRegion"];

  NSLog(@"configRegionDict before %@",configRegionDict);
  
  if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
    cell.accessoryType = UITableViewCellAccessoryNone;
    region.selected = NO;
    [configRegionDict removeObjectForKey:region.city];
  } else {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    region.selected = YES;
    [configRegionDict setObject:region.woeid forKey:region.city];
  }
  [[NSUserDefaults standardUserDefaults] setValue:configRegionDict forKey:@"selectedConfigRegion"];
  [[NSUserDefaults standardUserDefaults] synchronize];
#endif

}

-(void)setMenuSelection:(UIButton*)button
{
  //[button setTitle:[NSString stringWithFormat:@"%@%@", kMenuSelectionMark, [button currentTitle]] forState:UIControlStateNormal];
  NSLog(@"Before set: [%@]", [button currentTitle]);

  [button setTitle: [[button currentTitle] stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:kMenuSelectionMark] forState:UIControlStateNormal];

  NSLog(@"After set: [%@]", [button currentTitle]);

  //[button setTitle:[NSString stringWithFormat:@"%@%@", kMenuSelectionMark, [button currentTitle]] forState:UIControlStateNormal];

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
  
  [self addScrollButton:x name:[NSString stringWithFormat:@"%@%@",kMenuSelectionMark,@"Home" ] action:@selector(getHomeTrendDataButton:) tag:0];

  x++;
  
  id tmp = [[[NSUserDefaults standardUserDefaults] valueForKey:@"configRegion"] mutableCopy];
  NSMutableDictionary* configRegionDict;
  if (tmp == nil) {
    configRegionDict = [[NSMutableDictionary alloc]init];
  }else {
    configRegionDict = tmp;
    
    for(id key in configRegionDict) {
      id value = [configRegionDict objectForKey:key];
      
           NSString *woeidString = (NSString *)value;
            NSInteger woedInt = [woeidString intValue];
     // +      NSInteger woedInt = (NSInteger *)value;

      [self addScrollButton:x name:[NSString stringWithFormat:@"%@%@",kMenuUnSelectionMark,key] action:@selector(getGenericTrendDataButton:) tag:woedInt];
      x++;
    }
  }

  [self addScrollButton:x name:[NSString stringWithFormat:@"%@%@",kMenuUnSelectionMark, @"Add"] action:@selector(getRegionsDataButton:) tag:0];
  
  
  x++; //Need an extra increment so that we can scroll to end of last button
  self.scrollMenu.contentSize = CGSizeMake(kButtonWidth*x, self.scrollMenu.frame.size.height);
  self.scrollMenu.backgroundColor = [UIColor redColor];
  
#if 0
  NSString * selectedConfigRegionString = [[NSUserDefaults standardUserDefaults] valueForKey:@"selectedConfigRegion"];

  for (id object in [self.scrollMenu subviews])  {
    if ([object isMemberOfClass:[UIButton class]]) {
      UIButton *button = (UIButton*)object;
      NSString *title = [button currentTitle];
      if ([title isEqualToString:@"Home"]) {
        if (selectedConfigRegionString == nil) {
          [self setMenuSelection:button];
          break;
        }
      } else {
        if ([title isEqualToString:selectedConfigRegionString]) {
          [self setMenuSelection:button];
          break;
        }
      }
    }
  }
#endif
}


#pragma mark - request data from twitter api
-(IBAction)getGenericTrendDataButton:(id)sender {
  UIButton *button = (UIButton*)sender;
  [self removeMenuSelection];
  [self setMenuSelection:button];
  [self getTrendData:[NSString stringWithFormat:@"%d", button.tag]];
}

-(IBAction)getHomeTrendDataButton:(id)sender{
  [self removeMenuSelection];
  [self setMenuSelection:(UIButton*)sender];
  [self getTrendData:kLocationHome];
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
  
  id tmp = [[[NSUserDefaults standardUserDefaults] valueForKey:@"configRegion"] mutableCopy];
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
    
    regionObj.woeid = [NSString stringWithFormat:@"%d",[[region objectForKey:@"woeid"] intValue]];
    regionObj.country = [region objectForKey:@"country"];
    
    id value = [configRegionDict objectForKey:regionObj.city];
    NSString *userDefaultWoeid = (NSString *)value;
    
    if ([userDefaultWoeid isEqualToString:regionObj.woeid]) {
      regionObj.selected = YES;
    }

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
