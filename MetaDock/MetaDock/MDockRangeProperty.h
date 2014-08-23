//
//  MDockRangeProperty.h
//  MetaDock
//
//  Created by Rob Tsuk on 8/23/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MDockProperty.h"


@interface MDockRangeProperty : MDockProperty

@property (nonatomic) int32_t minVal;
@property (nonatomic) int32_t maxVal;

@end
