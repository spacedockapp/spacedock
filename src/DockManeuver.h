//
//  DockManeuver.h
//  Space Dock
//
//  Created by Rob Tsuk on 4/12/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DockShipClassDetails;

@interface DockManeuver : NSManagedObject

@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSString * kind;
@property (nonatomic, retain) NSNumber * speed;
@property (nonatomic, retain) DockShipClassDetails *shipClassDetails;

@end
