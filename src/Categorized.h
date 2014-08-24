//
//  Categorized.h
//  Space Dock
//
//  Created by Rob Tsuk on 8/24/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DockTagged.h"

@class DockCategory;

@interface Categorized : DockTagged

@property (nonatomic, retain) NSSet *categories;
@end

@interface Categorized (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(DockCategory *)value;
- (void)removeCategoriesObject:(DockCategory *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

@end
