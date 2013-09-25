//
//  DockOrderedSetArrayValueTransformer.m
//  Space Dock
//
//  Created by Rob Tsuk on 9/24/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import "DockOrderedSetArrayValueTransformer.h"

@implementation DockOrderedSetArrayValueTransformer

+(Class)transformedValueClass
{
    return [NSArray class];
}

+(BOOL)allowsReverseTransformation
{
    return YES;
}

-(id)transformedValue:(id)value
{
    return [(NSOrderedSet*)value array];
}

-(id)reverseTransformedValue:(id)value
{
    return [NSOrderedSet orderedSetWithArray: value];
}

@end
