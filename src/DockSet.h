//
//  DockSet.h
//  Space Dock
//
//  Created by Rob Tsuk on 4/12/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DockSetItem;

@interface DockSet : NSManagedObject

@property (nonatomic, retain) NSString * externalId;
@property (nonatomic, retain) NSNumber * include;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * productName;
@property (nonatomic, retain) NSString * wave;
@property (nonatomic, retain) NSSet *items;
@end

@interface DockSet (CoreDataGeneratedAccessors)

- (void)addItemsObject:(DockSetItem *)value;
- (void)removeItemsObject:(DockSetItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
