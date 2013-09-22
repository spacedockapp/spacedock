//
//  DockEquippedShip.h
//  Space Dock
//
//  Created by Rob Tsuk on 9/21/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DockShip, DockUpgrade;

@interface DockEquippedShip : NSManagedObject

@property (nonatomic, retain) DockShip *ship;
@property (nonatomic, retain) NSSet *upgrades;
@end

@interface DockEquippedShip (CoreDataGeneratedAccessors)

- (void)addUpgradesObject:(DockUpgrade *)value;
- (void)removeUpgradesObject:(DockUpgrade *)value;
- (void)addUpgrades:(NSSet *)values;
- (void)removeUpgrades:(NSSet *)values;

@end
