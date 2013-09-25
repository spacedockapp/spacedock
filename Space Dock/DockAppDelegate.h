//
//  DockAppDelegate.h
//  Space Dock
//
//  Created by Rob Tsuk on 9/18/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DockAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSArrayController *shipsController;
@property (assign) IBOutlet NSArrayController *squadsController;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *shipsSortDescriptors;
@property (strong, nonatomic) NSArray *captainsSortDescriptors;

-(IBAction)saveAction:(id)sender;
-(IBAction)addSelectedShip:(id)sender;

@end
