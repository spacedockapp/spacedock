//
//  DockReference.h
//  Space Dock
//
//  Created by Rob Tsuk on 5/21/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DockComponent.h"


@interface DockReference : DockComponent

@property (nonatomic, retain) NSString * ability;
@property (nonatomic, retain) NSString * externalId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;

@end
