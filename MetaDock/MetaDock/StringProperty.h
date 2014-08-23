//
//  StringProperty.h
//  MetaDock
//
//  Created by Rob Tsuk on 8/23/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MDockProperty.h"


@interface StringProperty : MDockProperty

@property (nonatomic, retain) NSString * val;

@end
