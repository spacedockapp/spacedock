//
//  DockManeuver.h
//  Space Dock
//
//  Created by Rob Tsuk on 11/24/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@class DockShipClassDetails;

@interface DockManeuver : NSManagedObject

@property (nonatomic, retain) NSString* color;
@property (nonatomic, retain) NSString* kind;
@property (nonatomic, retain) NSNumber* speed;
@property (nonatomic, retain) DockShipClassDetails* shipClassDetails;

@end
