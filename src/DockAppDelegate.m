//
//  DockAppDelegate.m
//  Space Dock
//
//  Created by Rob Tsuk on 9/18/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import "DockAppDelegate.h"

#import "DockCaptain.h"
#import "DockCrew.h"
#import "DockEquippedShip.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockResource.h"
#import "DockShip.h"
#import "DockSquad.h"
#import "DockSquad+Addons.h"
#import "DockTalent.h"
#import "DockTech.h"
#import "DockUpgrade+Addons.h"
#import "DockWeapon.h"

#import "NSTreeController+Additions.h"

@implementation DockAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

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

-(void)loadItems:(NSXMLDocument*)xmlDoc itemClasses:(NSDictionary*)itemClasses entityName:(NSString*)entityName xpath:(NSString*)xpath
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: entityName inManagedObjectContext: _managedObjectContext];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSError* err;
    NSArray* existingItems = [_managedObjectContext executeFetchRequest: request error: &err];
    NSMutableDictionary* existingItemsLookup = [NSMutableDictionary dictionaryWithCapacity: existingItems.count];

    for (id existingItem in existingItems) {
        existingItemsLookup[[existingItem externalId]] = existingItem;
    }

    NSArray* nodes = [xmlDoc nodesForXPath: xpath error: &err];
    NSDictionary* attributes = [entity attributesByName];

    for (NSXMLNode* oneNode in nodes) {
        NSDictionary* d = [self convertNode: oneNode];
        NSString* externalId = d[@"Id"];
        id c = existingItemsLookup[externalId];

        if (c == nil) {
            Class itemClass = nil;

            if (itemClasses.count == 1) {
                itemClass = [itemClasses allValues][0];
            } else {
                NSString* itemType = d[@"Type"];
                itemClass = itemClasses[itemType];
            }

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
            } else {
                NSString* lowerFirst = [[key substringToIndex: 1] lowercaseString];
                NSString* rest = [key substringFromIndex: 1];
                modifiedKey = [lowerFirst stringByAppendingString: rest];
            }

            NSAttributeDescription* desc = [attributes objectForKey: modifiedKey];

            if (desc != nil) {
                id v = [d valueForKey: key];
                NSInteger aType = [desc attributeType];

                switch (aType) {
                case NSInteger16AttributeType:
                    v = [NSNumber numberWithInt: [v intValue]];
                    break;

                case NSBooleanAttributeType:
                    v = [NSNumber numberWithBool: [v isEqualToString: @"Y"]];
                    break;
                }
                [c setValue: v forKey: modifiedKey];
            }
        }
    }
}

-(void)loadItems:(NSXMLDocument*)xmlDoc itemClass:(Class)itemClass entityName:(NSString*)entityName xpath:(NSString*)xpath targetType:(NSString*)targetType
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: entityName inManagedObjectContext: _managedObjectContext];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSError* err;
    NSArray* existingItems = [_managedObjectContext executeFetchRequest: request error: &err];
    NSMutableDictionary* existingItemsLookup = [NSMutableDictionary dictionaryWithCapacity: existingItems.count];

    for (id existingItem in existingItems) {
        NSString* externalId = [existingItem externalId];
        if (externalId != nil) {
            existingItemsLookup[[existingItem externalId]] = existingItem;
        }
    }

    NSArray* nodes = [xmlDoc nodesForXPath: xpath error: &err];
    NSDictionary* attributes = [entity attributesByName];

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
                    NSString* lowerFirst = [[key substringToIndex: 1] lowercaseString];
                    NSString* rest = [key substringFromIndex: 1];
                    modifiedKey = [lowerFirst stringByAppendingString: rest];
                }

                NSAttributeDescription* desc = [attributes objectForKey: modifiedKey];

                if (desc != nil) {
                    id v = [d valueForKey: key];
                    NSInteger aType = [desc attributeType];

                    switch (aType) {
                    case NSInteger16AttributeType:
                        v = [NSNumber numberWithInt: [v intValue]];
                        break;

                    case NSBooleanAttributeType:
                        v = [NSNumber numberWithBool: [v isEqualToString: @"Y"]];
                        break;
                    }
                    [c setValue: v forKey: modifiedKey];
               }
            }
        }
    }
}

-(void)loadData
{
    NSString* file = [[NSBundle mainBundle] pathForResource: @"Data" ofType: @"xml"];
    NSXMLDocument* xmlDoc;
    NSError* err = nil;
    NSURL* furl = [NSURL fileURLWithPath: file];

    if (!furl) {
        NSLog(@"Can't create an URL from file %@.", file);
        return;
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

        return;
    }

    if (err) {
        [self handleError: err];
    }

    [self loadItems: xmlDoc itemClass: [DockShip class] entityName: @"Ship" xpath: @"/Data/Ships/Ship" targetType: nil];
    [self loadItems: xmlDoc itemClass: [DockCaptain class] entityName: @"Captain" xpath: @"/Data/Captains/Captain" targetType: nil];
    [self loadItems: xmlDoc itemClass: [DockWeapon class] entityName: @"Weapon" xpath: @"/Data/Upgrades/Upgrade" targetType: @"Weapon"];
    [self loadItems: xmlDoc itemClass: [DockTalent class] entityName: @"Talent" xpath: @"/Data/Upgrades/Upgrade" targetType: @"Talent"];
    [self loadItems: xmlDoc itemClass: [DockCrew class] entityName: @"Crew" xpath: @"/Data/Upgrades/Upgrade" targetType: @"Crew"];
    [self loadItems: xmlDoc itemClass: [DockTech class] entityName: @"Tech" xpath: @"/Data/Upgrades/Upgrade" targetType: @"Tech"];
    [self loadItems: xmlDoc itemClass: [DockResource class] entityName: @"Resource" xpath: @"/Data/Resources/Resource" targetType: @"Resource"];
}

