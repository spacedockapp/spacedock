#import "DockAppDelegate.h"

#import "DockBackupManager.h"
#import "DockBuildMat.h"
#import "DockCaptain.h"
#import "DockTabController.h"
#import "DockConstants.h"
#import "DockCrew.h"
#import "DockDataFileLoader.h"
#import "DockDataModelExporter.h"
#import "DockDataLoader.h"
#import "DockDataUpdater.h"
#import "DockEquippedFlagship.h"
#import "DockEquippedShip.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedShip+MacAddons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockErrors.h"
#import "DockFlagship+MacAddons.h"
#import "DockFleetBuildSheet.h"
#import "DockInspector.h"
#import "DockNoteEditor.h"
#import "DockOverrideEditor.h"
#import "DockResource+Addons.h"
#import "DockSet+Addons.h"
#import "DockSetItem+Addons.h"
#import "DockSetTabController.h"
#import "DockShip+Addons.h"
#import "DockSquad+Addons.h"
#import "DockSquad.h"
#import "DockSquadImporterMac.h"
#import "DockTalent.h"
#import "DockTech.h"
#import "DockUpgrade+Addons.h"
#import "DockUtils.h"
#import "DockWeapon.h"

#import "NSFileManager+Addons.h"
#import "NSTreeController+Additions.h"

NSString* kWarnAboutUnhandledSpecials = @"warnAboutUnhandledSpecials";
NSString* kInspectorVisible = @"inspectorVisible";
NSString* kExpandSquads = @"expandSquads";
NSString* kExpandedRows = @"expandedRows";
NSString* kShowDataModelExport = @"showDataModelExport";
NSString* kSortSquadsByDate = @"sortSquadsByDate";

@interface DockAppDelegate ()
@property (strong, nonatomic) DockDataUpdater* updater;
@property (copy, nonatomic) NSArray* allSets;
@property (assign, nonatomic) BOOL expandedRows;
@property (strong, nonatomic) DockBuildMat* buildMat;
@end

@implementation DockAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

+(void)initialize
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* appDefs = @{
        kWarnAboutUnhandledSpecials: @YES,
        kInspectorVisible: @NO,
        kExpandSquads: @YES,
        kExpandedRows: @YES,
        kSortSquadsByDate: @NO
    };

    [defaults registerDefaults: appDefs];
}

-(void)validateSpecials:(NSSet*)unhandledSpecials
{
    if (unhandledSpecials.count > 0) {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

        if ([defaults boolForKey: kWarnAboutUnhandledSpecials]) {
            NSString* msg = [NSString stringWithFormat: @"Data.xml contains cards that have special effects that this version of Space Dock doesn't know how to handle"];
            NSArray* unhandledSpecialsArray = [unhandledSpecials allObjects];
            NSString* info = [unhandledSpecialsArray componentsJoinedByString: @", "];
            [self whineToUser: msg info: info showsSuppressionButton: YES];
        }
    }
}

-(void)loadData
{
    DockDataLoader* loader = [[DockDataLoader alloc] initWithContext: _managedObjectContext];
    NSError* error;
    [loader loadData: &error];
    [self validateSpecials: [loader validateSpecials]];
    [loader cleanupDatabase];

    _allSets = [DockSet allSets : _managedObjectContext];
    NSMutableArray* setNames = [NSMutableArray arrayWithCapacity: _allSets.count];
    for (DockSet* set in _allSets) {
        [setNames addObject: set.productName];
        [set addObserver: self forKeyPath: @"include" options: 0 context: 0];
    }
    [setNames sortUsingSelector: @selector(compare:)];
}

- (void)handleSelectedSquadChanged:(NSDictionary*)change
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey: kExpandSquads]) {
        [self performSelector: @selector(expandAll:) withObject: nil afterDelay: 0];
    }
}

-(void)observeValueForKeyPath:(NSString*)keyPath
                     ofObject:(id)object
                       change:(NSDictionary*)change
                      context:(void*)context
{
    if (object == _squadDetailController) {
        [_squadDetailView expandItem: nil
                      expandChildren: YES];
        [_squadDetailController removeObserver: self
                                    forKeyPath: @"content"];
    } else if (object == _squadsController) {
        [self handleSelectedSquadChanged: change];
    } else if ([object isMemberOfClass: [DockSet class]]) {
        [self updateForSelectedSets];
    } else {
        NSLog(@"other change %@ %@", object, change);
    }
}

-(void)setupFactionMenu
{
    NSSet* factionsSet = [DockUpgrade allFactions: _managedObjectContext];
    NSArray* originalFactions = @[
        @"Bajoran",
        @"Dominion",
        @"Federation",
        @"Ferengi",
        @"Independent",
        @"Klingon",
        @"Romulan"
    ];
    NSSet* originalFactionsSet = [NSSet setWithArray: originalFactions];
    NSArray* factionsArray = [[factionsSet allObjects] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    int originalShortcuts = 1;
    int newShortcuts = (int)originalFactions.count + 1;
    int shortcut = 0;
    for (NSString* factionName in factionsArray) {
        if ([originalFactionsSet containsObject: factionName]) {
            shortcut = originalShortcuts;
            originalShortcuts += 1;
        } else {
            shortcut = newShortcuts;
            newShortcuts += 1;
        }
        NSString* keyEquiv = @"";
        if (shortcut < 10) {
            keyEquiv = [NSString stringWithFormat: @"%d", shortcut];
        }
        [_factionMenu addItemWithTitle: factionName action: @selector(filterToFaction:) keyEquivalent: keyEquiv];
    }
}

-(void)setupFileMenu
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey: kShowDataModelExport]) {
        NSString* keyEquiv = @"";
        [_fileMenu addItem: [NSMenuItem separatorItem]];
        [_fileMenu addItemWithTitle: @"Export Data Model" action: @selector(exportDataModel:) keyEquivalent: keyEquiv];
    }
}

-(NSString*)pathToDataFile
{
    NSString* appData = [[DockAppDelegate applicationFilesDirectory] path];
    NSString* xmlFile = [appData stringByAppendingPathComponent: @"Data.xml"];
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL isDirectory;
    if ([fm fileExistsAtPath: xmlFile isDirectory: &isDirectory]) {
        return xmlFile;
    }
    
    return [[NSBundle mainBundle] pathForResource: @"Data" ofType: @"xml"];
}

