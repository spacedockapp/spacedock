//
//  DockExchangeFactionsSelection.h
//  Space Dock
//
//  Created by Robert George on 2/5/15.
//  Copyright (c) 2015 Robert George. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DockSquad;

@interface DockExchangeFactionsSelection : NSObject
-(void)show:(DockSquad*)targetSquad context:(NSManagedObjectContext*) managedObjectContext;

@end
