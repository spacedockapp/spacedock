#import "DockAppDelegate.h"

#import "DockCaptain.h"
#import "DockCrew.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedShip.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockFleetBuildSheet.h"
#import "DockInspector.h"
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

-(void)handleError:(NSError*)error
{
}

-(NSDictionary*)convertNode:(NSXMLNode*)node
{
    NSMutableDictionary* d = [NSMutableDictionary dictionaryWithCapacity: 0];

    for (NSXMLNode* c in node.children) {
        [d setObject: [c objectValue] forKey: [c name]];
    }
    return [NSDictionary dictionaryWithDictionary: d];
}

static id processAttribute(id v, NSInteger aType)
{
    switch (aType) {
    case NSInteger16AttributeType:
        v = [NSNumber numberWithInt: [v intValue]];
        break;

    case NSBooleanAttributeType:
        v = [NSNumber numberWithBool: [v isEqualToString: @"Y"]];
        break;

    case NSStringAttributeType:
        v = [v stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        break;
    }
    return v;
}

static NSMutableDictionary* createExistingItemsLookup(NSManagedObjectContext* context, NSEntityDescription* entity)
{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSError* err;
    NSArray* existingItems = [context executeFetchRequest: request error: &err];
    NSMutableDictionary* existingItemsLookup = [NSMutableDictionary dictionaryWithCapacity: existingItems.count];

    for (id existingItem in existingItems) {
        NSString* externalId = [existingItem externalId];
        if (externalId) {
            existingItemsLookup[externalId] = existingItem;
        }
    }

    return existingItemsLookup;
}

-(void)loadItems:(NSXMLDocument*)xmlDoc itemClass:(Class)itemClass entityName:(NSString*)entityName xpath:(NSString*)xpath targetType:(NSString*)targetType
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: entityName inManagedObjectContext: _managedObjectContext];
    NSError* err;
    NSMutableDictionary* existingItemsLookup = createExistingItemsLookup(_managedObjectContext, entity);

    NSArray* nodes = [xmlDoc nodesForXPath: xpath error: &err];
    NSDictionary* attributes = [NSDictionary dictionaryWithDictionary: [entity attributesByName]];

    for (NSXMLNode* oneNode in nodes) {
        NSDictionary* d = [self convertNode: oneNode];
        NSString* nodeType = d[@"Type"];

        if (targetType == nil || [nodeType isEqualToString: targetType]) {
            NSString* externalId = d[@"Id"];
            id c = existingItemsLookup[externalId];

            if (c == nil) {
                c = [[itemClass alloc] initWithEntity: entity insertIntoManagedObjectContext: _managedObjectContext];
            } else {
                [existingItemsLookup removeObjectForKey: externalId];
            }

            for (NSString* key in d) {
                NSString* modifiedKey;

                if ([key isEqualToString: @"Id"]) {
                    modifiedKey = @"externalId";
                } else if ([key isEqualToString: @"Battlestations"]) {
                    modifiedKey = @"battleStations";
                } else if ([key isEqualToString: @"Type"]) {
                    modifiedKey = @"upType";
                } else {
                    modifiedKey = makeKey(key);
                }

                NSAttributeDescription* desc = [attributes objectForKey: modifiedKey];

                if (desc != nil) {
                    id v = [d valueForKey: key];
                    NSInteger aType = [desc attributeType];
                    v = processAttribute(v, aType);
                    [c setValue: v forKey: modifiedKey];
                }
            }
            NSString* setValue = [d objectForKey: @"Set"];
            NSArray* sets = [setValue componentsSeparatedByString: @","];
            for (NSString* rawSet in sets) {
                NSString* setId = [rawSet stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                DockSet* theSet = [DockSet setForId:setId context:_managedObjectContext];
                [theSet addItemsObject: c];
            }
        }
    }
}

NSString* makeKey(NSString *key)
{
    NSString* lowerFirst = [[key substringToIndex: 1] lowercaseString];
    NSString* rest = [key substringFromIndex: 1];
    return [lowerFirst stringByAppendingString: rest];
}

