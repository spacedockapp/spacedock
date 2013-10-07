#import <Cocoa/Cocoa.h>

@class DockFleetBuildSheet;

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
@property (assign) IBOutlet DockFleetBuildSheet* fleetBuildSheet;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel* managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext* managedObjectContext;

-(IBAction)saveAction:(id)sender;
-(IBAction)addSelected:(id)sender;
-(IBAction)deleteSelected:(id)sender;
-(IBAction)expandAll:(id)sender;
-(IBAction)exportSquad:(id)sender;
-(IBAction)importSquad:(id)sender;

@end
