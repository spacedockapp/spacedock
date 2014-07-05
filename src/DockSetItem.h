//
//  DockSetItem.h
//  Space Dock
//
//  Created by Rob Tsuk on 7/5/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DockSet;

@interface DockSetItem : NSManagedObject

@property (nonatomic, retain) NSString * additionalFaction;
@property (nonatomic, retain) NSSet *sets;
@end

@interface DockSetItem (CoreDataGeneratedAccessors)

- (void)addSetsObject:(DockSet *)value;
- (void)removeSetsObject:(DockSet *)value;
- (void)addSets:(NSSet *)values;
- (void)removeSets:(NSSet *)values;

@end
