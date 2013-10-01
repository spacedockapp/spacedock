//
//  DockEquippedShip.h
//  Space Dock
//
//  Created by Rob Tsuk on 9/28/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@class DockEquippedUpgrade, DockShip, DockSquad;

@interface DockEquippedShip : NSManagedObject

@property (nonatomic, retain) DockShip* ship;
@property (nonatomic, retain) DockSquad* squad;
@property (nonatomic, retain) NSSet* upgrades;
@end

@interface DockEquippedShip (CoreDataGeneratedAccessors)

-(void)addUpgradesObject:(DockEquippedUpgrade*)value;
-(void)removeUpgradesObject:(DockEquippedUpgrade*)value;
-(void)addUpgrades:(NSSet*)values;
-(void)removeUpgrades:(NSSet*)values;

@end
