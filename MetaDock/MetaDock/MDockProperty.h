//
//  MDockProperty.h
//  MetaDock
//
//  Created by Rob Tsuk on 8/23/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MDockComponent;

@interface MDockProperty : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) MDockComponent *component;

@end
