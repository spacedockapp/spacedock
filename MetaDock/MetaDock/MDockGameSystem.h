//
//  MDockGameSystem.h
//  MetaDock
//
//  Created by Rob Tsuk on 8/14/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MDockGameSystem : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * systemId;
@property (nonatomic, retain) NSSet *components;
@end

@interface MDockGameSystem (CoreDataGeneratedAccessors)

- (void)addComponentsObject:(NSManagedObject *)value;
- (void)removeComponentsObject:(NSManagedObject *)value;
- (void)addComponents:(NSSet *)values;
- (void)removeComponents:(NSSet *)values;

@end
