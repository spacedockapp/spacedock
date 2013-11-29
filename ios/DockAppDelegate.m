#import "DockAppDelegate.h"

#import "DockDataLoader.h"
#import "DockSet+Addons.h"
#import "DockShip+Addons.h"
#import "DockTopMenuViewController.h"

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

-(void)applicationDidFinishLaunching:(UIApplication*)application
{
    DockDataLoader* loader = [[DockDataLoader alloc] initWithContext: self.managedObjectContext];
    NSError* error = nil;

    if ([loader loadData: &error]) {
    }

    UINavigationController* navigationController = (UINavigationController*)self.window.rootViewController;
    id controller = [navigationController topViewController];
    DockTopMenuViewController* topMenuViewController = (DockTopMenuViewController*)controller;
    topMenuViewController.managedObjectContext = self.managedObjectContext;
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

/*
   Returns the persistent store coordinator for the application.
   If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
-(NSPersistentStoreCoordinator*)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    NSURL* storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent: @"SpaceDock.CDBStore"];

    /*
       Set up the store.
       For the sake of illustration, provide a pre-populated default store.
     */
    NSFileManager* fileManager = [NSFileManager defaultManager];

    // If the expected store doesn't exist, copy the default store.
    if (![fileManager fileExistsAtPath: [storeURL path]]) {
        NSURL* defaultStoreURL = [[NSBundle mainBundle] URLForResource: @"SpaceDock" withExtension: @"CDBStore"];

        if (defaultStoreURL) {
            [fileManager copyItemAtURL: defaultStoreURL toURL: storeURL error: NULL];
        }
    }

    NSDictionary* options = @{
        NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES
    };
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];

    NSError* error;

    if (![_persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType configuration: nil URL: storeURL options: options error: &error]) {
        /*
           Replace this implementation with code to handle the error appropriately.

           abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

           Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
           Check the error message to determine what the actual problem was.


           If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.

           If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
           [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]

         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
           @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}

           Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.

         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _persistentStoreCoordinator;
}

#pragma mark - Application's documents directory

// Returns the URL to the application's Documents directory.
-(NSURL*)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory inDomains: NSUserDomainMask] lastObject];
}

@end
