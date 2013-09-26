//
//  DockWeapon.h
//  Space Dock
//
//  Created by Rob Tsuk on 9/26/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DockUpgrade.h"


@interface DockWeapon : DockUpgrade

@property (nonatomic, retain) NSNumber * attack;
@property (nonatomic, retain) NSString * range;

@end
