//
//  DockEquippedUpgrade.h
//  Space Dock
//
//  Created by Rob Tsuk on 9/4/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DockEquippedShip, DockUpgrade;

@interface DockEquippedUpgrade : NSManagedObject

@property (nonatomic, retain) NSNumber * overridden;
@property (nonatomic, retain) NSNumber * overriddenCost;
@property (nonatomic, retain) DockEquippedShip *equippedShip;
@property (nonatomic, retain) DockUpgrade *upgrade;

@end
