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

@class DockComponent;

@interface DockComponent : DockCategorized

@property (nonatomic, retain) NSString * additionalFaction;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * externalId;
@property (nonatomic, retain) NSSet *sets;
@end

@interface DockComponent (CoreDataGeneratedAccessors)

- (void)addSetsObject:(DockComponent *)value;
- (void)removeSetsObject:(DockComponent *)value;
- (void)addSets:(NSSet *)values;
- (void)removeSets:(NSSet *)values;

@end
