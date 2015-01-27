//
//  RightViewController.h
//  MathMonsters
//
//  Created by Ellen Shapiro on 1/8/13.
//  Copyright (c) 2013 Designated Nerd Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Monster;
//#import "MonsterSelectionDelegate.h"

@interface RightViewController : UIViewController <UISplitViewControllerDelegate/*, MonsterSelectionDelegate*/>

@property (nonatomic, strong) Monster *monster;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic, weak) IBOutlet UIImageView *weaponImageView;
@property (nonatomic, weak) IBOutlet UINavigationItem *navBarItem;
@property (nonatomic, strong) UIPopoverController *popover;
@end
