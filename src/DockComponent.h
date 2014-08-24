//
//  DockComponent.h
//  Space Dock
//
//  Created by Rob Tsuk on 8/24/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DockCategorized.h"

@class DockSet;

@interface DockComponent : DockCategorized

@property (nonatomic, retain) NSString * externalId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * factionSortValue;
@property (nonatomic, retain) NSSet *sets;
@end

@interface DockComponent (CoreDataGeneratedAccessors)

- (void)addSetsObject:(DockSet *)value;
- (void)removeSetsObject:(DockSet *)value;
- (void)addSets:(NSSet *)values;
- (void)removeSets:(NSSet *)values;

@end
