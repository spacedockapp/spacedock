//
//  DockReference.h
//  Space Dock
//
//  Created by Rob Tsuk on 5/17/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DockReference : NSManagedObject

@property (nonatomic, retain) NSString * ability;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * externalId;

@end