-(NSString*)backupDirectory
{
    NSString* appData = [[DockAppDelegate applicationFilesDirectory] path];
    NSString* backupPath = [appData stringByAppendingPathComponent: @"backup"];
    backupPath = [backupPath stringByAppendingPathExtension: kSpaceDockSquadListFileExtension];
    return backupPath;
}

-(void)applicationDidFinishLaunching:(NSNotification*)aNotification
{
    [self loadData];

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    [DockSquad assignUUIDs: self.managedObjectContext];
    [self updateForSelectedSets];
    [_squadDetailController addObserver: self
                             forKeyPath: @"content"
                                options: 0
                                context: nil];
    [_squadsController addObserver: self
                             forKeyPath: @"selectionIndexes"
                                options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                context: nil];
    NSSortDescriptor* defaultSortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"releaseDate" ascending: YES];
    [_setsTableView setSortDescriptors: @[defaultSortDescriptor]];
    if ([defaults boolForKey: kSortSquadsByDate]) {
        defaultSortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"modified" ascending: NO selector: @selector(compare:)];
    } else {
        defaultSortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"name" ascending: YES selector: @selector(localizedCaseInsensitiveCompare:)];
    }
    [_squadsTableView setSortDescriptors: @[defaultSortDescriptor]];
    [self setupFactionMenu];
    [self setupFileMenu];

    if ([defaults boolForKey: kInspectorVisible]) {
        [_inspector show];
    }
    
    self.expandedRows = [defaults boolForKey: kExpandedRows];

}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "com.funnyhatsoftware.Space_Dock" in the user's Application Support directory.
+(NSURL*)applicationFilesDirectory
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSURL* appSupportURL = [[fileManager URLsForDirectory: NSApplicationSupportDirectory inDomains: NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent: kDockBundleIdentifier];
}

// Creates if necessary and returns the managed object model for the application.
-(NSManagedObjectModel*)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }

    NSURL* modelURL = [[NSBundle mainBundle] URLForResource: @"Space_Dock" withExtension: @"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
-(NSPersistentStoreCoordinator*)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }

    NSManagedObjectModel* mom = [self managedObjectModel];

    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }

    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSURL* applicationFilesDirectory = [DockAppDelegate applicationFilesDirectory];
    NSError* error = nil;

    NSDictionary* properties = [applicationFilesDirectory resourceValuesForKeys: @[NSURLIsDirectoryKey] error: &error];

    if (!properties) {
        BOOL ok = NO;

        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath: [applicationFilesDirectory path] withIntermediateDirectories: YES attributes: nil error: &error];
        }

        if (!ok) {
            [[NSApplication sharedApplication] presentError: error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString* failureDescription = [NSString stringWithFormat: @"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];

            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setValue: failureDescription forKey: NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain: @"YOUR_ERROR_DOMAIN" code: 101 userInfo: dict];

            [[NSApplication sharedApplication] presentError: error];
            return nil;
        }
    }

    NSURL* url = [applicationFilesDirectory URLByAppendingPathComponent: @"Space_Dock.storedata"];
    NSPersistentStoreCoordinator* coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];

    NSDictionary* options = @{
        NSMigratePersistentStoresAutomaticallyOption : @YES,
        NSInferMappingModelAutomaticallyOption: @YES
    };

    if (![coordinator addPersistentStoreWithType: NSXMLStoreType configuration: nil URL: url options: options error: &error]) {
        [[NSApplication sharedApplication] presentError: error];
        return nil;
    }

    _persistentStoreCoordinator = coordinator;

    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
-(NSManagedObjectContext*)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }

    NSPersistentStoreCoordinator* coordinator = [self persistentStoreCoordinator];

    if (!coordinator) {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setValue: @"Failed to initialize the store" forKey: NSLocalizedDescriptionKey];
        [dict setValue: @"There was an error building up the data file." forKey: NSLocalizedFailureReasonErrorKey];
        NSError* error = [NSError errorWithDomain: @"YOUR_ERROR_DOMAIN" code: 9999 userInfo: dict];
        [[NSApplication sharedApplication] presentError: error];
        return nil;
    }

    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator: coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
-(NSUndoManager*)windowWillReturnUndoManager:(NSWindow*)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
-(IBAction)saveAction:(id)sender
{
    NSError* error = nil;

    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }

    if (![[self managedObjectContext] save: &error]) {
        [[NSApplication sharedApplication] presentError: error];
    }
}

-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication*)sender
{
    // Save changes in the application's managed object context before the application terminates.

    if (!_managedObjectContext) {
        return NSTerminateNow;
    }

    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }

    NSError* error = nil;
    
    BOOL coreDataSave = [[self managedObjectContext] save: &error];

    DockBackupManager* backupManager = [DockBackupManager sharedBackupManager];
    if (backupManager.squadHasChanged) {
        [backupManager backupNow: self.managedObjectContext error: nil];
    }

    if (!coreDataSave) {

        // Customize this code block to include application-specific recovery steps.
        BOOL result = [sender presentError: error];

        if (result) {
            return NSTerminateCancel;
        }

        NSString* question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString* info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString* quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString* cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert* alert = [[NSAlert alloc] init];
        [alert setMessageText: question];
        [alert setInformativeText: info];
        [alert addButtonWithTitle: quitButton];
        [alert addButtonWithTitle: cancelButton];

        NSInteger answer = [alert runModal];

        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

-(void)whineToUser:(NSString*)msg info:(NSString*)info showsSuppressionButton:(BOOL)showsSuppressionButton
{
    NSAlert* alert = [[NSAlert alloc] init];
    [alert setMessageText: msg];
    [alert setInformativeText: info];
    [alert setAlertStyle: NSInformationalAlertStyle];
    [alert setShowsSuppressionButton: showsSuppressionButton];
    [alert beginSheetModalForWindow: [self window]
                      modalDelegate: self
                     didEndSelector: @selector(alertDidEnd:returnCode:contextInfo:)
                        contextInfo: nil];
}

-(void)whineToUser:(NSString*)msg
{
    [self whineToUser: msg info: @"" showsSuppressionButton: NO];
}

-(void)alertDidEnd:(NSAlert*)alert returnCode:(NSInteger)returnCode contextInfo:(void*)contextInfo
{
    [[alert window] orderOut: self];

    if ([[alert suppressionButton] state] == NSOnState) {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool: NO forKey: kWarnAboutUnhandledSpecials];
    }
}

