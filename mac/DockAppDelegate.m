#import "DockAppDelegate.h"

#import "DockCaptain.h"
#import "DockConstants.h"
#import "DockCrew.h"
#import "DockDataFileLoader.h"
#import "DockDataLoader.h"
#import "DockDataUpdater.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedShip.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockErrors.h"
#import "DockFAQViewer.h"
#import "DockFleetBuildSheet.h"
#import "DockInspector.h"
#import "DockNoteEditor.h"
#import "DockOverrideEditor.h"
#import "DockResource.h"
#import "DockSet+Addons.h"
#import "DockShip+Addons.h"
#import "DockSquad+Addons.h"
#import "DockSquad.h"
#import "DockTalent.h"
#import "DockTech.h"
#import "DockUpgrade+Addons.h"
#import "DockUtils.h"
#import "DockWeapon.h"

#import "NSTreeController+Additions.h"

NSString* kWarnAboutUnhandledSpecials = @"warnAboutUnhandledSpecials";
NSString* kInspectorVisible = @"inspectorVisible";

@interface DockAppDelegate ()
@property (strong, nonatomic) DockDataUpdater* updater;
@property (strong, nonatomic) IBOutlet NSArrayController* setsController;
@property (copy, nonatomic) NSArray* allSets;
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
        kInspectorVisible: @NO
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
    } else if ([object isMemberOfClass: [DockSet class]]) {
        [self updateForSelectedSets];
    } else {
        NSLog(@"other change %@ %@", object, change);
    }
}

-(void)setupFactionMenu
{
    NSSet* factionsSet = [DockUpgrade allFactions: _managedObjectContext];
    NSArray* factionsArray = [[factionsSet allObjects] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    int i = 1;

    for (NSString* factionName in factionsArray) {
        [_factionMenu addItemWithTitle: factionName action: @selector(filterToFaction:) keyEquivalent: [NSString stringWithFormat: @"%d", i]];
        i += 1;
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

-(void)applicationDidFinishLaunching:(NSNotification*)aNotification
{
    [self loadData];
    [self updateForSelectedSets];
    [_squadDetailController addObserver: self
                             forKeyPath: @"content"
                                options: 0
                                context: nil];
    NSSortDescriptor* defaultSortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"title" ascending: YES];
    [_shipsTableView setSortDescriptors: @[defaultSortDescriptor]];
    [_captainsTableView setSortDescriptors: @[defaultSortDescriptor]];
    [_upgradesTableView setSortDescriptors: @[defaultSortDescriptor]];
    [_resourcesTableView setSortDescriptors: @[defaultSortDescriptor]];
    [_flagshipsTableView setSortDescriptors: @[defaultSortDescriptor]];
    defaultSortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"externalId" ascending: YES];
    [_setsTableView setSortDescriptors: @[defaultSortDescriptor]];
    defaultSortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"name" ascending: YES];
    [_squadsTableView setSortDescriptors: @[defaultSortDescriptor]];
    [self setupFactionMenu];

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    if ([defaults boolForKey: kInspectorVisible]) {
        [_inspector show];
    }

}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "com.funnyhatsoftware.Space_Dock" in the user's Application Support directory.
+(NSURL*)applicationFilesDirectory
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSURL* appSupportURL = [[fileManager URLsForDirectory: NSApplicationSupportDirectory inDomains: NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent: @"com.funnyhatsoftware.Space_Dock"];
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

    _managedObjectContext = [[NSManagedObjectContext alloc] init];
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

    if (![[self managedObjectContext] save: &error]) {

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

-(void)explainCantAddShip:(DockShip*)ship
{
    NSAlert* alert = [[NSAlert alloc] init];
    NSString* msg = [NSString stringWithFormat: @"Can't add %@ to the selected squadron.", ship.title];
    [alert setMessageText: msg];
    NSString* info = @"This ship is unique and one with the same name already exists in the squadron.";
    [alert setInformativeText: info];
    [alert setAlertStyle: NSInformationalAlertStyle];
    [alert beginSheetModalForWindow: [self window]
                      modalDelegate: self
                     didEndSelector: @selector(alertDidEnd:returnCode:contextInfo:)
                        contextInfo: nil];
}

-(void)explainCantUniqueUpgrade:(NSError*)error
{
    NSDictionary* d = error.userInfo;
    DockEquippedUpgrade* upgrade = d[DockExistingUpgradeKey];

    if (upgrade) {
        [self selectUpgrade: upgrade];
    }

    NSAlert* alert = [[NSAlert alloc] init];
    NSString* msg = d[NSLocalizedDescriptionKey];
    [alert setMessageText: msg];
    NSString* info = d[NSLocalizedFailureReasonErrorKey];
    [alert setInformativeText: info];
    [alert setAlertStyle: NSInformationalAlertStyle];
    [alert beginSheetModalForWindow: [self window]
                      modalDelegate: self
                     didEndSelector: @selector(alertDidEnd:returnCode:contextInfo:)
                        contextInfo: nil];
}

-(void)explainCantAddUpgrade:(DockEquippedShip*)ship upgrade:(DockUpgrade*)upgrade
{
    NSDictionary* reasons = [ship explainCantAddUpgrade: upgrade];
    NSAlert* alert = [[NSAlert alloc] init];
    [alert setMessageText: reasons[@"message"]];
    [alert setInformativeText: reasons[@"info"]];
    [alert setAlertStyle: NSInformationalAlertStyle];
    [alert beginSheetModalForWindow: [self window]
                      modalDelegate: self
                     didEndSelector: @selector(alertDidEnd:returnCode:contextInfo:)
                        contextInfo: nil];
}

-(IBAction)addSquad:(id)sender
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Squad"
                                              inManagedObjectContext: _managedObjectContext];
    DockSquad* squad = [[DockSquad alloc] initWithEntity: entity
                          insertIntoManagedObjectContext: _managedObjectContext];
    [self performSelector: @selector(editNameOfSquad:) withObject: squad afterDelay: 0];
}

