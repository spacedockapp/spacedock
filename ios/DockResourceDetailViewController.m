//
//  DockResourceDetailViewController.m
//  Space Dock
//
//  Created by Rob Tsuk on 11/9/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import "DockResourceDetailViewController.h"

@interface DockResourceDetailViewController ()

@end

@implementation DockResourceDetailViewController

-(NSArray*)attributeNamesToDisplay
{
    return @[@"title", @"cost", @"ability"];
}

@end
