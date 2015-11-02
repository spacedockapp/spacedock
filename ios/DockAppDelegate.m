#import "DockAppDelegate.h"

#import "DockBackupManager.h"
#import "DockBuildSheetRenderer.h"
#import "DockConstants.h"
#import "DockCoreDataManager.h"
#import "DockDataLoader.h"
#import "DockDataFileLoader.h"
#import "DockSet+Addons.h"
#import "DockSquad+Addons.h"
#import "DockSquadImporteriOS.h"
#import "DockSquadsListController.h"
#import "DockShip+Addons.h"
#import "DockTopMenuViewController.h"
#import "DockUpgrade+Addons.h"
#import "DockSplitViewController.h"
#import "DockResourcesViewController.h"

@interface DockAppDelegate ()

@property (atomic, strong) DockCoreDataManager* coreDataManager;
@property (atomic, strong) NSManagedObjectContext* managedObjectContext;
@property (atomic, strong) NSOperationQueue* loaderQueue;
@property (nonatomic, strong) DockSquadImporteriOS* squadImporter;

-(NSURL*)applicationDocumentsDirectory;
-(void)saveContext;

@end

@implementation DockAppDelegate

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

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL succeeded))completionHandler
{
    NSString* bundle = [[NSBundle mainBundle] bundleIdentifier];
    
    if ([shortcutItem.type isEqualToString:[bundle stringByAppendingString:@".GoToSquads"]]) {
        [self loadAppData:@"GoToSquads"];
    } else if ([shortcutItem.type isEqualToString:[bundle stringByAppendingString:@".GoToReference"]]) {
        [self loadAppData:@"GoToReference"];
    }
}

-(void)loadAppData
{
    [self loadAppData:nil];
}

-(void)loadAppData:(NSString *)segueId
{
    id finishLoadBlock = ^() {
        NSError* error;
        _managedObjectContext = [_coreDataManager createContext: NSMainQueueConcurrencyType error: &error];
        UINavigationController* navigationController;
        if ([self.window.rootViewController isKindOfClass:[UISplitViewController class]]) {
            navigationController = [[(UISplitViewController*)self.window.rootViewController viewControllers] objectAtIndex:0];
        } else {
            navigationController = (UINavigationController*)self.window.rootViewController;
        }
        id controller = [navigationController.viewControllers firstObject];
        DockTopMenuViewController* topMenuViewController = (DockTopMenuViewController*)controller;
        topMenuViewController.managedObjectContext = self.managedObjectContext;
        
        if (segueId != nil) {
            [navigationController popToRootViewControllerAnimated:YES];
            [topMenuViewController performSegueWithIdentifier:segueId sender:nil];
        } else if ([self.window.rootViewController isKindOfClass:[UISplitViewController class]]) {
            [topMenuViewController performSegueWithIdentifier:@"GoToSquads" sender:nil];
        }
    };

    id loadBlock = ^() {
        NSError* error;
        NSManagedObjectContext* moc = [_coreDataManager createContext: 1 error: &error];
        DockDataLoader* loader = [[DockDataLoader alloc] initWithContext: moc];
        [loader loadData: &error];
        [loader validateSpecials];
        [loader cleanupDatabase];
        if ([[moc deletedObjects] count] > 0) {
            [moc save:&error];
        }
        [DockSquad assignUUIDs: moc];
        [[NSOperationQueue mainQueue] addOperationWithBlock: finishLoadBlock];
    };

    _coreDataManager = [[DockCoreDataManager alloc] initWithStore: [self storeURL] model: [self modelURL]];
    [_loaderQueue addOperationWithBlock: loadBlock];
}

-(DockSquad*)importSquad:(NSURL*)url
{
    NSError* error;
    DockSquad* newSquad = nil;
    NSString* contents = [NSString stringWithContentsOfURL: url encoding: NSUTF8StringEncoding error: &error];
    if (contents != nil) {
        NSString* extension = [url pathExtension];
        if ([extension isEqualToString: kSpaceDockSquadFileExtension]) {
            newSquad = [DockSquad importOneSquadFromString: contents context: _managedObjectContext];
        } else {
            NSString* name = [[[url path] lastPathComponent] stringByDeletingPathExtension];
            newSquad = [DockSquad import: name data: contents context: _managedObjectContext];
        }
    }
    return newSquad;
}

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _loaderQueue = [[NSOperationQueue alloc] init];

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* appDefs = @{
        kPlayerNameKey: @"",
        kPlayerEmailKey: @"",
        kEventFactionKey: @"",
        kEventNameKey: @"",
        kBlindBuyKey: @"",
        kLightHeaderKey: @"",
        kMarkExpiredResKey: @""
    };

    [defaults registerDefaults: appDefs];

    if ([self.window.rootViewController isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController* splitViewController = (UISplitViewController*) self.window.rootViewController;
        if ([splitViewController respondsToSelector:@selector(setPreferredDisplayMode:)]) {
            splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
        }
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        DockSplitViewController* splitViewController = [[DockSplitViewController alloc] init];
        UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:[[UITableViewController alloc] init]];
        navigationController.toolbarHidden = NO;
        navigationController.hidesBottomBarWhenPushed = NO;
        [splitViewController addChildViewController:self.window.rootViewController];
        [splitViewController addChildViewController:navigationController];
        self.window.rootViewController = splitViewController;
    }
    
    if ([UIApplicationShortcutItem class]) {
        UIApplicationShortcutItem* shortcutItem = [launchOptions objectForKey:UIApplicationLaunchOptionsShortcutItemKey];
        NSString* bundle = [[NSBundle mainBundle] bundleIdentifier];
        
        if ([shortcutItem.type isEqualToString:[bundle stringByAppendingString:@".GoToSquads"]]) {
            [self loadAppData:@"GoToSquads"];
        } else if ([shortcutItem.type isEqualToString:[bundle stringByAppendingString:@".GoToReference"]]) {
            [self loadAppData:@"GoToReference"];
        } else {
            [self loadAppData];
        }
        return NO;
    }
    [self loadAppData];
    [self updateVersionInfo];
    
    return YES;
}

