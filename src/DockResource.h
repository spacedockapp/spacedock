//
//  DockResource.h
//  Space Dock
//
//  Created by Rob Tsuk on 12/18/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DockSetItem.h"

@class DockSquad;

@interface DockResource : DockSetItem

@property (nonatomic, retain) NSString * ability;
@property (nonatomic, retain) NSNumber * cost;
@property (nonatomic, retain) NSString * externalId;
@property (nonatomic, retain) NSString * special;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * unique;
@property (nonatomic, retain) NSSet *squad;
@end

@interface DockResource (CoreDataGeneratedAccessors)

- (void)addSquadObject:(DockSquad *)value;
- (void)removeSquadObject:(DockSquad *)value;
- (void)addSquad:(NSSet *)values;
- (void)removeSquad:(NSSet *)values;

@end