-(void)addSelectedShip
{
    NSArray* selectedShips = [_squadsController selectedObjects];

    if (selectedShips.count > 0) {
        DockSquad* squad = selectedShips[0];
        NSArray* shipsToAdd = [_shipsController selectedObjects];

        for (DockShip* ship in shipsToAdd) {
            if ([ship isUnique]) {
                DockEquippedShip* existing = [squad containsShip: ship];

                if (existing != nil) {
                    [self selectShip: existing];
                    [self explainCantAddShip: ship];
                    continue;
                }
            }

            DockEquippedShip* es = [DockEquippedShip equippedShipWithShip: ship];
            [squad addEquippedShip: es];
            [self selectShip: es];
        }
    }
}

-(void)addSelectedShip:(id)sender
{
    [self addSelectedShip];
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

-(id)selectedItem:(NSString*)tabName controller:(NSArrayController*)controller
{
    NSTabViewItem* selectedTab = [_tabView selectedTabViewItem];
    id identifier = selectedTab.identifier;

    if ([identifier isEqualToString: tabName]) {
        NSArray* selected = [controller selectedObjects];

        if (selected.count > 0) {
            return selected[0];
        }
    }

    return nil;
}

-(DockShip*)selectedShip
{
    return [self selectedItem: @"ships" controller: _shipsController];
}

-(DockUpgrade*)selectedUpgrade
{
    return [self selectedItem: @"upgrades" controller: _upgradesController];
}

-(DockEquippedShip*)selectedEquippedShip
{
    NSArray* selectedShips = [_squadDetailController selectedObjects];

    if (selectedShips.count > 0) {
        id target = [[_squadDetailController selectedObjects] objectAtIndex: 0];

        if ([target isKindOfClass: [DockEquippedShip class]]) {
            return target;
        }

        if ([target isMemberOfClass: [DockEquippedUpgrade class]]) {
            DockEquippedUpgrade* upgrade = target;
            return upgrade.equippedShip;
        }
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

-(DockEquippedUpgrade*)addSelectedCaptain:(DockEquippedShip*)targetShip
{
    NSArray* captainsToAdd = [_captainsController selectedObjects];

    if (captainsToAdd.count < 1) {
    } else {
        DockCaptain* captain = captainsToAdd[0];
        DockSquad* squad = [self selectedSquad];
        NSError* error;

        if ([squad canAddCaptain: captain toShip: targetShip error: &error]) {
            return [squad addCaptain: captain toShip: targetShip error: nil];
        } else {
            [self explainCantUniqueUpgrade: error];
        }

        return nil;

    }

    return nil;
}

-(DockEquippedUpgrade*)addSelectedUpgrade:(DockEquippedShip*)targetShip maybeReplace:(DockEquippedUpgrade*)maybeReplace
{
    NSArray* upgradeToAdd = [_upgradesController selectedObjects];
    DockUpgrade* upgrade = upgradeToAdd[0];

    if ([upgrade isUnique]) {
        DockSquad* squad = [self selectedSquad];
        DockEquippedUpgrade* existing = [squad containsUpgradeWithName: upgrade.title];

        if (existing) {
            [self selectUpgrade: existing];
            [self explainCantUniqueUpgrade: nil]; // fixme
            return nil;
        }
    }

    if (![targetShip canAddUpgrade: upgrade]) {
        [self explainCantAddUpgrade: targetShip upgrade: upgrade];
        return nil;
    }

    return [targetShip addUpgrade: upgrade maybeReplace: maybeReplace];
}

-(DockEquippedUpgrade*)addSelectedUpgrade:(DockEquippedShip*)targetShip
{
    return [self addSelectedUpgrade: targetShip maybeReplace: nil];
}

-(void)addSelectedResource
{
    NSArray* selectedResources = [_resourcesController selectedObjects];

    if (selectedResources.count > 0) {
        DockSquad* squad = [self selectedSquad];
        DockResource* resource = selectedResources[0];
        squad.resource = resource;
    }
}

-(void)addSelectedFlagship:(DockEquippedShip*)selectedShip
{
    NSArray* selectedFlagships = [_flagshipsController selectedObjects];

    if (selectedFlagships.count > 0) {
        DockFlagship* flagShip = selectedFlagships[0];
        NSDictionary* info = [selectedShip becomeFlagship: flagShip];
        if (info != nil) {
            NSAlert* alert = [[NSAlert alloc] init];
            [alert setMessageText: info[@"message"]];
            [alert setInformativeText: info[@"info"]];
            [alert setAlertStyle: NSInformationalAlertStyle];
            [alert beginSheetModalForWindow: [self window]
                              modalDelegate: self
                             didEndSelector: @selector(alertDidEnd:returnCode:contextInfo:)
                                contextInfo: nil];
        }
    }
}

-(IBAction)addSelected:(id)sender
{
    NSTabViewItem* selectedTab = [_tabView selectedTabViewItem];
    id identifier = selectedTab.identifier;

    if ([identifier isEqualToString: @"ships"]) {
        [self addSelectedShip];
    } else if ([identifier isEqualToString: @"resources"]) {
        [self addSelectedResource];
    } else {
        DockEquippedShip* selectedShip = [self selectedEquippedShip];
        DockEquippedUpgrade* maybeUpgrade = [self selectedEquippedUpgrade];
        DockEquippedUpgrade* equippedUpgrade = nil;

        if (selectedShip != nil) {
            if ([identifier isEqualToString: @"flagships"]) {
                [self addSelectedFlagship: selectedShip];
                return;
            }
            
            if ([identifier isEqualToString: @"captains"]) {
                equippedUpgrade = [self addSelectedCaptain: selectedShip];
            }

            if ([identifier isEqualToString: @"upgrades"]) {
                equippedUpgrade = [self addSelectedUpgrade: selectedShip maybeReplace: maybeUpgrade];
            }

            if (equippedUpgrade != nil) {
                [self selectUpgrade: equippedUpgrade];
            }
        } else {
            NSAlert* alert = [NSAlert alertWithMessageText: @"You must select a ship before adding a captain or upgrade or designating a flagship."
                                             defaultButton: @"OK"
                                           alternateButton: @""
                                               otherButton: @""
                                 informativeTextWithFormat: @""];
            [alert beginSheetModalForWindow: [self window]
                              modalDelegate: self
                             didEndSelector: @selector(alertDidEnd:returnCode:contextInfo:)
                                contextInfo: nil];
        }
    }
}

-(IBAction)deleteSelected:(id)sender
{
    id target = [[_squadDetailController selectedObjects] objectAtIndex: 0];
    DockEquippedShip* targetShip = [self selectedEquippedShip];

    if (target == targetShip) {
        if (targetShip.flagship != nil) {
            [targetShip removeFlagship];
        } else {
            DockSquad* squad = [[_squadsController selectedObjects] objectAtIndex: 0];
            [squad removeEquippedShip: targetShip];
        }
    } else {
        [targetShip removeUpgrade: target establishPlaceholders: YES];
        [self selectShip: targetShip];
    }
}

-(void)editNameOfSquad:(DockSquad*)theSquad
{
    NSArray* objects = [_squadsController arrangedObjects];
    NSInteger row = [objects indexOfObject: theSquad];

    if (row != NSNotFound) {
        [_squadsTableView becomeFirstResponder];
        [_squadsController setSelectionIndex: row];
        [_squadsTableView editColumn: 0 row: row withEvent: nil select: YES];
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

-(void)updatePredicates
{
    NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"any sets.externalId in %@", _includedSets];
    _resourcesController.fetchPredicate = predicateTemplate;

    if (_factionName == nil) {
        _shipsController.fetchPredicate = predicateTemplate;
        _captainsController.fetchPredicate = predicateTemplate;
        _flagshipsController.fetchPredicate = predicateTemplate;
        _flagshipsController.fetchPredicate = predicateTemplate;
        predicateTemplate = [NSPredicate predicateWithFormat: @"not upType like 'Captain' and not placeholder == YES and any sets.externalId in %@", _includedSets];
        _upgradesController.fetchPredicate = predicateTemplate;
    } else {
        NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"faction = %@ and any sets.externalId in %@", _factionName, _includedSets];
        _shipsController.fetchPredicate = predicateTemplate;
        _captainsController.fetchPredicate = predicateTemplate;
        predicateTemplate = [NSPredicate predicateWithFormat: @"not upType like 'Captain' and not placeholder == YES and faction = %@ and any sets.externalId in %@", _factionName, _includedSets];
        _upgradesController.fetchPredicate = predicateTemplate;
        predicateTemplate = [NSPredicate predicateWithFormat: @"faction in %@ and any sets.externalId in %@", @[_factionName, @"Independent"], _includedSets];
        _flagshipsController.fetchPredicate = predicateTemplate;
    }
}

-(IBAction)resetFactionFilter:(id)sender
{
    _factionName = nil;
    [self updatePredicates];
}

-(IBAction)filterToFaction:(id)sender
{
    _factionName = [sender title];
    [self updatePredicates];
}

-(void)updateForSelectedSets
{
    NSArray* includedSets = [DockSet includedSets: _managedObjectContext];
    NSMutableArray* includedIds = [[NSMutableArray alloc] init];

    for (DockSet* set in includedSets) {
        [includedIds addObject: [set externalId]];
    }
    _includedSets = [NSArray arrayWithArray: includedIds];
    [self updatePredicates];
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

-(BOOL)validateMenuItem:(NSMenuItem*)menuItem
{
    SEL action = [menuItem action];

    if (action == @selector(resetFactionFilter:)) {
        [menuItem setState: _factionName == nil ? NSOnState: NSOffState];
    } else if (action == @selector(filterToFaction:)) {
        BOOL isCurrentFilter = [menuItem.title isEqualToString: _factionName];
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
        DockShip* ship = [self selectedShip];
        DockEquippedShip* equippedShip = [self selectedEquippedShip];

        if (ship && equippedShip) {
            [menuItem setTitle: [NSString stringWithFormat: @"Change '%@' to '%@'", equippedShip.descriptiveTitle, ship.descriptiveTitle]];
        } else {
            [menuItem setTitle: @"Change Ship"];
            return NO;
        }
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

        if (currentShip == nil) {
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

-(IBAction)logItem:(id)sender
{
    NSTabViewItem* selectedTab = [_tabView selectedTabViewItem];
    id identifier = selectedTab.identifier;
    id target = nil;

    if ([identifier isEqualToString: @"ships"]) {
        NSArray* shipsToAdd = [_shipsController selectedObjects];
        target = shipsToAdd[0];
    } else if ([identifier isEqualToString: @"resources"]) {
        NSArray* selectedResources = [_resourcesController selectedObjects];
        target = selectedResources[0];
    } else if ([identifier isEqualToString: @"captains"]) {
        NSArray* captainsToAdd = [_captainsController selectedObjects];
        target = captainsToAdd[0];
    } else if ([identifier isEqualToString: @"upgrades"]) {
        NSArray* upgradeToAdd = [_upgradesController selectedObjects];
        target = upgradeToAdd[0];
    }

    if (target != nil) {
        NSLog(@"target = %@, id = %@", target, [target externalId]);
    }
}

-(IBAction)showInspector:(id)sender
{
    [_inspector show];
}

-(IBAction)printFleetBuildSheet:(id)sender
{
    DockSquad* squad = [self selectedSquad];
    if (squad.equippedShips.count > 4) {
        [self whineToUser: @"This version of Space Dock cannot print build sheets for squads with more than four ships."];
    } else {
        [_fleetBuildSheet2 show: [self selectedSquad]];
    }
}

-(IBAction)editNotes:(id)sender
{
    [_noteEditor show: [self selectedSquad]];
}

-(IBAction)copy:(id)sender
{
    NSPasteboard* pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    NSArray* objectsToCopy = @[[[self selectedSquad] asPlainTextFormat]];
    [pasteboard writeObjects: objectsToCopy];
}

-(IBAction)showFAQ:(id)sender
{
    [_faqViewer show];
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

-(IBAction)includeSelectedSets:(id)sender
{
    NSArray* selectedItems = [_setsController selectedObjects];
    for (DockSet* set in selectedItems) {
        set.include = @YES;
    }
}

-(IBAction)excludeSelectedSets:(id)sender
{
    NSArray* selectedItems = [_setsController selectedObjects];
    for (DockSet* set in selectedItems) {
        set.include = @NO;
    }
}

@end
