//
//  DockUpgrade.h
//  Space Dock
//
//  Created by Rob Tsuk on 12/18/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DockSetItem.h"

@class DockEquippedUpgrade;

@interface DockUpgrade : DockSetItem

@property (nonatomic, retain) NSString * ability;
@property (nonatomic, retain) NSNumber * cost;
@property (nonatomic, retain) NSString * externalId;
@property (nonatomic, retain) NSString * faction;
@property (nonatomic, retain) NSNumber * placeholder;
@property (nonatomic, retain) NSString * special;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * unique;
@property (nonatomic, retain) NSString * upType;
@property (nonatomic, retain) NSSet *equippedUpgrades;
@end

@interface DockUpgrade (CoreDataGeneratedAccessors)

- (void)addEquippedUpgradesObject:(DockEquippedUpgrade *)value;
- (void)removeEquippedUpgradesObject:(DockEquippedUpgrade *)value;
- (void)addEquippedUpgrades:(NSSet *)values;
- (void)removeEquippedUpgrades:(NSSet *)values;

@end
