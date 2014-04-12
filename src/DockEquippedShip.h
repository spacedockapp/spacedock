//
//  DockEquippedShip.h
//  Space Dock
//
//  Created by Rob Tsuk on 4/12/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DockEquippedUpgrade, DockFlagship, DockShip, DockSquad;

@interface DockEquippedShip : NSManagedObject

@property (nonatomic, retain) DockFlagship *flagship;
@property (nonatomic, retain) DockShip *ship;
@property (nonatomic, retain) DockSquad *squad;
@property (nonatomic, retain) NSSet *upgrades;
@end

@interface DockEquippedShip (CoreDataGeneratedAccessors)

- (void)addUpgradesObject:(DockEquippedUpgrade *)value;
- (void)removeUpgradesObject:(DockEquippedUpgrade *)value;
- (void)addUpgrades:(NSSet *)values;
- (void)removeUpgrades:(NSSet *)values;

@end