-(IBAction)addSquad:(id)sender
{
    DockSquad* squad = [DockSquad squad: _managedObjectContext];
    [self performSelector: @selector(editNameOfSquad:) withObject: squad afterDelay: 0];
    [self saveAction: sender];
}

-(IBAction)deleteSelectedShip:(id)sender
{
    [self deleteSelected: sender];
}

-(IBAction)changeSelectedShip:(id)sender
{
    DockEquippedShip* targetShip = [self selectedEquippedShip];
    DockShip* ship = [self selectedShip];
    [targetShip changeShip: ship];
}

-(DockShip*)selectedShip
{
    return self.shipsTabController.selectedItem;
}

-(DockUpgrade*)selectedUpgrade
{
    return self.upgradesTabController.selectedItem;
}

-(DockEquippedShip*)equippedShipForTarget:(id)target
{
    if ([target isKindOfClass: [DockEquippedShip class]]) {
        return target;
    }

    if ([target isKindOfClass: [DockEquippedFlagship class]]) {
        return [target equippedShip];
    }

    if ([target isMemberOfClass: [DockEquippedUpgrade class]]) {
        DockEquippedUpgrade* upgrade = target;
        return upgrade.equippedShip;
    }

    return nil;
}

-(DockEquippedShip*)selectedEquippedShip
{
    NSArray* selectedShips = [_squadDetailController selectedObjects];

    if (selectedShips.count > 0) {
        id target = [[_squadDetailController selectedObjects] objectAtIndex: 0];
        
        return [self equippedShipForTarget: target];
    }

    return nil;
}

-(id)clickedSquadItem
{
    NSInteger index = [_squadDetailView clickedRow];
    if (index != -1) {
        id item = [_squadDetailView itemAtRow: index];
        return [item representedObject];
    }

    return nil;
}

-(DockEquippedShip*)clickedEquippedShip
{
    NSInteger index = [_squadDetailView clickedRow];
    if (index != -1) {
        id item = [_squadDetailView itemAtRow: index];
        return [self equippedShipForTarget: [item representedObject]];
    }

    return nil;
}

-(void)selectShip:(DockEquippedShip*)theShip
{
    NSIndexPath* path = [_squadDetailController indexPathOfObject: theShip];
    [_squadDetailController setSelectionIndexPath: path];
}

-(DockEquippedUpgrade*)selectedEquippedUpgrade
{
    NSArray* selectedItems = [_squadDetailController selectedObjects];

    if (selectedItems.count > 0) {
        id target = [selectedItems objectAtIndex: 0];

        if ([target isMemberOfClass: [DockEquippedUpgrade class]]) {
            return target;
        }
    }

    return nil;
}

-(void)selectUpgrade:(DockEquippedUpgrade*)theUpgrade
{
    NSIndexPath* path = [_squadDetailController indexPathOfObject: theUpgrade];
    [_squadDetailController setSelectionIndexPath: path];
}

-(DockSquad*)selectedSquad
{
    DockSquad* squad = nil;

    NSArray* squads = [_squadsController selectedObjects];

    if (squads.count > 0) {
        squad = [squads objectAtIndex: 0];
    }

    return squad;
}

-(void)selectSquad:(DockSquad*)theSquad
{
    NSArray* objects = [_squadsController arrangedObjects];
    NSInteger index = [objects indexOfObject: theSquad];
    [_squadsController setSelectionIndex: index];
}

-(IBAction)addSelected:(id)sender
{
    NSTabViewItem* selectedTab = [_tabView selectedTabViewItem];
    id identifier = selectedTab.identifier;

    DockEquippedShip* selectedShip = [self selectedEquippedShip];
    DockEquippedUpgrade* maybeUpgrade = [self selectedEquippedUpgrade];

    if ([identifier isEqualToString: @"captains"]) {
        [self.captainsTabController addSelectedToSquad: [self selectedSquad] ship: selectedShip selectedItem: maybeUpgrade];
    } else if ([identifier isEqualToString: @"upgrades"]) {
        [self.upgradesTabController addSelectedToSquad: [self selectedSquad] ship: selectedShip selectedItem: maybeUpgrade];
    } else if ([identifier isEqualToString: @"admirals"]) {
        [self.admiralsTabController addSelectedToSquad: [self selectedSquad] ship: selectedShip selectedItem: maybeUpgrade];
    } else if ([identifier isEqualToString: @"flagships"]) {
        [self.flagshipsTabController addSelectedToSquad: [self selectedSquad] ship: selectedShip selectedItem: maybeUpgrade];
    } else if ([identifier isEqualToString: @"resources"]) {
        [self.resourcesTabController addSelectedToSquad: [self selectedSquad] ship: selectedShip selectedItem: maybeUpgrade];
    } else if ([identifier isEqualToString: @"ships"]) {
        [self.shipsTabController addSelectedToSquad: [self selectedSquad] ship: selectedShip selectedItem: maybeUpgrade];
    }
}

-(IBAction)deleteTarget:(id)target targetShip:(DockEquippedShip*)targetShip
{
    if (target == targetShip) {
        DockSquad* squad = [[_squadsController selectedObjects] objectAtIndex: 0];
        [squad removeEquippedShip: targetShip];
    } else if ([target isKindOfClass: [DockEquippedFlagship class]]) {
        [targetShip removeFlagship];
    } else {
        [targetShip removeUpgrade: target establishPlaceholders: YES];
        [self selectShip: targetShip];
    }
}

-(IBAction)deleteSelected:(id)sender
{
    id target = [[_squadDetailController selectedObjects] objectAtIndex: 0];
    DockEquippedShip* targetShip = [self selectedEquippedShip];
    [self deleteTarget: target targetShip: targetShip];
}

