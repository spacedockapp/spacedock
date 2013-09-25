//
//  DockWeapon.h
//  Space Dock
//
//  Created by Rob Tsuk on 9/24/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import "DockUpgrade.h"
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>


@interface DockWeapon : DockUpgrade

@property (nonatomic, retain) NSNumber* attack;
@property (nonatomic, retain) NSString* range;

@end
