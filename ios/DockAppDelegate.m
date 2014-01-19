#import "DockAppDelegate.h"

#import "DockConstants.h"
#import "DockDataLoader.h"
#import "DockDataFileLoader.h"
#import "DockSet+Addons.h"
#import "DockSquad+Addons.h"
#import "DockShip+Addons.h"
#import "DockTopMenuViewController.h"
#import "DockUpgrade+Addons.h"

@interface DockAppDelegate ()

@property (nonatomic, strong, readonly) NSManagedObjectModel* managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator* persistentStoreCoordinator;

-(NSURL*)applicationDocumentsDirectory;
-(void)saveContext;

@end

@implementation DockAppDelegate

@synthesize managedObjectModel = _managedObjectModel, managedObjectContext = _managedObjectContext, persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Application lifecycle

-(NSString*)pathToDataFile
{
    NSString* appData = [[self applicationDocumentsDirectory] path];
    NSString* xmlFile = [appData stringByAppendingPathComponent: @"Data.xml"];
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL isDirectory;
    if ([fm fileExistsAtPath: xmlFile isDirectory: &isDirectory]) {
        return xmlFile;
    }
    
    return [[NSBundle mainBundle] pathForResource: @"Data" ofType: @"xml"];
}

-(NSString*)loadDataFromPath:(NSString*)filePath version:(NSString*)currentVersion error:(NSError**)error
{
    DockDataFileLoader* loader = [[DockDataFileLoader alloc] initWithContext: self.managedObjectContext version: currentVersion];
    if ([loader loadData: filePath force: NO error: error]) {
        return loader.dataVersion;
    }
    return nil;
}

-(void)loadAppDataNow
{
    DockDataLoader* loader = [[DockDataLoader alloc] initWithContext: self.managedObjectContext];
    NSError* error = nil;
    [loader loadData: &error];
}

-(void)loadAppData
{
    [self loadAppDataNow];
    UINavigationController* navigationController = (UINavigationController*)self.window.rootViewController;
    id controller = [navigationController topViewController];
    DockTopMenuViewController* topMenuViewController = (DockTopMenuViewController*)controller;
    topMenuViewController.managedObjectContext = self.managedObjectContext;
}

-(DockSquad*)importSquad:(NSURL*)url
{
    NSError* error;
    DockSquad* newSquad = nil;
    NSString* contents = [NSString stringWithContentsOfURL: url encoding: NSUTF8StringEncoding error: &error];
    if (contents != nil) {
        NSString* extension = [url pathExtension];
        if ([extension isEqualToString: kSpaceDockSquadFileExtension]) {
            newSquad = [DockSquad import: contents context: _managedObjectContext];
        } else {
            NSString* name = [[[url path] lastPathComponent] stringByDeletingPathExtension];
            newSquad = [DockSquad import: name data: contents context: _managedObjectContext];
        }
    }
    return newSquad;
}

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self loadAppData];
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    DockSquad* newSquad = [self importSquad: url];
    if (newSquad != nil) {
        UINavigationController* navigationController = (UINavigationController*)self.window.rootViewController;
        for (UIViewController* controller in navigationController.viewControllers) {
            if ([controller isKindOfClass: [DockTopMenuViewController class]]) {
                [navigationController popToViewController: controller animated: NO];
                DockTopMenuViewController* topMenuViewController = (DockTopMenuViewController*)controller;
                [topMenuViewController showSquad: newSquad];
                break;
            }
        }
    }
    return newSquad != nil;
}

-(void)applicationWillTerminate:(UIApplication*)application
{
    [self saveContext];
}

-(void)applicationWillResignActive:(UIApplication*)application
{
    [self saveContext];
}

-(void)applicationDidEnterBackground:(UIApplication*)application
{
    [self saveContext];
}

-(void)saveContext
{
    NSError* error;

    if (_managedObjectContext != nil) {
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save: &error]) {
            /*
               Replace this implementation with code to handle the error appropriately.

               abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

/*
   Returns the managed object context for the application.
   If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
-(NSManagedObjectContext*)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }

    NSPersistentStoreCoordinator* coordinator = [self persistentStoreCoordinator];

    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }

    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
-(NSManagedObjectModel*)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }

    NSURL* modelURL = [[NSBundle mainBundle] URLForResource: @"Space_Dock" withExtension: @"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: modelURL];
    return _managedObjectModel;
}

static NSString* kSpaceDockFileName = @"SpaceDock2.CDBStore";

-(NSURL*)storeURL
{
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent: kSpaceDockFileName];
}

-(NSPersistentStore*)createStore:(NSURL*)storeURL error:(NSError**)error
{
    NSDictionary* options = @{
                              NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES
                              };
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    
    NSPersistentStore* store = [_persistentStoreCoordinator addPersistentStoreWithType: NSBinaryStoreType
                                                     configuration: nil
                                                               URL: storeURL
                                                           options: options error: error];
    return store;
}

/*
   Returns the persistent store coordinator for the application.
   If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
-(NSPersistentStoreCoordinator*)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    NSFileManager* fileManager = [NSFileManager defaultManager];

    NSURL* oldStoreURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent: @"SpaceDock.CDBStore"];
    if ([fileManager fileExistsAtPath: [oldStoreURL path]]) {
        [fileManager removeItemAtURL: oldStoreURL error: nil];
    }

    NSURL* storeURL = [self storeURL];
    NSError* error;
    NSPersistentStore* store = [self createStore: storeURL error: &error];
    if (store == nil) {
        NSString* explanation = @"Something has gone wrong with the Space Dock data store and the application cannot continue without discarding your data. Preset 'Reset Data' to reset.";
        UIAlertView* view = [[UIAlertView alloc] initWithTitle: @"Error reading data"
                                                       message: explanation
                                                      delegate: self
                                             cancelButtonTitle: nil
                                             otherButtonTitles: @"Reset Data", nil];
        [view show];
    }

    return _persistentStoreCoordinator;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSURL* storeURL = [self storeURL];
    [fileManager removeItemAtURL: storeURL error: nil];
    [self persistentStoreCoordinator];
}

#pragma mark - Application's documents directory

// Returns the URL to the application's Documents directory.
-(NSURL*)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory inDomains: NSUserDomainMask] lastObject];
}

-(NSURL*)updatedDataURL
{
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent: @"Data.xml"];
}

-(void)installData:(NSData*)data
{
    NSURL* appDataPath = [self updatedDataURL];
    [data writeToURL: appDataPath atomically: NO];
    [self loadAppDataNow];
}

-(void)revertData
{
    NSURL* appDataPath = [self updatedDataURL];
    [[NSFileManager defaultManager] removeItemAtURL: appDataPath error: nil];
    [self loadAppDataNow];
}

-(BOOL)hasUpdatedData
{
    NSString* pathToDataFile = [self pathToDataFile];
    NSString* appDocsPath = [[self applicationDocumentsDirectory] path];
    return [pathToDataFile hasPrefix: appDocsPath];
}

@end