-(void)editNameOfSquad:(DockSquad*)theSquad
{
    NSArray* objects = [_squadsController arrangedObjects];
    NSInteger row = [objects indexOfObject: theSquad];

    if (row != NSNotFound) {
        NSInteger columnIndex = [_squadsTableView columnWithIdentifier: @"squadsTitle"];
        if (columnIndex != -1) {
            [_squadsTableView becomeFirstResponder];
            [_squadsController setSelectionIndex: row];
            [_squadsTableView editColumn: columnIndex row: row withEvent: nil select: YES];
        }
    }
}

-(IBAction)duplicate:(id)sender
{
    DockSquad* squad = [self selectedSquad];
    DockSquad* newSquad = [squad duplicate];
    [self performSelector: @selector(editNameOfSquad:) withObject: newSquad afterDelay: 0];
}

-(IBAction)addSelectedUpgradeAction:(id)sender
{
    [self addSelected: sender];
}

-(IBAction)deleteSelectedUpgradeAction:(id)sender
{
    [self deleteSelected: sender];
}

-(IBAction)expandAll:(id)sender
{
    [_squadDetailView expandItem: nil expandChildren: YES];
}

-(IBAction)exportSquad:(id)sender
{
    DockSquad* squad = [self selectedSquad];
    _currentSavePanel = [NSSavePanel savePanel];
    _currentSavePanel.allowedFileTypes = @[kSpaceDockSquadFileExtension];
    [_currentSavePanel setNameFieldStringValue: squad.name];
    [_currentSavePanel beginSheetModalForWindow: self.window completionHandler: ^(NSInteger v) {
        if (v == NSFileHandlingPanelOKButton) {
            NSURL* fileUrl = _currentSavePanel.URL;
            NSDictionary* json = [squad asJSON];
            NSError* error;
            NSData* jsonData = [NSJSONSerialization dataWithJSONObject: json options: NSJSONWritingPrettyPrinted error: &error];
            [jsonData writeToURL: fileUrl atomically: NO];
        }
        
        _currentSavePanel = nil;
    }
     
     ];
}

-(IBAction)setFormat:(id)sender
{
    NSString* newExtension = @"txt";
    NSInteger formatSelected = self.exportFormatPopup.selectedTag;

    if (formatSelected == 2) {
        newExtension = kSpaceDockSquadFileExtension;
    }

    NSString* currentName = [_currentSavePanel nameFieldStringValue];
    NSString* currentBaseName = [currentName stringByDeletingPathExtension];
    NSString* newName = [currentBaseName stringByAppendingPathExtension: newExtension];
    [_currentSavePanel setNameFieldStringValue: newName];
}

-(IBAction)importSquad:(id)sender
{
    NSOpenPanel* importPanel = [NSOpenPanel openPanel];
    importPanel.allowedFileTypes = @[kSpaceDockSquadWindowsFileExtension, kSpaceDockSquadOldFileExtension, kSpaceDockSquadFileExtension];
    [importPanel beginSheetModalForWindow: self.window completionHandler: ^(NSInteger v) {
         if (v == NSFileHandlingPanelOKButton) {
             NSURL* fileUrl = importPanel.URL;
             NSError* error;
             NSString* extension = [fileUrl pathExtension];
             NSString* data = [NSString stringWithContentsOfURL: fileUrl encoding: NSUTF8StringEncoding error: &error];
             if ([extension isEqualToString: kSpaceDockSquadFileExtension]) {
                [DockSquad import: data context: _managedObjectContext];
             } else {
                NSString* name = [[[fileUrl path] lastPathComponent] stringByDeletingPathExtension];
                [DockSquad import: name data: data context: _managedObjectContext];
             }
         }
     }

    ];
}

-(IBAction)resetFactionFilter:(id)sender
{
    self.factionName = nil;
}

-(void)updateFactionFilter:(NSString*)faction
{
    self.factionName = faction;
}

-(IBAction)filterToFaction:(id)sender
{
    [self updateFactionFilter: [sender title]];
}

-(IBAction)resetUpgradeFilter:(id)sender
{
    self.upType = nil;
}

-(void)updateUpgradeTypeFilter:(NSString*)upgradeType
{
    self.upType = upgradeType;
}


-(IBAction)filterToUpgradeType:(id)sender
{
    self.upType = [sender title];
}

-(void)updateForSelectedSets
{
    NSArray* includedSets = [DockSet includedSets: _managedObjectContext];
    NSMutableArray* includedIds = [[NSMutableArray alloc] init];

    for (DockSet* set in includedSets) {
        [includedIds addObject: [set externalId]];
    }
    self.includedSets = [NSArray arrayWithArray: includedIds];
}

-(void)explainCantPromoteShip:(DockShip*)ship
{
    NSAlert* alert = [[NSAlert alloc] init];
    NSString* msg = [NSString stringWithFormat: @"Can't promote the selected ship to %@.", ship.title];
    [alert setMessageText: msg];
    NSString* info = [NSString stringWithFormat: @"%@ is unique and already exists in the squadron.", ship.title];
    [alert setInformativeText: info];
    [alert setAlertStyle: NSInformationalAlertStyle];
    [alert beginSheetModalForWindow: [self window]
                      modalDelegate: self
                     didEndSelector: @selector(alertDidEnd:returnCode:contextInfo:)
                        contextInfo: nil];
}

-(IBAction)toggleUnique:(id)sender
{
    DockEquippedShip* currentShip = [self selectedEquippedShip];

    if (currentShip != nil) {
        DockShip* ship = currentShip.ship;
        DockShip* counterpart = [ship counterpart];
        DockSquad* squad = [self selectedSquad];
        DockEquippedShip* existing = [squad containsShip: counterpart];

        if (existing != nil && [counterpart isUnique]) {
            [self explainCantPromoteShip: counterpart];
        } else {
            [currentShip changeShip: counterpart];
        }
    }
}

-(BOOL)updateChangeShipItem:(NSMenuItem*)menuItem equippedShip:(DockEquippedShip*)equippedShip
{
    DockShip* ship = [self selectedShip];

    if (ship && equippedShip) {
        [menuItem setTitle: [NSString stringWithFormat: @"Change '%@' to '%@'", equippedShip.descriptiveTitle, ship.descriptiveTitle]];
    } else {
        [menuItem setTitle: @"Change Ship"];
        return NO;
    }
    return YES;
}

