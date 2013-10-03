//
//  DockResource+Addons.h
//  Space Dock
//
//  Created by Rob Tsuk on 10/3/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import "DockResource.h"

@interface DockResource (Addons)
+(DockResource*)resourceForId:(NSString*)externalId context:(NSManagedObjectContext*)context;
@end
