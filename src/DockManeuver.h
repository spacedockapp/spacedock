//
//  DockManeuver.h
//  Space Dock
//
//  Created by Rob Tsuk on 11/20/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DockShip;

@interface DockManeuver : NSManagedObject

@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSNumber * speed;
@property (nonatomic, retain) NSString * kind;
@property (nonatomic, retain) DockShip *ship;

@end