-(BOOL)validateMenuItem:(NSMenuItem*)menuItem
{
    SEL action = [menuItem action];

    if (action == @selector(resetFactionFilter:)) {
        [menuItem setState: _factionName == nil ? NSOnState: NSOffState];
    } else if (action == @selector(filterToFaction:)) {
        BOOL isCurrentFilter = [menuItem.title isEqualToString: _factionName];
        [menuItem setState: isCurrentFilter ? NSOnState: NSOffState];
    } else if (action == @selector(resetUpgradeFilter:)) {
        [menuItem setState: _upType == nil ? NSOnState: NSOffState];
    } else if (action == @selector(filterToUpgradeType:)) {
        BOOL isCurrentFilter = [menuItem.title isEqualToString: _upType];
        [menuItem setState: isCurrentFilter ? NSOnState: NSOffState];
    } else if (action == @selector(addSelectedShip:)) {
        DockShip* ship = [self selectedShip];
        DockSquad* squad = [self selectedSquad];

        if (ship && squad) {
            [menuItem setTitle: [NSString stringWithFormat: @"Add '%@' to '%@'", ship.descriptiveTitle, squad.name]];
        } else {
            [menuItem setTitle: @"Add Ship to Squad"];
            return NO;
        }
    } else if (action == @selector(deleteSelectedShip:)) {
        DockEquippedShip* ship = [self selectedEquippedShip];
        DockSquad* squad = [self selectedSquad];

        if (ship && squad) {
            [menuItem setTitle: [NSString stringWithFormat: @"Remove '%@' from '%@'", ship.descriptiveTitle, squad.name]];
        } else {
            [menuItem setTitle: @"Delete Ship from Squad"];
            return NO;
        }
    } else if (action == @selector(changeSelectedShip:)) {
        DockEquippedShip* equippedShip = [self selectedEquippedShip];
        return [self updateChangeShipItem: menuItem equippedShip: equippedShip];
    } else if (action == @selector(addSelectedUpgradeAction:)) {
        DockEquippedShip* ship = [self selectedEquippedShip];
        DockUpgrade* upgrade = [self selectedUpgrade];

        if (ship && upgrade) {
            [menuItem setTitle: [NSString stringWithFormat: @"Add '%@' to '%@'", upgrade.title, ship.descriptiveTitle]];
            return YES;
        } else {
            [menuItem setTitle: @"Add Upgrade to Ship"];
            return NO;
        }
    } else if (action == @selector(deleteSelectedUpgradeAction:)) {
        DockEquippedShip* ship = [self selectedEquippedShip];
        DockEquippedUpgrade* upgrade = [self selectedEquippedUpgrade];

        if (ship && upgrade) {
            [menuItem setTitle: [NSString stringWithFormat: @"Remove '%@' from '%@'", upgrade.upgrade.title, ship.descriptiveTitle]];
            return YES;
        } else {
            [menuItem setTitle: @"Remove Upgrade from Ship"];
            return NO;
        }
    } else if (action == @selector(toggleUnique:)) {
        DockEquippedShip* currentShip = [self selectedEquippedShip];

        if (currentShip == nil || currentShip.isFighterSquadron) {
            [menuItem setTitle: @"Demote"];
            return NO;
        }

        DockShip* ship = currentShip.ship;
        DockShip* counterpart = [ship counterpart];

        if ([ship isUnique]) {
            [menuItem setTitle: [NSString stringWithFormat: @"Demote to '%@'", counterpart.descriptiveTitle]];
        } else {
            [menuItem setTitle: [NSString stringWithFormat: @"Promote to '%@'", counterpart.descriptiveTitle]];
        }
    } else if (action == @selector(overrideCost:)) {
        DockEquippedUpgrade* upgrade = [self selectedEquippedUpgrade];
        return upgrade && ![upgrade.upgrade isCaptain];
    } else if (action == @selector(removeOverride:)) {
        DockEquippedUpgrade* upgrade = [self selectedEquippedUpgrade];
        return upgrade && [upgrade costIsOverridden];
    } else if (action == @selector(checkForNewDataFile:)) {
        return _updater == nil;
    } else if (action == @selector(revertDataFile:)) {
        NSString* pathToDataFile = [self pathToDataFile];
        NSString* appPath = [[DockAppDelegate applicationFilesDirectory] path];
        return [pathToDataFile hasPrefix: appPath];
    } else if (action == @selector(toggleExpandedRows:)) {
        [menuItem setState: _expandedRows ? NSOnState: NSOffState];
    } else if (action == @selector(showInList:)) {
        BOOL detailsIsFirstResponder = _squadDetailView.window.firstResponder == _squadDetailView;
        return detailsIsFirstResponder && [_squadDetailController selectedObjects].count > 0;
    }

    return YES;
}

-(IBAction)cleanupDatabaseUnused:(id)sender
{
    NSLog(@"cleanupDatabase");
    NSArray* dupNames = @[
        @"Attack Pattern Delta",
        @"Cloaking Device",
        @"Jadzia Dax",
        @"Miles O'Brien",
        @"Defense Condition One",
        @"Barrage of Fire",
                        ];

    for (NSString* name in dupNames) {
        NSArray* upgrades = [DockUpgrade findUpgrades: name context: _managedObjectContext];

        if (upgrades.count > 1) {
            id cmp = ^(id a, id b) {
                return [[b externalId] compare: [a externalId]];
            };
            upgrades = [upgrades sortedArrayUsingComparator: cmp];
            NSIndexSet* indexSet = [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(1, upgrades.count - 1)];
            NSArray* onesToReplace = [upgrades objectsAtIndexes: indexSet];
            DockUpgrade* oneTrueUpgrade = upgrades[0];

            for (id u in onesToReplace) {
                NSLog(@"u = %@ %@", u, [u externalId]);
                NSArray* squads = [DockSquad allSquads: _managedObjectContext];

                for (DockSquad* squad in squads) {
                    for (DockEquippedShip* ship in squad.equippedShips) {
                        for (DockEquippedUpgrade* eu in ship.sortedUpgrades) {
                            if (eu.upgrade == u) {
                                NSLog(@"need to replace upgrade in %@", eu);
                                eu.upgrade = oneTrueUpgrade;
                            }
                        }
                    }
                }
                [_managedObjectContext deleteObject: u];
            }
        }
    }
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Captain" inManagedObjectContext: _managedObjectContext];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"externalId == %@", @"2025"];
    [request setPredicate: predicateTemplate];
    NSError* err;
    NSArray* dupBreens = [_managedObjectContext executeFetchRequest: request error: &err];

    if (dupBreens.count > 1) {
        NSIndexSet* indexSet = [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(1, dupBreens.count - 1)];
        NSArray* onesToReplace = [dupBreens objectsAtIndexes: indexSet];
        NSArray* squads = [DockSquad allSquads: _managedObjectContext];
        id oneTrueBreen = dupBreens[0];

        for (id dupBreen in onesToReplace) {
            for (DockSquad* squad in squads) {
                for (DockEquippedShip* ship in squad.equippedShips) {
                    if (ship.equippedCaptain.upgrade == dupBreen) {
                        NSLog(@"need to replace captain in %@", ship);
                        ship.equippedCaptain.upgrade = oneTrueBreen;
                    }
                }
            }
            [_managedObjectContext deleteObject: dupBreen];
        }
    }

    [_managedObjectContext commitEditing];
}

