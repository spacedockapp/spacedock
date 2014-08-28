//
//  DockCategory.h
//  Space Dock
//
//  Created by Rob Tsuk on 8/28/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DockCategorized;

@interface DockCategory : NSManagedObject

@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSString * pair;
@property (nonatomic, retain) NSSet *categorized;
@end

@interface DockCategory (CoreDataGeneratedAccessors)

- (void)addCategorizedObject:(DockCategorized *)value;
- (void)removeCategorizedObject:(DockCategorized *)value;
- (void)addCategorized:(NSSet *)values;
- (void)removeCategorized:(NSSet *)values;

@end
