//
//  DockShip.h
//  Space Dock
//
//  Created by Rob Tsuk on 5/16/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DockSetItem.h"

@class DockEquippedShip, DockShipClassDetails;

@interface DockShip : DockSetItem

@property (nonatomic, retain) NSString * ability;
@property (nonatomic, retain) NSNumber * agility;
@property (nonatomic, retain) NSNumber * attack;
@property (nonatomic, retain) NSNumber * battleStations;
@property (nonatomic, retain) NSNumber * borg;
@property (nonatomic, retain) NSNumber * captainLimit;
@property (nonatomic, retain) NSNumber * cloak;
@property (nonatomic, retain) NSNumber * cost;
@property (nonatomic, retain) NSNumber * craftAttack;
@property (nonatomic, retain) NSString * craftBonusArcs;
@property (nonatomic, retain) NSString * craftRange;
@property (nonatomic, retain) NSNumber * crew;
@property (nonatomic, retain) NSNumber * evasiveManeuvers;
@property (nonatomic, retain) NSString * externalId;
@property (nonatomic, retain) NSString * faction;
@property (nonatomic, retain) NSNumber * has360Arc;
@property (nonatomic, retain) NSNumber * hull;
@property (nonatomic, retain) NSNumber * isCraft;
@property (nonatomic, retain) NSNumber * maxCarry;
@property (nonatomic, retain) NSNumber * minCarry;
@property (nonatomic, retain) NSNumber * pivot;
@property (nonatomic, retain) NSNumber * regenerate;
@property (nonatomic, retain) NSNumber * scan;
@property (nonatomic, retain) NSNumber * sensorEcho;
@property (nonatomic, retain) NSNumber * shield;
@property (nonatomic, retain) NSString * shipBonusArcs;
@property (nonatomic, retain) NSString * shipClass;
@property (nonatomic, retain) NSString * shipRange;
@property (nonatomic, retain) NSNumber * targetLock;
@property (nonatomic, retain) NSNumber * tech;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * unique;
@property (nonatomic, retain) NSNumber * weapon;
@property (nonatomic, retain) NSNumber * barrelRoll;
@property (nonatomic, retain) NSNumber * spin;
@property (nonatomic, retain) NSNumber * afterburner;
@property (nonatomic, retain) NSSet *equippedShips;
@property (nonatomic, retain) DockShipClassDetails *shipClassDetails;
@end

@interface DockShip (CoreDataGeneratedAccessors)

- (void)addEquippedShipsObject:(DockEquippedShip *)value;
- (void)removeEquippedShipsObject:(DockEquippedShip *)value;
- (void)addEquippedShips:(NSSet *)values;
- (void)removeEquippedShips:(NSSet *)values;

@end
