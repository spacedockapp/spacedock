//
//  DockSet.h
//  Space Dock
//
//  Created by Rob Tsuk on 6/25/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DockComponent;

@interface DockSet : NSManagedObject

@property (nonatomic, retain) NSString * externalId;
@property (nonatomic, retain) NSNumber * include;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * productName;
@property (nonatomic, retain) NSDate * releaseDate;
@property (nonatomic, retain) NSString * wave;
@property (nonatomic, retain) NSSet *items;
@end

@interface DockSet (CoreDataGeneratedAccessors)

- (void)addItemsObject:(DockComponent *)value;
- (void)removeItemsObject:(DockComponent *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