-(IBAction)showInspector:(id)sender
{
    [_inspector show];
}

-(IBAction)printFleetBuildSheet:(id)sender
{
    DockSquad* squad = [self selectedSquad];
    if (squad.equippedShips.count > 10) {
        [self whineToUser: kSquadTooLargeToPrint];
    } else {
        if ([squad flagshipIsNotAssigned]) {
            [self whineToUser: kFlagshipPrintingError];
        } else {
            [_fleetBuildSheet2 show: [self selectedSquad]];
        }
    }
}

-(IBAction)editNotes:(id)sender
{
    [_noteEditor show: [self selectedSquad]];
}

-(IBAction)copy:(id)sender
{
    NSString* s = nil;
    id responder = [_window firstResponder];
    NSString* ident = [responder identifier];
    if ([ident isEqualToString: @"setsTable"]) {
        s = [self.setsTabController copySelectedSet];
    } else {
        s = [[self selectedSquad] asPlainTextFormat];
    }
    if (s) {
        NSPasteboard* pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard clearContents];
        NSArray* objectsToCopy = @[s];
        [pasteboard writeObjects: objectsToCopy];
    }
}

-(void)updateInfo:(NSData*)downloadedData
{
    NSURL* importURL = [DockAppDelegate applicationFilesDirectory];
    importURL = [importURL URLByAppendingPathComponent: @"Data.xml"];
    NSFileManager* fm = [NSFileManager defaultManager];
    [fm removeItemAtURL: importURL error: nil];
    [downloadedData writeToURL: importURL atomically: NO];
    [self loadData];
}

-(void)handleNewData:(NSString*)remoteVersion path:(NSData*)downloadData error:(NSError*)error
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* currentVersion = [defaults stringForKey: kSpaceDockCurrentDataVersionKey];
    NSAlert* alert = [[NSAlert alloc] init];
    if (![currentVersion isEqualToString: remoteVersion]) {
        [alert addButtonWithTitle: @"Update"];
        [alert addButtonWithTitle: @"Cancel"];
        [alert setMessageText: @"New Game Data Available"];
        NSString* info = [NSString stringWithFormat: @"Current data version is %@ and version %@ is available. Would you like to update?", currentVersion, remoteVersion];
        [alert setInformativeText: info];
        [alert setAlertStyle: NSInformationalAlertStyle];
        id completion = ^(NSModalResponse returnCode) {
            [self updateInfo: downloadData];
        };
        [alert beginSheetModalForWindow: [self window]
                          completionHandler: completion];
    } else {
        [alert addButtonWithTitle: @"OK"];
        [alert setMessageText: @"Game Data Up to Date"];
        NSString* info = [NSString stringWithFormat: @"Installed data is version %@ and is the most recent version available.", currentVersion];
        [alert setInformativeText: info];
        [alert setAlertStyle: NSInformationalAlertStyle];
        id completion = ^(NSModalResponse returnCode) {
        };
        [alert beginSheetModalForWindow: [self window]
                          completionHandler: completion];
    }
    _updater = nil;
}

-(IBAction)checkForNewDataFile:(id)sender
{
    if (_updater == nil) {
        _updater = [[DockDataUpdater alloc] init];
        [_updater checkForNewData: ^(NSString* remoteVersion, NSData* downloadData, NSError* error) {
            [self handleNewData: remoteVersion path: downloadData error: error];
        }];
    }
}

-(IBAction)overrideCost:(id)sender
{
    DockEquippedUpgrade* upgrade = [self selectedEquippedUpgrade];
    [_overrideEditor show: upgrade];
}

-(IBAction)removeOverride:(id)sender
{
    DockEquippedUpgrade* upgrade = [self selectedEquippedUpgrade];
    if (upgrade) {
        [upgrade removeCostOverride];
    }
}

-(IBAction)toggleExpandedRows:(id)sender
{
    self.expandedRows = !self.expandedRows;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool: _expandedRows forKey: kExpandedRows];
}

static void doSelectIndex(NSInteger index, NSArrayController* controller, NSTableView* table)
{
    if (index != NSNotFound) {
        [controller setSelectionIndex: index];
        [table selectRowIndexes: [NSIndexSet indexSetWithIndex: index] byExtendingSelection: NO];
        [table scrollRowToVisible: index];
    }
}

-(void)showItemInternal:(NSDictionary*)d
{
    NSArrayController* controller = d[@"controller"];
    NSTableView* table = d[@"table"];
    NSInteger index = [d[@"index"] intValue];
    doSelectIndex(index, controller, table);
}

-(void)showItemAfterReset:(NSDictionary*)d
{
    NSArrayController* controller = d[@"controller"];
    NSTableView* table = d[@"table"];
    id item = d[@"item"];
    NSArray* objects = [controller arrangedObjects];
    NSInteger index = [objects indexOfObject: item];
    doSelectIndex(index, controller, table);
}