-(void)loadSets:(NSXMLDocument*)xmlDoc
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Set" inManagedObjectContext: _managedObjectContext];
    NSError* err;
    NSMutableDictionary* existingItemsLookup = createExistingItemsLookup(_managedObjectContext, entity);
    NSArray* elements = [xmlDoc nodesForXPath: @"/Data/Sets/Set" error: &err];

    for (NSXMLElement* oneElement in elements) {
        NSString* externalId = [[oneElement attributeForName: @"id"] stringValue];
        DockSet* c = existingItemsLookup[externalId];

        if (c == nil) {
            c = [[DockSet alloc] initWithEntity: entity insertIntoManagedObjectContext: _managedObjectContext];
        }

        [c setExternalId: externalId];
        [c setProductName: [oneElement stringValue]];
        NSString* name = [[oneElement attributeForName: @"overallSetName"] stringValue];
        [c setName: name];
    }

    for (DockSet* set in [DockSet allSets: _managedObjectContext]) {
        [set addObserver: self forKeyPath: @"include" options: 0 context: 0];
    }
}


-(void)validateSpecials
{
    NSSet* specials = allAttributes(_managedObjectContext, @"Upgrade", @"Special");
    specials = [specials setByAddingObjectsFromSet: allAttributes(_managedObjectContext, @"Resource", @"Special")];
    NSArray* handledSpecials = @[
        @"BaselineTalentCostToThree",
        @"CrewUpgradesCostOneLess",
        @"costincreasedifnotromulansciencevessel",
        @"WeaponUpgradesCostOneLess",
        @"costincreasedifnotbreen",
        @"UpgradesIgnoreFactionPenalty",
        @"CaptainAndTalentsIgnoreFactionPenalty",
        @"PenaltyOnShipOtherThanDefiant",
        @"PlusFivePointsNonJemHadarShips",
        @"NoPenaltyOnFederationOrBajoranShip",
        @"OneDominionUpgradeCostsMinusTwo",
        @"OnlyJemHadarShips"
                               ];
    NSMutableSet* unhandledSpecials = [[NSMutableSet alloc] initWithSet: specials];
    [unhandledSpecials minusSet: [NSSet setWithArray: handledSpecials]];

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

-(NSXMLDocument*)loadDataFile
{
    NSString* file = [[NSBundle mainBundle] pathForResource: @"Data" ofType: @"xml"];
    NSXMLDocument* xmlDoc;
    NSError* err = nil;
    NSURL* furl = [NSURL fileURLWithPath: file];

    if (!furl) {
        NSLog(@"Can't create an URL from file %@.", file);
        return nil;
    }

    xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL: furl
                                                  options: (NSXMLNodePreserveWhitespace | NSXMLNodePreserveCDATA)
                                                    error: &err];

    if (xmlDoc == nil) {
        xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL: furl
                                                      options: NSXMLDocumentTidyXML
                                                        error: &err];
    }

    if (xmlDoc == nil) {
        if (err) {
            [self handleError: err];
        }

        return nil;
    }

    if (err) {
        [self handleError: err];
    }

    return xmlDoc;
}

