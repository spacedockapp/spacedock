#import <Cocoa/Cocoa.h>

@class DockEquippedShip;
@class DockEquippedUpgrade;
@class DockFleetBuildSheet;
@class DockInspector;
@class DockItemSourceListController;
@class DockNoteEditor;
@class DockOverrideEditor;
@class DockExchangeFactionsSelection;
@class DockSetTabController;
@class DockSetTabController;
@class DockSquadDetailController;
@class DockTabController;
@class DockUpgrade;

extern NSString* kInspectorVisible;
extern NSString* kExpandedRows;
extern NSString* kExpandSquads;

@interface DockAppDelegate : NSObject<NSApplicationDelegate>

@property (assign) IBOutlet NSWindow* window;
@property (assign) IBOutlet NSTabView* tabView;
@property (assign) IBOutlet DockTabController* shipsTabController;
@property (assign) IBOutlet NSArrayController* squadsController;
@property (assign) IBOutlet DockTabController* captainsTabController;
@property (assign) IBOutlet DockTabController* upgradesTabController;
@property (assign) IBOutlet DockTabController* officersTabController;
@property (assign) IBOutlet DockTabController* fleetCaptainsTabController;
@property (assign) IBOutlet DockTabController* admiralsTabController;
@property (assign) IBOutlet DockTabController* resourcesTabController;
@property (assign) IBOutlet DockTabController* flagshipsTabController;
@property (assign) IBOutlet DockSetTabController* setsTabController;
@property (assign) IBOutlet DockTabController* referenceTabController;
@property (assign) IBOutlet DockItemSourceListController* itemSourceListController;
@property (assign) IBOutlet NSTableView* upgradesTableView;
@property (assign) IBOutlet NSTableView* resourcesTableView;
@property (assign) IBOutlet NSTableView* setsTableView;
@property (assign) IBOutlet NSTableView* squadsTableView;
@property (assign) IBOutlet NSMenu* factionMenu;
@property (assign) IBOutlet NSMenu* fileMenu;
@property (assign) IBOutlet NSWindow* preferencesWindow;
@property (assign) IBOutlet DockInspector* inspector;
@property (assign) IBOutlet DockFleetBuildSheet* fleetBuildSheet2;
@property (assign) IBOutlet DockNoteEditor* noteEditor;
@property (assign) IBOutlet DockOverrideEditor* overrideEditor;
@property (assign) IBOutlet DockExchangeFactionsSelection* exchangeFactionSelection;
@property (assign) IBOutlet NSToolbar* toolbar;
@property (assign) IBOutlet NSSearchField* searchField;


@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel* managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic) NSString* factionName;
@property (strong, nonatomic) NSString* upType;
@property (strong, nonatomic) NSArray* includedSets;
@property (strong, nonatomic) NSSavePanel* currentSavePanel;


+(NSURL*)applicationFilesDirectory;
-(IBAction)printFleetBuildSheet:(id)sender;
-(IBAction)setResource:(id)sender;
-(IBAction)toggleMarkExpiredResources:(id)sender;

-(void)selectUpgrade:(DockEquippedUpgrade*)theUpgrade;
-(void)selectShip:(DockEquippedShip*)theShip;
-(void)showInList:(id)target targetShip:(DockEquippedShip*)targetShip;

-(void)updateFactionFilter:(NSString*)faction;
-(void)updateUpgradeTypeFilter:(NSString*)upgradeType;
@end
