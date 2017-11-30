#import "DockDataLoader.h"

#import "DockConstants.h"
#import "DockCrew+Addons.h"
#import "DockShip+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
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
#if !TARGET_OS_IPHONE
    return [[[[NSFileManager defaultManager] URLsForDirectory: NSApplicationSupportDirectory inDomains: NSUserDomainMask] lastObject] URLByAppendingPathComponent: kDockBundleIdentifier];
#endif
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
    DockDataFileLoader* externalLoader = [[DockDataFileLoader alloc] init];
    NSString* externalVersion = [externalLoader getVersion: externalFile];
    if ([internalVersion compare:externalVersion] != NSOrderedAscending) {
        NSFileManager* fm = [NSFileManager defaultManager];
        [fm removeItemAtPath: externalFile error: nil];
        return internalFile;
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
    NSManagedObjectContext* context = _managedObjectContext;
    DockCrew* crew = [DockCrew crewForId: @"cold_storage_unit_op5prize" context:_managedObjectContext];
    if (crew != nil) {
        NSArray* allSquads = [DockSquad allSquads: _managedObjectContext];
        for (DockSquad* s in allSquads) {
            [s purgeUpgrade: crew];
        }
        [_managedObjectContext deleteObject: crew];
    }
    crew = [DockCrew crewForId:@"vox_71511" context:_managedObjectContext];
    if (crew != nil && [crew.faction isEqualToString:@"Borg, Romulan"])
    {
        NSArray* allSquads = [DockSquad allSquads: _managedObjectContext];
        for (DockSquad* s in allSquads) {
            [s purgeUpgrade: crew];
        }
        [_managedObjectContext deleteObject: crew];
        NSError* error;
        [self loadData:&error];
    }
    
    DockCrew* crew3of5 = [DockCrew crewForId:@"third_of_five_c_71525" context:context];
    DockCrew* crew3of5old = [DockCrew crewForId:@"third_of_five_71525" context:context];
    if (crew3of5 != nil && crew3of5old != nil) {
    NSArray* allSquads = [DockSquad allSquads: context];
        for (DockSquad* s in allSquads) {
            for (DockEquippedShip* sh in [s equippedShips]) {
                for (DockEquippedUpgrade* eu in sh.sortedUpgrades) {
                    if ([eu.upgrade.externalId isEqualToString:@"third_of_five_71525"] && eu.upgrade.isCrew) {
                        [eu setUpgrade:crew3of5];
                    }
                }
            }
        }
        [context deleteObject:crew3of5old];
    }

    DockUpgrade* resourceUpgrade = [DockUpgrade upgradeForId:@"captains_chair_c_72936r" context:_managedObjectContext];
    if (resourceUpgrade != nil)
    {
        NSArray* allSquads = [DockSquad allSquads: _managedObjectContext];
        for (DockSquad* s in allSquads) {
            [s purgeUpgrade: resourceUpgrade];
        }
        [_managedObjectContext deleteObject: resourceUpgrade];
        NSError* error;
        [self loadData:&error];
    }
    resourceUpgrade = [DockUpgrade upgradeForId:@"captains_chair_t_72936r" context:_managedObjectContext];
    if (resourceUpgrade != nil)
    {
        NSArray* allSquads = [DockSquad allSquads: _managedObjectContext];
        for (DockSquad* s in allSquads) {
            [s purgeUpgrade: resourceUpgrade];
        }
        [_managedObjectContext deleteObject: resourceUpgrade];
        NSError* error;
        [self loadData:&error];
    }
    resourceUpgrade = [DockUpgrade upgradeForId:@"captains_chair_w_72936r" context:_managedObjectContext];
    if (resourceUpgrade != nil)
    {
        NSArray* allSquads = [DockSquad allSquads: _managedObjectContext];
        for (DockSquad* s in allSquads) {
            [s purgeUpgrade: resourceUpgrade];
        }
        [_managedObjectContext deleteObject: resourceUpgrade];
        NSError* error;
        [self loadData:&error];
    }
    resourceUpgrade = [DockUpgrade upgradeForId:@"line_retrofit_c_72941r" context:_managedObjectContext];
    if (resourceUpgrade != nil)
    {
        NSArray* allSquads = [DockSquad allSquads: _managedObjectContext];
        for (DockSquad* s in allSquads) {
            [s purgeUpgrade: resourceUpgrade];
        }
        [_managedObjectContext deleteObject: resourceUpgrade];
        NSError* error;
        [self loadData:&error];
    }
    resourceUpgrade = [DockUpgrade upgradeForId:@"line_retrofit_t_72941r" context:_managedObjectContext];
    if (resourceUpgrade != nil)
    {
        NSArray* allSquads = [DockSquad allSquads: _managedObjectContext];
        for (DockSquad* s in allSquads) {
            [s purgeUpgrade: resourceUpgrade];
        }
        [_managedObjectContext deleteObject: resourceUpgrade];
        NSError* error;
        [self loadData:&error];
    }
    resourceUpgrade = [DockUpgrade upgradeForId:@"line_retrofit_w_72941r" context:_managedObjectContext];
    if (resourceUpgrade != nil)
    {
        NSArray* allSquads = [DockSquad allSquads: _managedObjectContext];
        for (DockSquad* s in allSquads) {
            [s purgeUpgrade: resourceUpgrade];
        }
        [_managedObjectContext deleteObject: resourceUpgrade];
        NSError* error;
        [self loadData:&error];
    }
    
    [self mergeGenericUpgrade:[DockUpgrade upgradeForId:@"Plus5NotDominionAndNoMoreThanOnePerShip" context:context] intoUpgrade:[DockUpgrade upgradeForId:@"high_energy_subspace_field_72221c" context:context]];
    [self mergeGenericUpgrade:[DockUpgrade upgradeForId:@"3119" context:context] intoUpgrade:[DockUpgrade upgradeForId:@"3012" context:context]];
    [self mergeGenericUpgrade:[DockUpgrade upgradeForId:@"3052" context:context] intoUpgrade:[DockUpgrade upgradeForId:@"3011" context:context]];
    [self mergeGenericUpgrade:[DockUpgrade upgradeForId:@"photon_torpedoes_71448" context:context] intoUpgrade:[DockUpgrade upgradeForId:@"3045" context:context]];
    [self mergeGenericUpgrade:[DockUpgrade upgradeForId:@"3118" context:context] intoUpgrade:[DockUpgrade upgradeForId:@"3073" context:context]];
    [self mergeGenericUpgrade:[DockUpgrade upgradeForId:@"energy_dissipator_op5prize" context:context] intoUpgrade:[DockUpgrade upgradeForId:@"3059" context:context]];
    [self mergeGenericUpgrade:[DockUpgrade upgradeForId:@"phased_polaron_beam_71524" context:context] intoUpgrade:[DockUpgrade upgradeForId:@"phased_polaron_beam_71279" context:context]];
    [self mergeGenericUpgrade:[DockUpgrade upgradeForId:@"photonic_weapon_71527" context:context] intoUpgrade:[DockUpgrade upgradeForId:@"photonic_weapon_71446" context:context]];
    [self mergeGenericUpgrade:[DockUpgrade upgradeForId:@"quantum_torpedoes_71531" context:context] intoUpgrade:[DockUpgrade upgradeForId:@"3067" context:context]];
    [self mergeGenericUpgrade:[DockUpgrade upgradeForId:@"3037" context:context] intoUpgrade:[DockUpgrade upgradeForId:@"3016" context:context]];
    [self mergeGenericUpgrade:[DockUpgrade upgradeForId:@"plasma_torpedoes_71511" context:context] intoUpgrade:[DockUpgrade upgradeForId:@"3016" context:context]];
    [self mergeGenericUpgrade:[DockUpgrade upgradeForId:@"71276" context:context] intoUpgrade:[DockUpgrade upgradeForId:@"3006" context:context]];
    [self mergeGenericUpgrade:[DockUpgrade upgradeForId:@"photon_torpedoes_71280" context:context] intoUpgrade:[DockUpgrade upgradeForId:@"3006" context:context]];
    [self mergeGenericUpgrade:[DockUpgrade upgradeForId:@"3033" context:context] intoUpgrade:[DockUpgrade upgradeForId:@"3024" context:context]];
    [self mergeGenericUpgrade:[DockUpgrade upgradeForId:@"3111" context:context] intoUpgrade:[DockUpgrade upgradeForId:@"3024" context:context]];
    [self mergeGenericUpgrade:[DockUpgrade upgradeForId:@"photon_torpedoes_71523" context:context] intoUpgrade:[DockUpgrade upgradeForId:@"photon_torpedoes_u_s_s_yaeger" context:context]];
    [self mergeGenericUpgrade:[DockUpgrade upgradeForId:@"photon_torpedoes_71808" context:context] intoUpgrade:[DockUpgrade upgradeForId:@"photon_torpedoes_71528" context:context]];
    [self mergeGenericUpgrade:[DockUpgrade upgradeForId:@"mirror_universe_71535" context:context] intoUpgrade:[DockUpgrade upgradeForId:@"mirror_universe_captain_71510b" context:context]];
    [self mergeGenericUpgrade:[DockUpgrade upgradeForId:@"em_pulse_71806" context:context] intoUpgrade:[DockUpgrade upgradeForId:@"3061" context:context]];
    [self mergeGenericUpgrade:[DockUpgrade upgradeForId:@"missile_launchers_71806" context:context] intoUpgrade:[DockUpgrade upgradeForId:@"3063" context:context]];
    [self mergeGenericShip:[DockShip shipForId: @"1026" context:context] intoShip:[DockShip shipForId: @"1025" context:context]];
    [self mergeGenericShip:[DockShip shipForId: @"ferengi_starship_71646a" context:context] intoShip:[DockShip shipForId: @"1024" context:context]];
    [self mergeGenericShip:[DockShip shipForId: @"vulcan_starship_71527" context:context] intoShip:[DockShip shipForId: @"vulcan_starship_71508" context:context]];
    [self mergeGenericShip:[DockShip shipForId: @"vulcan_starship_71646e" context:context] intoShip:[DockShip shipForId: @"d_kyr_class_71446" context:context]];
    [self mergeGenericShip:[DockShip shipForId: @"romulan_starship_71511" context:context] intoShip:[DockShip shipForId: @"1043" context:context]];
    [self mergeGenericShip:[DockShip shipForId: @"jem_hadar_attack_ship_3rd_wing_attack_ship" context:context] intoShip:[DockShip shipForId: @"1037" context:context]];
    [self mergeGenericShip:[DockShip shipForId: @"borg_starship_71646d" context:context] intoShip:[DockShip shipForId: @"borg_starship_71525" context:context]];
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

-(void)mergeGenericUpgrade:(DockUpgrade*)fromUpgrade intoUpgrade:(DockUpgrade*)intoUpgrade
{
    if (fromUpgrade != nil)
    {
        NSArray* allSquads = [DockSquad allSquads: _managedObjectContext];
        for (DockSquad* s in allSquads) {
            for (DockEquippedShip* sh in [s equippedShips]) {
                for (DockEquippedUpgrade* eu in sh.sortedUpgrades) {
                    if ([eu.upgrade.externalId isEqualToString:fromUpgrade.externalId]) {
                        [eu setUpgrade:intoUpgrade];
                    }
                }
            }
        }
        [_managedObjectContext deleteObject:fromUpgrade];
    }
}

@end
