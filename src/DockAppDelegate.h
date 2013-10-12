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
@property (assign) IBOutlet NSOutlineView* squadDetailView;
@property (assign) IBOutlet NSArrayController* shipsController;
@property (assign) IBOutlet NSArrayController* squadsController;
@property (assign) IBOutlet NSArrayController* captainsController;
@property (assign) IBOutlet NSArrayController* upgradesController;
@property (assign) IBOutlet NSArrayController* resourcesController;
@property (assign) IBOutlet NSTreeController* squadDetailController;
@property (assign) IBOutlet NSView* exportFormatView;
@property (assign) IBOutlet NSPopUpButton* exportFormatPopup;
@property (assign) IBOutlet NSTableView* shipsTableView;
@property (assign) IBOutlet NSTableView* captainsTableView;
@property (assign) IBOutlet NSTableView* upgradesTableView;
@property (assign) IBOutlet NSTableView* resourcesTableView;
@property (assign) IBOutlet NSTableView* setsTableView;
@property (assign) IBOutlet NSTableView* squadsTableView;
@property (assign) IBOutlet NSView* fleetBuildSheet;
@property (assign) IBOutlet NSMenu* factionMenu;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel* managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic) NSString* factionName;
@property (strong, nonatomic) NSArray* includedSets;
@property (strong, nonatomic) NSSavePanel* currentSavePanel;

-(IBAction)saveAction:(id)sender;
-(IBAction)addSelected:(id)sender;
-(IBAction)addSelectedShip:(id)sender;
-(IBAction)deleteSelectedShip:(id)sender;
-(IBAction)addSelectedUpgradeAction:(id)sender;
-(IBAction)deleteSelectedUpgradeAction:(id)sender;
-(IBAction)deleteSelected:(id)sender;
-(IBAction)expandAll:(id)sender;
-(IBAction)exportSquad:(id)sender;
-(IBAction)setFormat:(id)sender;
-(IBAction)importSquad:(id)sender;
-(IBAction)resetFactionFilter:(id)sender;
-(IBAction)filterToFaction:(id)sender;

@end
