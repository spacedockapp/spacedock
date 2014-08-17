//
//  MDockCategory.h
//  MetaDock
//
//  Created by Rob Tsuk on 8/17/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MDockComponent;

@interface MDockCategory : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *components;
@end

@interface MDockCategory (CoreDataGeneratedAccessors)

- (void)addComponentsObject:(MDockComponent *)value;
- (void)removeComponentsObject:(MDockComponent *)value;
- (void)addComponents:(NSSet *)values;
- (void)removeComponents:(NSSet *)values;

@end