-(void)showItem:(id)item controller:(NSArrayController*)controller table:(NSTableView*)table
{
    if (controller && item && table) {
        NSArray* objects = [controller arrangedObjects];
        NSInteger index = [objects indexOfObject: item];
        if (index == NSNotFound) {
            NSDictionary* d2 = @{
                @"table" : table,
                @"controller": controller,
                @"item": item
            };
            [self performSelector: @selector(showItemAfterReset:) withObject: d2 afterDelay: 0];
        }
        
        NSDictionary* d = @{
            @"table" : table,
            @"controller": controller,
            @"index": [NSNumber numberWithInt: (int)index]
        };
        [self performSelector: @selector(showItemInternal:) withObject: d afterDelay: 0];
    }
}

-(void)showInList:(id)target targetShip:(DockEquippedShip*)targetShip
{
    if (target == targetShip) {
        DockShip* ship = targetShip.ship;
        [DockTabController makeOneControllerShowItem: ship];
    } else if ([target isKindOfClass: [DockEquippedFlagship class]]) {
        DockFlagship* flagship = [target flagship];
        [DockTabController makeOneControllerShowItem: flagship];
    } else {
        DockEquippedUpgrade* eu = target;
        DockUpgrade* upgrade = eu.upgrade;
        if (![upgrade isPlaceholder]) {
            [DockTabController makeOneControllerShowItem: upgrade];
        }
    }
}

-(IBAction)showInList:(id)sender
{
    id target = [[_squadDetailController selectedObjects] objectAtIndex: 0];
    DockEquippedShip* targetShip = [self selectedEquippedShip];
    [self showInList: target targetShip: targetShip];
}

-(IBAction)showClickedInList:(id)sender
{
    id target = [self clickedSquadItem];
    DockEquippedShip* targetShip = [self clickedEquippedShip];
    [self showInList: target targetShip: targetShip];
}

-(IBAction)changeClickedShip:(id)sender
{
    DockEquippedShip* targetShip = [self clickedEquippedShip];
    DockShip* ship = [self selectedShip];
    [targetShip changeShip: ship];
}

-(IBAction)removeFlagship:(id)sender
{
    DockEquippedShip* targetShip = [self clickedEquippedShip];
    [targetShip removeFlagship];
}

-(IBAction)deleteClicked:(id)sender
{
    [self deleteTarget: [self clickedSquadItem] targetShip: [self clickedEquippedShip]];
}

-(IBAction)filterToClickedFaction:(id)sender
{
    [self updateFactionFilter: [[[self clickedEquippedShip] ship] faction]];
}

-(IBAction)filterToClickedUpgradeType:(id)sender
{
    DockUpgrade* upgrade = [[self clickedSquadItem] upgrade];
    [self updateUpgradeTypeFilter: [upgrade upType]];
}

-(IBAction)filterToClickedFactionAndUpgradeType:(id)sender
{
    [_tabView selectTabViewItemWithIdentifier: @"upgrades"];
    [self filterToClickedFaction:sender];
    [self filterToClickedUpgradeType:sender];
}

-(IBAction)overrideClickedCost:(id)sender
{
    DockEquippedUpgrade* upgrade = [self clickedSquadItem];
    [_overrideEditor show: upgrade];
}

-(IBAction)removeClickedOverride:(id)sender
{
    DockEquippedUpgrade* upgrade = [self clickedSquadItem];
    if (upgrade) {
        [upgrade removeCostOverride];
    }
}

static void addDeleteItem(NSMenu* menu)
{
    NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle: @"Delete" action: @selector(deleteClicked:) keyEquivalent: @""];
    [menu addItem: menuItem];
}

static void addFilterToFactionItem(NSMenu* menu, NSString* faction)
{
    if (faction == nil) {
        NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle: @"Filter to Faction" action: 0 keyEquivalent: @""];
        [menuItem setEnabled: NO];
        [menu addItem: menuItem];
        return;
    }
    NSString* menuTitle = [NSString stringWithFormat: @"Filter to Faction “%@”", faction];
    NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle: menuTitle action: @selector(filterToClickedFaction:) keyEquivalent: @""];
    [menu addItem: menuItem];
}

static void addFilterToTypeItem(NSMenu* menu, NSString* upType)
{
    NSString* menuTitle = [NSString stringWithFormat: @"Filter to Type “%@”", upType];
    NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle: menuTitle action: @selector(filterToClickedUpgradeType:) keyEquivalent: @""];
    [menu addItem: menuItem];
}

static void addFilterToFactionAndTypeItem(NSMenu* menu, NSString* faction, NSString* upType)
{
    if (faction == nil) {
        NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle: @"Filter to Faction and Type" action: 0 keyEquivalent: @""];
        [menuItem setEnabled: NO];
        [menu addItem: menuItem];
        return;
    }
    NSString* menuTitle = [NSString stringWithFormat: @"Filter to Faction “%@” and Type “%@”", faction, upType];
    NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle: menuTitle action: @selector(filterToClickedFactionAndUpgradeType:) keyEquivalent: @""];
    [menu addItem: menuItem];
}

static void addShowDetailsItem(NSMenu* menu)
{
    NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle: @"Show in List" action: @selector(showClickedInList:) keyEquivalent: @""];
    [menu addItem: menuItem];
}

static void addOverrideItems(NSMenu* menu)
{
    NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle: @"Override Cost..." action: @selector(overrideClickedCost:) keyEquivalent: @""];
    [menu addItem: menuItem];
    menuItem = [[NSMenuItem alloc] initWithTitle: @"Remove Upgrade Cost Override" action: @selector(removeClickedOverride:) keyEquivalent: @""];
    [menu addItem: menuItem];
}

-(void)addChangeShipItem:(NSMenu *)menu
{
    DockEquippedShip* ship = [self clickedEquippedShip];
    NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle: @"Change Ship" action: @selector(changeClickedShip:) keyEquivalent: @""];
    BOOL enabled = [self updateChangeShipItem: menuItem equippedShip: ship];
    if (enabled) {
        [menuItem setEnabled: enabled];
        [menuItem setTarget: self];
        [menu addItem: menuItem];
    } else {
        menuItem.target = nil;
    }
}

