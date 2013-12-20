//
//  DockFlagshipViewController.m
//  Space Dock
//
//  Created by Rob Tsuk on 12/20/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import "DockFlagshipDetailViewController.h"

@interface DockFlagshipDetailViewController ()

@end

@implementation DockFlagshipDetailViewController

-(NSArray*)attributeNamesToDisplay
{
    return @[@"name", @"attack", @"agility", @"hull", @"shield", @"capabilities", @"ability"];
}

@end
