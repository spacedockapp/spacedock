//
//  DockBooleanFormatter.m
//  Space Dock
//
//  Created by Rob Tsuk on 10/3/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import "DockBooleanFormatter.h"

@implementation DockBooleanFormatter

- (NSString *)stringForObjectValue:(id)obj
{
    BOOL yn = [obj boolValue];
    if (yn) {
        return @"Y";
    }
    return @"N";
}

@end
