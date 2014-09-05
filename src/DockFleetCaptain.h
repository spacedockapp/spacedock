//
//  DockFleetCaptain.h
//  Space Dock
//
//  Created by Rob Tsuk on 9/4/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DockUpgrade.h"


@interface DockFleetCaptain : DockUpgrade

@property (nonatomic, retain) NSNumber * captainSkillBonus;
@property (nonatomic, retain) NSNumber * crewAdd;
@property (nonatomic, retain) NSNumber * talentAdd;
@property (nonatomic, retain) NSNumber * techAdd;
@property (nonatomic, retain) NSNumber * weaponAdd;

@end