-(void)applicationDidFinishLaunching:(NSNotification*)aNotification
{
    [self loadData];
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

    if (![coordinator addPersistentStoreWithType: NSXMLStoreType configuration: nil URL: url options: nil error: &error]) {
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

-(void)whineToUser:(NSString*)msg
{
    NSAlert* alert = [[NSAlert alloc] init];
    [alert setMessageText: msg];
    [alert setAlertStyle: NSInformationalAlertStyle];
    [alert runModal];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	[[alert window] orderOut:self];
}


-(void)explainCantAddUpgrade:(DockEquippedShip*)ship upgrade:(DockUpgrade*)upgrade
{
    NSAlert* alert = [[NSAlert alloc] init];
    NSString* msg =[NSString stringWithFormat: @"Can't add %@ to %@", upgrade, ship];
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
    }
    [alert setInformativeText: info];
    [alert setAlertStyle: NSInformationalAlertStyle];
    [alert beginSheetModalForWindow:[self window]
                      modalDelegate:self
                     didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                        contextInfo:nil];
}

-(void)addSelectedShip
{
    DockSquad* squad = [[_squadsController selectedObjects] objectAtIndex: 0];
    NSArray* shipsToAdd = [_shipsController selectedObjects];

    for (DockShip* ship in shipsToAdd) {
        DockEquippedShip* es = [DockEquippedShip equippedShipWithShip: ship];
        es.ship = ship;
        [squad addEquippedShip: es];
        NSIndexPath* path = [_squadDetailController indexPathOfObject: [es equippedCaptain]];
        [_squadDetailController setSelectionIndexPath: path];
    }
}

-(DockEquippedShip*)selectedShip
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

-(DockEquippedUpgrade*)selectedUpgrade
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

-(DockSquad*)selectedSquad
{
    DockSquad* squad = nil;

    NSArray* squads = [_squadsController selectedObjects];
    if (squads.count > 0) {
        squad = [squads objectAtIndex: 0];
    }

    return squad;
}

-(DockEquippedUpgrade*)addSelectedCaptain:(DockEquippedShip*)targetShip
{
    NSArray* captainsToAdd = [_captainsController selectedObjects];
    if (captainsToAdd.count < 1) {
    } else {
        [targetShip removeCaptain];
        DockCaptain* captain = captainsToAdd[0];
        return [targetShip addUpgrade: captain];
    }
    return nil;
}

-(DockEquippedUpgrade*)addSelectedUpgrade:(DockEquippedShip*)targetShip maybeReplace:(DockEquippedUpgrade*)maybeReplace
{
    NSArray* upgradeToAdd = [_upgradesController selectedObjects];
    DockUpgrade* upgrade = upgradeToAdd[0];
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

-(IBAction)addSelected:(id)sender
{
    NSTabViewItem* selectedTab = [_tabView selectedTabViewItem];
    id identifier = selectedTab.identifier;
    if ([identifier isEqualToString: @"ships"]) {
        [self addSelectedShip];
    } else {
        DockEquippedShip* selectedShip = [self selectedShip];
        DockEquippedUpgrade* maybeUpgrade = [self selectedUpgrade];
        DockEquippedUpgrade* equippedUpgrade = nil;
        if (selectedShip != nil) {
            if ([identifier isEqualToString: @"captains"]) {
                equippedUpgrade = [self addSelectedCaptain: selectedShip];
            }
            if ([identifier isEqualToString: @"upgrades"]) {
                equippedUpgrade = [self addSelectedUpgrade: selectedShip maybeReplace: maybeUpgrade];
            }
            if (equippedUpgrade != nil) {
                NSIndexPath* path = [_squadDetailController indexPathOfObject: equippedUpgrade];
                [_squadDetailController setSelectionIndexPath: path];
            }
        } else {
            NSAlert* alert = [NSAlert alertWithMessageText: @"You must select a ship before adding a captain or upgrade."
                                             defaultButton: @"OK"
                                           alternateButton: @""
                                               otherButton: @""
                                 informativeTextWithFormat: @""];
            [alert runModal];
        }
    }
}

-(IBAction)deleteSelected:(id)sender
{
    id target = [[_squadDetailController selectedObjects] objectAtIndex: 0];
    DockEquippedShip* targetShip = [self selectedShip];
    if (target == targetShip) {
        DockSquad* squad = [[_squadsController selectedObjects] objectAtIndex: 0];
        [squad removeEquippedShip: targetShip];
    } else {
        [targetShip removeUpgrade: target establishPlaceholders: YES];
        NSIndexPath* path = [_squadDetailController indexPathOfObject: targetShip];
        [_squadDetailController setSelectionIndexPath: path];
    }
}

-(IBAction)expandAll:(id)sender
{
    [_squadDetailView expandItem: nil expandChildren: YES];
}

@end
