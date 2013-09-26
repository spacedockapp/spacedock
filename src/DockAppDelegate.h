//
//  DockAppDelegate.h
//  Space Dock
//
//  Created by Rob Tsuk on 9/18/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DockAppDelegate : NSObject<NSApplicationDelegate>

@property (assign) IBOutlet NSWindow* window;
@property (assign) IBOutlet NSTabView* tabView;
@property (assign) IBOutlet NSArrayController* shipsController;
@property (assign) IBOutlet NSArrayController* squadsController;
@property (assign) IBOutlet NSArrayController* captainsController;
@property (assign) IBOutlet NSTreeController* squadDetailController;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel* managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext* managedObjectContext;

-(IBAction)saveAction:(id)sender;
-(IBAction)addSelected:(id)sender;

@end
