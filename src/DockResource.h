//
//  DockResource.h
//  Space Dock
//
//  Created by Rob Tsuk on 9/28/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>


@interface DockResource : NSManagedObject

@property (nonatomic, retain) NSString* ability;
@property (nonatomic, retain) NSNumber* cost;
@property (nonatomic, retain) NSString* externalId;
@property (nonatomic, retain) NSString* special;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSNumber* unique;
@property (nonatomic, retain) NSString* type;

@end
