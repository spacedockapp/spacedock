//
//  DockTag.h
//  Space Dock
//
//  Created by Rob Tsuk on 8/24/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DockTagged;

@interface DockTag : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *tagged;
@end

@interface DockTag (CoreDataGeneratedAccessors)

- (void)addTaggedObject:(DockTagged *)value;
- (void)removeTaggedObject:(DockTagged *)value;
- (void)addTagged:(NSSet *)values;
- (void)removeTagged:(NSSet *)values;

@end
