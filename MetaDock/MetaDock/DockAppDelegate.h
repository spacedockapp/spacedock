//
//  DockAppDelegate.h
//  MetaDock
//
//  Created by Rob Tsuk on 8/10/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DockAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end