-(BOOL)importOneSquad:(NSURL*)url
{
    DockSquad* newSquad = [self importSquad: url];
    if (newSquad != nil) {
        UINavigationController* navigationController;
        if ([self.window.rootViewController isKindOfClass:[UISplitViewController class]]) {
            navigationController = [[(UISplitViewController*)self.window.rootViewController viewControllers] objectAtIndex:0];
        } else {
            navigationController = (UINavigationController*)self.window.rootViewController;
        }
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

-(BOOL)importSquadList:(NSURL*)url
{
    _squadImporter = [[DockSquadImporteriOS alloc] initWithPath: [url path] context: _managedObjectContext];
    [_squadImporter examineImport: nil];
#if 0
    UINavigationController* navigationController = (UINavigationController*)self.window.rootViewController;
    for (UIViewController* controller in navigationController.viewControllers) {
        if ([controller isKindOfClass: [DockSquadsListController class]]) {
            [navigationController popToViewController: controller animated: NO];
            break;
        }
    }
#endif
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString* extension = [[[url path] pathExtension] lowercaseString];
    if ([extension isEqualToString: @"spacedock"]) {
        return [self importOneSquad: url];
    }
    if ([extension isEqualToString: @"spacedocksquads"]) {
        return [self importSquadList: url];
    }
    return NO;
}

-(void)cleanupSavedSquads
{
    NSString* targetDirectory = [[self applicationDocumentsDirectory] path];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSArray* files = [fm contentsOfDirectoryAtPath: targetDirectory error: nil];
    for (NSString* oneFileName in files) {
        NSString* extension = [oneFileName pathExtension];
        if ([extension isEqualToString: @"json"]) {
            NSString* oneTargetPath = [targetDirectory stringByAppendingPathComponent: oneFileName];
            [fm removeItemAtPath: oneTargetPath error: nil];
        }
    }
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

-(void)saveSquadsToDisk
{
    NSString* targetDirectory = [[self applicationDocumentsDirectory] path];
    for (DockSquad* squad in [DockSquad allSquads: _managedObjectContext]) {
        NSString* targetPath = [targetDirectory stringByAppendingPathComponent: [NSString stringWithFormat: @"%@_%@", squad.name, squad.uuid]];
        targetPath = [targetPath stringByAppendingPathExtension: @"json"];
        [squad checkAndUpdateFileAtPath: targetPath];
    }
}

-(void)saveContext
{
    NSError* error;
    
    [self cleanupSavedSquads];

    if (_managedObjectContext != nil) {
        
        DockBackupManager* backupManager = [DockBackupManager sharedBackupManager];
        if (backupManager.squadHasChanged) {
            [backupManager backupNow: self.managedObjectContext error: nil];
        }
        
        if ([_managedObjectContext hasChanges]) {
            BOOL contextSaved = [_managedObjectContext save: &error];
            
            if (!contextSaved) {
                /*
                 Replace this implementation with code to handle the error appropriately.
                 
                 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 */
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
    }
    
}

#pragma mark - Core Data stack

static NSString* kSpaceDockFileName = @"SpaceDock2.CDBStore";

-(NSURL*)storeURL
{
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent: kSpaceDockFileName];
}

-(NSURL*)modelURL
{
    return [[NSBundle mainBundle] URLForResource: @"Space_Dock" withExtension: @"momd"];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
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

- (void)updateVersionInfo
{
    //This method updates the Root settings to display current Version and Build No in Settings Bundle
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *appVersionNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *appBuildNo = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    NSString *versionNumberInSettings = [NSString stringWithFormat:@"%@ Build %@", appBuildNo, appVersionNumber];
    [defaults setObject:versionNumberInSettings forKey:@"version"];
}

@end
