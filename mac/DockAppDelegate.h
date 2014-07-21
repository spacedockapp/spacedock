#import <Cocoa/Cocoa.h>

@class DockEquippedShip;
@class DockEquippedUpgrade;
@class DockInspector;
@class DockFleetBuildSheet;
@class DockNoteEditor;
@class DockOverrideEditor;
@class DockSetTabController;
@class DockTabController;
@class DockUpgrade;

extern NSString* kInspectorVisible;
extern NSString* kExpandedRows;
extern NSString* kExpandSquads;

@interface DockAppDelegate : NSObject<NSApplicationDelegate>

@property (assign) IBOutlet NSWindow* window;
@property (assign) IBOutlet NSTabView* tabView;
@property (assign) IBOutlet NSOutlineView* squadDetailView;
@property (assign) IBOutlet DockTabController* shipsTabController;
@property (assign) IBOutlet NSArrayController* squadsController;
@property (assign) IBOutlet DockTabController* captainsTabController;
@property (assign) IBOutlet DockTabController* upgradesTabController;
@property (assign) IBOutlet DockTabController* admiralsTabController;
@property (assign) IBOutlet DockTabController* resourcesTabController;
@property (assign) IBOutlet DockTabController* flagshipsTabController;
@property (assign) IBOutlet DockSetTabController* setsTabController;
@property (assign) IBOutlet DockTabController* referenceTabController;
@property (assign) IBOutlet NSTreeController* squadDetailController;
@property (assign) IBOutlet NSPopUpButton* exportFormatPopup;
@property (assign) IBOutlet NSTableView* upgradesTableView;
@property (assign) IBOutlet NSTableView* setsTableView;
@property (assign) IBOutlet NSTableView* squadsTableView;
@property (assign) IBOutlet NSMenu* factionMenu;
@property (assign) IBOutlet NSMenu* fileMenu;
@property (assign) IBOutlet NSWindow* preferencesWindow;
@property (assign) IBOutlet DockInspector* inspector;
@property (assign) IBOutlet DockFleetBuildSheet* fleetBuildSheet2;
@property (assign) IBOutlet DockNoteEditor* noteEditor;
@property (assign) IBOutlet DockOverrideEditor* overrideEditor;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel* managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic) NSString* factionName;
@property (strong, nonatomic) NSString* upType;
@property (strong, nonatomic) NSArray* includedSets;
@property (strong, nonatomic) NSSavePanel* currentSavePanel;


+(NSURL*)applicationFilesDirectory;
-(IBAction)saveAction:(id)sender;
-(IBAction)addSquad:(id)sender;
-(IBAction)addSelected:(id)sender;
-(IBAction)deleteSelectedShip:(id)sender;
-(IBAction)addSelectedUpgradeAction:(id)sender;
-(IBAction)deleteSelectedUpgradeAction:(id)sender;
-(IBAction)duplicate:(id)sender;
-(IBAction)expandAll:(id)sender;
-(IBAction)exportSquad:(id)sender;
-(IBAction)setFormat:(id)sender;
-(IBAction)importSquad:(id)sender;
-(IBAction)resetFactionFilter:(id)sender;
-(IBAction)filterToFaction:(id)sender;
-(IBAction)showInspector:(id)sender;
-(IBAction)overrideCost:(id)sender;
-(IBAction)showInList:(id)sender;

-(void)selectUpgrade:(DockEquippedUpgrade*)theUpgrade;
-(void)selectShip:(DockEquippedShip*)theShip;
@end