-(void)loadData
{
    NSXMLDocument* xmlDoc = [self loadDataFile];

    if (xmlDoc != nil) {
        [self loadSets: xmlDoc];
        [self loadItems: xmlDoc itemClass: [DockShip class] entityName: @"Ship" xpath: @"/Data/Ships/Ship" targetType: nil];
        [self loadItems: xmlDoc itemClass: [DockCaptain class] entityName: @"Captain" xpath: @"/Data/Captains/Captain" targetType: nil];
        [self loadItems: xmlDoc itemClass: [DockWeapon class] entityName: @"Weapon" xpath: @"/Data/Upgrades/Upgrade" targetType: @"Weapon"];
        [self loadItems: xmlDoc itemClass: [DockTalent class] entityName: @"Talent" xpath: @"/Data/Upgrades/Upgrade" targetType: @"Talent"];
        [self loadItems: xmlDoc itemClass: [DockCrew class] entityName: @"Crew" xpath: @"/Data/Upgrades/Upgrade" targetType: @"Crew"];
        [self loadItems: xmlDoc itemClass: [DockTech class] entityName: @"Tech" xpath: @"/Data/Upgrades/Upgrade" targetType: @"Tech"];
        [self loadItems: xmlDoc itemClass: [DockResource class] entityName: @"Resource" xpath: @"/Data/Resources/Resource" targetType: @"Resource"];
        [self validateSpecials];
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
-(NSURL*)applicationFilesDirectory
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
    NSURL* applicationFilesDirectory = [self applicationFilesDirectory];
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

-(void)explainCantUniqueUpgrade:(DockUpgrade*)upgrade
{
    NSAlert* alert = [[NSAlert alloc] init];
    NSString* msg = [NSString stringWithFormat: @"Can't add %@ to the selected squadron.", upgrade.title];
    [alert setMessageText: msg];
    NSString* info = @"This upgrade is unique and one with the same name already exists in the squadron.";
    [alert setInformativeText: info];
    [alert setAlertStyle: NSInformationalAlertStyle];
    [alert beginSheetModalForWindow: [self window]
                      modalDelegate: self
                     didEndSelector: @selector(alertDidEnd:returnCode:contextInfo:)
                        contextInfo: nil];
}

-(void)explainCantAddUpgrade:(DockEquippedShip*)ship upgrade:(DockUpgrade*)upgrade
{
    NSAlert* alert = [[NSAlert alloc] init];
    NSString* msg = [NSString stringWithFormat: @"Can't add %@ to %@", [upgrade plainDescription], [ship plainDescription]];
    [alert setMessageText: msg];
    NSString* info = @"";
    int limit = [upgrade limitForShip: ship];

    if (limit == 0) {
        NSString* targetClass = [upgrade targetShipClass];

        if (targetClass != nil) {
            info = [NSString stringWithFormat: @"This upgrade can only be installed on ships of class %@.", targetClass];
        } else {
            if ([upgrade isTalent]) {
                info = [NSString stringWithFormat: @"This ship's captain has no %@ upgrade symbols.", [upgrade.upType lowercaseString]];
            } else {
                info = [NSString stringWithFormat: @"This ship has no %@ upgrade symbols on its ship card.", [upgrade.upType lowercaseString]];
            }
        }
    } else {
        NSString* upgradeSpecial = upgrade.special;

        if ([upgradeSpecial isEqualToString: @"OnlyJemHadarShips"]) {
            info = @"This upgrade can only be added to Jem'hadar ships.";
        }
    }

    [alert setInformativeText: info];
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

        if ([target isMemberOfClass: [DockEquippedShip class]]) {
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
        DockCaptain* existingCaptain = [targetShip captain];

        if (captain == existingCaptain) {
            return nil;
        }

        if ([captain isUnique]) {
            DockSquad* squad = [self selectedSquad];
            DockEquippedUpgrade* existing = [squad containsUpgradeWithName: captain.title];

            if (existing) {
                [self selectUpgrade: existing];
                [self explainCantUniqueUpgrade: captain];
                return nil;
            }
        }

        [targetShip removeCaptain];
        return [targetShip addUpgrade: captain];
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
            [self explainCantUniqueUpgrade: upgrade];
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
            NSAlert* alert = [NSAlert alertWithMessageText: @"You must select a ship before adding a captain or upgrade."
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
        DockSquad* squad = [[_squadsController selectedObjects] objectAtIndex: 0];
        [squad removeEquippedShip: targetShip];
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
    _currentSavePanel.allowedFileTypes = @[@"txt", @"dat"];
    _currentSavePanel.accessoryView = _exportFormatView;
    [_currentSavePanel setNameFieldStringValue: squad.name];
    [_currentSavePanel beginSheetModalForWindow: self.window completionHandler: ^(NSInteger v) {
         if (v == NSFileHandlingPanelOKButton) {
             NSURL* fileUrl = _currentSavePanel.URL;
             NSInteger formatSelected = self.exportFormatPopup.selectedTag;

             if (formatSelected == 1) {
                 NSString* textFormat = [squad asTextFormat];
                 NSError* error;
                 [textFormat writeToURL: fileUrl atomically: NO encoding: NSUTF8StringEncoding error: &error];
             } else if (formatSelected == 2) {
                 NSString* textFormat = [squad asDataFormat];
                 NSError* error;
                 [textFormat writeToURL: fileUrl atomically: NO encoding: NSUTF8StringEncoding error: &error];
             }
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
        newExtension = @"dat";
    }

    NSString* currentName = [_currentSavePanel nameFieldStringValue];
    NSString* currentBaseName = [currentName stringByDeletingPathExtension];
    NSString* newName = [currentBaseName stringByAppendingPathExtension: newExtension];
    [_currentSavePanel setNameFieldStringValue: newName];
}

-(IBAction)importSquad:(id)sender
{
    NSOpenPanel* importPanel = [NSOpenPanel openPanel];
    importPanel.allowedFileTypes = @[@"dat"];
    [importPanel beginSheetModalForWindow: self.window completionHandler: ^(NSInteger v) {
         if (v == NSFileHandlingPanelOKButton) {
             NSURL* fileUrl = importPanel.URL;
             NSString* filePath = [fileUrl path];
             NSString* fileName = [filePath lastPathComponent];
             NSString* squadName = [fileName stringByDeletingPathExtension];
             NSError* error;
             NSString* data = [NSString stringWithContentsOfURL: fileUrl encoding: NSUTF8StringEncoding error: &error];
             [DockSquad import: squadName data: data context: _managedObjectContext];
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
        predicateTemplate = [NSPredicate predicateWithFormat: @"not upType like 'Captain' and not placeholder == YES and any sets.externalId in %@", _includedSets];
        _upgradesController.fetchPredicate = predicateTemplate;
    } else {
        NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"faction = %@ and any sets.externalId in %@", _factionName, _includedSets];
        _shipsController.fetchPredicate = predicateTemplate;
        _captainsController.fetchPredicate = predicateTemplate;
        predicateTemplate = [NSPredicate predicateWithFormat: @"not upType like 'Captain' and not placeholder == YES and faction = %@ and any sets.externalId in %@", _factionName, _includedSets];
        _upgradesController.fetchPredicate = predicateTemplate;
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
            [menuItem setTitle: [NSString stringWithFormat: @"Add '%@' to '%@'", ship.title, squad.name]];
        } else {
            [menuItem setTitle: @"Add Ship to Squad"];
            return NO;
        }
    } else if (action == @selector(deleteSelectedShip:)) {
        DockEquippedShip* ship = [self selectedEquippedShip];
        DockSquad* squad = [self selectedSquad];
        if (ship && squad) {
            [menuItem setTitle: [NSString stringWithFormat: @"Remove '%@' from '%@'", ship.ship.title, squad.name]];
        } else {
            [menuItem setTitle: @"Delete Ship from Squad"];
            return NO;
        }
    } else if (action == @selector(addSelectedUpgradeAction:)) {
        DockEquippedShip* ship = [self selectedEquippedShip];
        DockUpgrade* upgrade = [self selectedUpgrade];
        if (ship && upgrade) {
            [menuItem setTitle: [NSString stringWithFormat: @"Add '%@' to '%@'", upgrade.title, ship.ship.title]];
            return YES;
        } else {
            [menuItem setTitle: @"Add Upgrade to Ship"];
            return NO;
        }
    } else if (action == @selector(deleteSelectedUpgradeAction:)) {
        DockEquippedShip* ship = [self selectedEquippedShip];
        DockEquippedUpgrade* upgrade = [self selectedEquippedUpgrade];
        if (ship && upgrade) {
            [menuItem setTitle: [NSString stringWithFormat: @"Remove '%@' from '%@'", upgrade.upgrade.title, ship.ship.title]];
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
            [menuItem setTitle: [NSString stringWithFormat: @"Demote to '%@'", counterpart.title]];
        } else {
            [menuItem setTitle: [NSString stringWithFormat: @"Promote to '%@'", counterpart.title]];
        }
    }

    return YES;
}

-(IBAction)cleanupDatabase:(id)sender
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

-(IBAction)showFleetBuildSheet:(id)sender
{
    [_fleetBuildSheet show: [self selectedSquad]];
}
@end
