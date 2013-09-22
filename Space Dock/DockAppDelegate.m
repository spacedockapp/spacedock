//
//  DockAppDelegate.m
//  Space Dock
//
//  Created by Rob Tsuk on 9/18/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import "DockAppDelegate.h"

#import "DockCaptain.h"
#import "DockShip.h"

@implementation DockAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

-(void)handleError:(NSError*)error
{
}

-(NSDictionary*)convertNode: (NSXMLNode*)node
{
    NSMutableDictionary* d = [NSMutableDictionary dictionaryWithCapacity:0];
    for (NSXMLNode* c in node.children) {
        [d setObject: [c objectValue] forKey: [c name]];
    }
    return [NSDictionary dictionaryWithDictionary: d];
}

- (void)loadData {
    NSString* file = [[NSBundle mainBundle] pathForResource:@"Data" ofType:@"xml"];
    NSXMLDocument *xmlDoc;
    NSError *err=nil;
    NSURL *furl = [NSURL fileURLWithPath:file];
    if (!furl) {
        NSLog(@"Can't create an URL from file %@.", file);
        return;
    }
    xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:furl
            options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA)
            error:&err];
    if (xmlDoc == nil) {
        xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:furl
                    options:NSXMLDocumentTidyXML
                    error:&err];
    }
    if (xmlDoc == nil)  {
        if (err) {
            [self handleError:err];
        }
        return;
    }
 
    if (err) {
        [self handleError:err];
    }

    NSEntityDescription* shipEntity = [NSEntityDescription entityForName: @"Ship" inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:shipEntity];
    NSArray *existingShips = [_managedObjectContext executeFetchRequest:request error:&err];
    for (id existingShip in existingShips) {
        [_managedObjectContext deleteObject: existingShip];
    }

    NSArray *shipNodes = [xmlDoc nodesForXPath:@"/Data/Ships/Ship"
            error:&err];
    NSDictionary* attributes = [shipEntity attributesByName];
    for (NSXMLNode* shipNode in shipNodes) {
        NSDictionary* d = [self convertNode: shipNode];
        DockShip* c = [[DockShip alloc] initWithEntity: shipEntity insertIntoManagedObjectContext:_managedObjectContext];
        for(NSString* key in d) {
            NSString* modifiedKey;
            if ([key isEqualToString: @"Id"]) {
                modifiedKey = @"externalId";
            } else {
                NSString* lowerFirst = [[key substringToIndex: 1] lowercaseString];
                NSString* rest = [key substringFromIndex: 1];
                modifiedKey = [lowerFirst stringByAppendingString: rest];
            }
            NSAttributeDescription* desc = [attributes objectForKey: modifiedKey];
            id v = [d valueForKey: key];
            NSInteger aType = [desc attributeType];
            switch(aType) {
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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.shipsSortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                            ascending:YES],
                              [NSSortDescriptor sortDescriptorWithKey:@"faction"
                                                            ascending:YES]];
    [self loadData];
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "com.funnyhatsoftware.Space_Dock" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.funnyhatsoftware.Space_Dock"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Space_Dock" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Space_Dock.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
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
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

@end
