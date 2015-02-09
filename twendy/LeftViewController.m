//
//  LeftViewController.m
//  twendy
//
//  Created by Macadamian on 1/27/15.
//  Copyright (c) 2015 Larribeau. All rights reserved.
//

//
//  LeftViewController.m
//  MathMonsters
//
//  Created by Ellen Shapiro on 1/8/13.
//  Copyright (c) 2013 Designated Nerd Software. All rights reserved.
//

#import "LeftViewController.h"
#import "Monster.h"
#import "AuthenticationModel.h"

//#import "ViewController.h"
//#import "TrendViewController.h"
//#import "RegionViewController.h"
#import "RegionModel.h"
//#import "Trend.h"
//#import "AuthenticationModel.h"
//#import "TwitterFetch.h"
//#import "LocationModel.h"
#import "Notifications.h"
//#import "RegionModel.h"


@interface LeftViewController ()
@property (nonatomic, strong) NSMutableArray *monsters;
@property (weak, nonatomic) IBOutlet UITableView *tblRegion;

@end

@implementation LeftViewController

-(IBAction)login:(id)sender {
  [self performSegueWithIdentifier:@"idSegueAuth2" sender:self];
}

-(void)regionsWereRetrieved:(NSNotification*)obj
{
  [self.tblRegion reloadData];
}
-(void) viewWillAppear: (BOOL) animated {
  if ([AuthenticationModel isLoggedIn] == YES) {
   //[self.loginButton setTitle:@"Logout"];
    [self.tblRegion reloadData];

  } else {
   //[self.loginButton setTitle:@"Login"];
  }
  
  //if (self.trendDB.count == 0) {
    //[self getTrendData:[LocationModel getWoeid]];
 // } else {
    // Reload the table view.
  //  [self.tblPeople reloadData];
  //  [self createScrollMenu];
 // }
}

-(void)userLoggedOut:(NSNotification*)obj {
  [RegionModel reset];
  //self.trendDB = [[NSMutableArray alloc] init];
  //[self.tblPeople reloadData];
  //[self clearScrollMenu];
}

-(void)menuHasChanged:(NSNotification*)obj {
  //[self createScrollMenu];
}



-(id)initWithCoder:(NSCoder *)aDecoder
{
  if (self = [super initWithCoder:aDecoder]) {
    //Initialize the array of monsters for display.
    _monsters = [NSMutableArray array];
    
    //Create monster objects then add them to the array.
    [_monsters addObject:[Monster newMonsterWithName:@"Cat-Bot" description:@"MEE-OW" iconName:@"meetcatbot.png" weapon:Sword]];
    [_monsters addObject:[Monster newMonsterWithName:@"Dog-Bot" description:@"BOW-WOW" iconName:@"meetdogbot.png" weapon:Blowgun]];
    [_monsters addObject:[Monster newMonsterWithName:@"Explode-Bot" description:@"Tick, tick, BOOM!" iconName:@"meetexplodebot.png" weapon:Smoke]];
    [_monsters addObject:[Monster newMonsterWithName:@"Fire-Bot" description:@"Will Make You Steamed" iconName:@"meetfirebot.png" weapon:NinjaStar]];
    [_monsters addObject:[Monster newMonsterWithName:@"Ice-Bot" description:@"Has A Chilling Effect" iconName:@"meeticebot.png" weapon:Fire]];
    [_monsters addObject:[Monster newMonsterWithName:@"Mini-Tomato-Bot" description:@"Extremely Handsome" iconName:@"meetminitomatobot.png" weapon:NinjaStar]];
  }
  
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.tblRegion.delegate = self;
  self.tblRegion.dataSource = self;
  
  [self.tblRegion reloadData];

  //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
  
  if ([AuthenticationModel isLoggedIn] == NO) {
    [self login:nil];
  } else {
    // Reload the table view.
 // [self.tblRegion reloadData];
    
    //[self createScrollMenu];
  }
  //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuHasChanged:) name:MenuHasChanged object:nil];
  
 // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedOut:) name:LogoutSucceed object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(regionsWereRetrieved:) name:RegionsRetrieved object:nil];

}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  int x = [RegionModel count];
  return [RegionModel count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idRegionCellRecord" forIndexPath:indexPath];
  
  Region *region = [RegionModel get:indexPath.row];
  cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", region.country, region.city];
  
  NSLog(@"table view region = %ld", (long)region.woeid);
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)region.woeid];
  
  
  if (region.selected == YES) {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  } else {
    cell.accessoryType = UITableViewCellAccessoryNone;
  }
  
  
  return cell;
#if 0
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  
  // Configure the cell...
  Monster *monster = _monsters[indexPath.row];
  cell.textLabel.text = monster.name;
  
  return cell;
#endif
}

#pragma mark - Table view delegate

#if 0
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self performSegueWithIdentifier:@"foo" sender:self];

  Monster *selectedMonster = [_monsters objectAtIndex:indexPath.row];
 // if (_delegate) {
 //   [_delegate selectedMonster:selectedMonster];
  //}
}
#endif

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  Region *region = [RegionModel get:indexPath.row];
  
  NSLog(@"region = %ld", (long)region.woeid);
  id tmp = [[[NSUserDefaults standardUserDefaults] objectForKey:@"configRegion"] mutableCopy];
  
  NSMutableDictionary* configRegionDict;
  if (tmp == nil) {
    configRegionDict = [[NSMutableDictionary alloc]init];
  }else {
    configRegionDict = tmp;
  }
  
  NSLog(@"configRegionDict before %@",configRegionDict);
  
  if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
    cell.accessoryType = UITableViewCellAccessoryNone;
    region.selected = NO;
    [configRegionDict removeObjectForKey:region.city];
  } else {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    region.selected = YES;
    [configRegionDict setObject:[NSNumber numberWithInteger:region.woeid] forKey:region.city];
  }
  [[NSUserDefaults standardUserDefaults] setObject:configRegionDict forKey:@"configRegion"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  NSLog(@"configRegionDict after %@",configRegionDict);
  
 // [[NSNotificationCenter defaultCenter] postNotificationName:MenuHasChanged object:nil];
  
}


- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
