//
//  DockSet.h
//  Space Dock
//
//  Created by Rob Tsuk on 12/18/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DockSetItem;

@interface DockSet : NSManagedObject

@property (nonatomic, retain) NSString * externalId;
@property (nonatomic, retain) NSNumber * include;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * productName;
@property (nonatomic, retain) NSSet *items;
@end

@interface DockSet (CoreDataGeneratedAccessors)

- (void)addItemsObject:(DockSetItem *)value;
- (void)removeItemsObject:(DockSetItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
