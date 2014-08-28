//
//  DockAdmiral.h
//  Space Dock
//
//  Created by Rob Tsuk on 8/28/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DockUpgrade.h"


@interface DockAdmiral : DockUpgrade

@property (nonatomic, retain) NSString * admiralAbility;
@property (nonatomic, retain) NSNumber * admiralCost;
@property (nonatomic, retain) NSNumber * admiralTalent;
@property (nonatomic, retain) NSNumber * skillModifier;

@end
