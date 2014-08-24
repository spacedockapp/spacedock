//
//  DockFlagship.h
//  Space Dock
//
//  Created by Rob Tsuk on 8/24/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DockComponent.h"

@class DockEquippedShip;

@interface DockFlagship : DockComponent

@property (nonatomic, retain) NSString * ability;
@property (nonatomic, retain) NSNumber * agility;
@property (nonatomic, retain) NSNumber * attack;
@property (nonatomic, retain) NSNumber * battleStations;
@property (nonatomic, retain) NSNumber * cloak;
@property (nonatomic, retain) NSNumber * cost;
@property (nonatomic, retain) NSNumber * crew;
@property (nonatomic, retain) NSNumber * evasiveManeuvers;
@property (nonatomic, retain) NSNumber * hull;
@property (nonatomic, retain) NSNumber * scan;
@property (nonatomic, retain) NSNumber * sensorEcho;
@property (nonatomic, retain) NSNumber * shield;
@property (nonatomic, retain) NSNumber * talent;
@property (nonatomic, retain) NSNumber * targetLock;
@property (nonatomic, retain) NSNumber * tech;
@property (nonatomic, retain) NSNumber * weapon;
@property (nonatomic, retain) NSSet *ships;
@end

@interface DockFlagship (CoreDataGeneratedAccessors)

- (void)addShipsObject:(DockEquippedShip *)value;
- (void)removeShipsObject:(DockEquippedShip *)value;
- (void)addShips:(NSSet *)values;
- (void)removeShips:(NSSet *)values;

@end
