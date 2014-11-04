#import "DockDataLoader.h"

#import "DockConstants.h"
#import "DockCrew+Addons.h"
#import "DockShip+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockDataFileLoader.h"
#import "DockSquad+Addons.h"

@interface DockDataLoader () {
    DockDataFileLoader* _loader;
    NSManagedObjectContext* _managedObjectContext;
}
@end

@implementation DockDataLoader

-(id)initWithContext:(NSManagedObjectContext*)context
{
    self = [super init];
    if (self) {
        _managedObjectContext = context;
    }
    return self;
}

-(NSString*)currentDataVersion
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey: kSpaceDockCurrentDataVersionKey];
}

-(NSString*)loadDataForVersion:(NSString*)currentVersion filePath:(NSString*)filePath error:(NSError**)error
{
    _loader = [[DockDataFileLoader alloc] initWithContext: _managedObjectContext
                                                             version: currentVersion];
    if ([_loader loadData: filePath force: NO error: error]) {
        return _loader.dataVersion;
    }
    
    return nil;
}

-(BOOL)loadDataFromPath:(NSString*)filePath error:(NSError**)error
{
    NSString* currentVersion = [self currentDataVersion];

    NSString* dataVersion = [self loadDataForVersion: currentVersion filePath: filePath error: error];
    if (dataVersion != nil) {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject: dataVersion forKey: kSpaceDockCurrentDataVersionKey];
    }
    
    return YES;
}

-(NSSet*)validateSpecials
{
    return [_loader validateSpecials];
}

-(NSString*)internalDataFile
{
    return [[NSBundle mainBundle] pathForResource: @"Data" ofType: @"xml"];
}

-(NSURL*)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory inDomains: NSUserDomainMask] lastObject];
}

-(NSString*)externalDataFile
{
    NSString* appData = [[self applicationDocumentsDirectory] path];
    NSString* xmlFile = [appData stringByAppendingPathComponent: @"Data.xml"];
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL isDirectory;
    if ([fm fileExistsAtPath: xmlFile isDirectory: &isDirectory]) {
        return xmlFile;
    }
    
    return nil;
}

-(NSString*)selectNewestDataFile
{
    NSString* externalFile = [self externalDataFile];
    NSString* internalFile = [self internalDataFile];
    if (externalFile == nil) {
        return internalFile;
    }
    DockDataFileLoader* internalLoader = [[DockDataFileLoader alloc] init];
    NSString* internalVersion = [internalLoader getVersion: internalFile];
    float internalVersionValue = [internalVersion floatValue];
    DockDataFileLoader* externalLoader = [[DockDataFileLoader alloc] init];
    NSString* externalVersion = [externalLoader getVersion: internalFile];
    float externalVersionValue = [externalVersion floatValue];
    if (internalVersionValue >= externalVersionValue) {
        NSFileManager* fm = [NSFileManager defaultManager];
        [fm removeItemAtPath: externalFile error: nil];
    }
    return externalFile;
}

-(BOOL)loadData:(NSError**)error
{
    NSString* targetPath = [self selectNewestDataFile];
    return [self loadDataFromPath: targetPath error: error];
}

-(void)cleanupDatabase
{
    DockCrew* crew = [DockCrew crewForId: @"cold_storage_unit_op5prize" context:_managedObjectContext];
    if (crew != nil) {
        NSArray* allSquads = [DockSquad allSquads: _managedObjectContext];
        for (DockSquad* s in allSquads) {
            [s purgeUpgrade: crew];
        }
        [_managedObjectContext deleteObject: crew];
    }
    [self mergeGenericShip:[DockShip shipForId: @"1026" context:_managedObjectContext] intoShip:[DockShip shipForId: @"1025" context:_managedObjectContext]];
    [self mergeGenericShip:[DockShip shipForId: @"ferengi_starship_71646a" context:_managedObjectContext] intoShip:[DockShip shipForId: @"1024" context:_managedObjectContext]];
    [self mergeGenericShip:[DockShip shipForId: @"vulcan_starship_71527" context:_managedObjectContext] intoShip:[DockShip shipForId: @"vulcan_starship_71508" context:_managedObjectContext]];
    [self mergeGenericShip:[DockShip shipForId: @"vulcan_starship_71646e" context:_managedObjectContext] intoShip:[DockShip shipForId: @"d_kyr_class_71446" context:_managedObjectContext]];
    [self mergeGenericShip:[DockShip shipForId: @"romulan_starship_71511" context:_managedObjectContext] intoShip:[DockShip shipForId: @"1043" context:_managedObjectContext]];
    [self mergeGenericShip:[DockShip shipForId: @"jem_hadar_attack_ship_3rd_wing_attack_ship" context:_managedObjectContext] intoShip:[DockShip shipForId: @"1037" context:_managedObjectContext]];
}

-(void)mergeGenericShip:(DockShip*)fromShip intoShip:(DockShip*)intoShip
{
    if (fromShip != nil)
    {
        NSArray* allSquads = [DockSquad allSquads: _managedObjectContext];
        for (DockSquad* s in allSquads) {
            NSMutableOrderedSet* removeShips = [NSMutableOrderedSet orderedSet];
            for (DockEquippedShip* sh in [s equippedShips]) {
                if ([sh.ship.externalId isEqualToString:fromShip.externalId]) {
                    if (intoShip !=nil) {
                        [sh changeShip:intoShip];
                    } else {
                        [removeShips addObject:sh];
                    }
                }
            }
            if (removeShips.count > 0) {
                [s removeEquippedShips:removeShips];
            }
        }
        [_managedObjectContext deleteObject:fromShip];
    }

}

@end
