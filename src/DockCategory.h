//
//  DockCategory.h
//  Space Dock
//
//  Created by Rob Tsuk on 8/24/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Categorized;

@interface DockCategory : NSManagedObject

@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSSet *categorized;
@end

@interface DockCategory (CoreDataGeneratedAccessors)

- (void)addCategorizedObject:(Categorized *)value;
- (void)removeCategorizedObject:(Categorized *)value;
- (void)addCategorized:(NSSet *)values;
- (void)removeCategorized:(NSSet *)values;

@end