void addRemoveFlagshipItem(NSMenu *menu)
{
    NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle: @"Remove Flagship" action: @selector(removeFlagship:) keyEquivalent: @""];
    [menu addItem: menuItem];
    [menuItem setEnabled: YES];
}

- (void)menuNeedsUpdate:(NSMenu*)menu
{
    [menu removeAllItems];
    id target = [self clickedSquadItem];
    DockEquippedShip* targetShip = [self clickedEquippedShip];
    if (target != nil) {
        if (target == targetShip) {
            [self addChangeShipItem:menu];
            DockEquippedShip* ship = [self clickedEquippedShip];
            addShowDetailsItem(menu);
            addFilterToFactionItem(menu, ship.ship.faction);
            addDeleteItem(menu);
        } else if ([target isKindOfClass: [DockEquippedFlagship class]]) {
            addShowDetailsItem(menu);
            addRemoveFlagshipItem(menu);
        } else {
            DockEquippedUpgrade* eu = target;
            if (!eu.isPlaceholder) {
                addShowDetailsItem(menu);
            }
            addFilterToFactionItem(menu, eu.equippedShip.ship.faction);
            if (!eu.upgrade.isCaptain) {
                addFilterToTypeItem(menu, eu.upgrade.upType);
                addFilterToFactionAndTypeItem(menu, eu.equippedShip.ship.faction, eu.upgrade.upType);
                if (!eu.isPlaceholder) {
                    addOverrideItems(menu);
                }
            }
            if (!eu.isPlaceholder) {
                addDeleteItem(menu);
            }
        }
    }
}

-(IBAction)showPreferences:(id)sender
{
    [_preferencesWindow makeKeyAndOrderFront: sender];
}

-(void)saveAlertDidEnd:(NSAlert*)alert returnCode:(NSInteger)returnCode contextInfo:(void*)contextInfo
{
    [[alert window] orderOut: self];
}

-(void)saveSquadsToDisk:(NSString*)targetPath
{
    NSArray* allSquads = [DockSquad allSquads: _managedObjectContext];
    id squadExportComparator = ^(DockSquad* a, DockSquad* b) {
        NSComparisonResult result = [a.name caseInsensitiveCompare: b.name];
        if (result == NSOrderedSame) {
            result = [a.uuid compare: b.uuid];
        }
        return result;
    };
    allSquads = [allSquads sortedArrayUsingComparator: squadExportComparator];
    NSMutableArray* squadsForJSONArray = [NSMutableArray arrayWithCapacity: allSquads.count];
    for (DockSquad* squad in allSquads) {
        [squadsForJSONArray addObject: [squad asJSON]];
    }

    NSError* error;
    NSData* squadData = [NSJSONSerialization dataWithJSONObject: squadsForJSONArray options: NSJSONWritingPrettyPrinted error: &error];
    if (squadData != nil) {
        [squadData writeToFile: targetPath atomically: YES];
    } else {
        NSAlert* alert = [NSAlert alertWithError: error];
        [alert beginSheetModalForWindow: [self window]
                          modalDelegate: self
                         didEndSelector: @selector(saveAlertDidEnd:returnCode:contextInfo:)
                            contextInfo: nil];
    }
}


-(IBAction)exportAllSquads:(id)sender
{
    [self.managedObjectContext save: nil];
    _currentSavePanel = [NSSavePanel savePanel];
    _currentSavePanel.allowedFileTypes = @[kSpaceDockSquadListFileExtension];
    NSString* defaultName = [@"All Squads" stringByAppendingPathExtension: kSpaceDockSquadListFileExtension];
    [_currentSavePanel setNameFieldStringValue: defaultName];

    id completionHandler = ^(NSInteger v) {
        if (v == NSFileHandlingPanelOKButton) {
            NSURL* fileUrl = _currentSavePanel.URL;
            [self saveSquadsToDisk: [fileUrl path]];
        }
        
        _currentSavePanel = nil;
    };
    
    [_currentSavePanel beginSheetModalForWindow: self.window completionHandler: completionHandler];
}

-(IBAction)importAllSquads:(id)sender
{
    NSOpenPanel* importPanel = [NSOpenPanel openPanel];
    importPanel.allowedFileTypes = @[kSpaceDockSquadListFileExtension];
    [importPanel beginSheetModalForWindow: self.window completionHandler: ^(NSInteger v) {
         if (v == NSFileHandlingPanelOKButton) {
             NSURL* fileUrl = importPanel.URL;
             DockSquadImporterMac* importer = [[DockSquadImporterMac alloc] initWithPath: [fileUrl path] context: self.managedObjectContext];
             [importer examineImport: self.window];
         }
     }

    ];
}

-(void)exportDataModelTo:(NSString*)targetFolder
{
    DockDataModelExporter* exporter = [[DockDataModelExporter alloc] initWithContext: _managedObjectContext];
    NSError* error;
    if (![exporter doExport: targetFolder error: &error]) {
        [[NSApplication sharedApplication] presentError: error];
    }
}

-(IBAction)exportDataModel:(id)sender
{
    NSString* kDataModelExportTargetFolder = @"dataModelExportTargetFolder";
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* targetFolder = [defaults stringForKey: kDataModelExportTargetFolder];
    NSUInteger modifierFlags = [NSEvent modifierFlags];
    if (targetFolder == nil || ((modifierFlags & NSAlternateKeyMask) != 0)) {
        NSOpenPanel* openPanel = [NSOpenPanel openPanel];
        openPanel.canChooseDirectories = YES;
        openPanel.canChooseFiles = NO;
        openPanel.canCreateDirectories = YES;
        [openPanel beginSheetModalForWindow: self.window completionHandler: ^(NSInteger v) {
            if (v == NSFileHandlingPanelOKButton) {
                NSURL* fileUrl = openPanel.URL;
                NSString* target = [fileUrl path];
                [defaults setObject: target forKey: kDataModelExportTargetFolder];
                [self exportDataModelTo: target];
            }
        }];
    } else {
        [self exportDataModelTo: targetFolder];
    }
}

-(IBAction)printBuildMat:(id)sender
{
    _buildMat = [[DockBuildMat alloc] initWithSquad: [self selectedSquad]];
    [_buildMat print];
}

@end
