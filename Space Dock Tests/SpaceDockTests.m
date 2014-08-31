#import <XCTest/XCTest.h>

#import "DockAppDelegate.h"
#import "DockCaptain+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockFlagship+Addons.h"
#import "DockManeuver+Addons.h"
#import "DockResource+Addons.h"
#import "DockSet+Addons.h"
#import "DockShip+Addons.h"
#import "DockShipClassDetails+Addons.h"
#import "DockSquad+Addons.h"
#import "DockTagged+Addons.h"
#import "DockUpgrade+Addons.h"

@interface SpaceDockTests : XCTestCase
@property (strong, nonatomic) NSManagedObjectContext* context;
@end

@implementation SpaceDockTests

static NSManagedObjectContext* getManagedObjectContext()
{
    DockAppDelegate* delegate = [NSApp delegate];
    return delegate.managedObjectContext;
}

- (void)setUp
{
    [super setUp];
    _context = getManagedObjectContext();
    [DockSquad deleteAllSquads: _context];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testLoad
{
    {
        NSArray* allShips = [DockShip allShips: _context];
        XCTAssertEqual(100, allShips.count);
    }
    
    {
        DockShip* entD = [DockShip shipForId: @"1001" context: _context];
        XCTAssertNotNil(entD);
        XCTAssertEqual(4, [entD.attack intValue]);
        XCTAssertEqualObjects(@"Federation", entD.factionSortValue);
        DockShipClassDetails* details = entD.shipClassDetails;
        XCTAssertNotNil(details, "Couldn't get ship details");
        XCTAssertEqualObjects(@"90", details.frontArc, @"wrong front arc");
        DockManeuver* maneuver = [details getDockManeuver: -2 kind: @"straight"];
        XCTAssertNotNil(maneuver, @"Couldn't backup 2");
        XCTAssertEqual(-2, [maneuver.speed intValue]);
        XCTAssertEqualObjects(@"U.S.S. Enterprise-D", entD.title);
        XCTAssertTrue([entD.unique boolValue], @"U.S.S. Enterprise-D should be unique");
    }
    
    {
        DockCaptain* picard = (DockCaptain*)[DockCaptain captainForId: @"2001" context: _context];
        XCTAssertNotNil(picard, "Couldn't get captain");
        XCTAssertEqualObjects(@9, picard.skill);
        XCTAssertEqualObjects(@"Jean-Luc Picard", picard.title);
        XCTAssertTrue([picard.unique boolValue], @"Picard should be unique");
    }
    
    {
        DockUpgrade* romulanPilot = [DockUpgrade upgradeForId: @"3102" context:_context];
        XCTAssertNotNil(romulanPilot);
        XCTAssertEqualObjects(@"Romulan Pilot", romulanPilot.title);
        XCTAssertEqualObjects(@2, romulanPilot.cost);
        XCTAssertNotEqualObjects(@YES, romulanPilot.unique);
    }
    
    {
        DockFlagship* fs = [DockFlagship flagshipForId: @"6002" context: _context];
        XCTAssertNotNil(fs);
        XCTAssertEqualObjects(@1, fs.attack);
        XCTAssertEqualObjects(@0, fs.hull);
        XCTAssertEqualObjects(@"Independent", fs.factionSortValue);
    }
    
    {
        DockResource* tokens = [DockResource resourceForId: @"4002" context: _context];
        XCTAssertNotNil(tokens);
        XCTAssertEqualObjects(@5, tokens.cost);
    }
    
    {
        DockSet* coreSet = [DockSet setForId: @"71120" context: _context];
        XCTAssertNotNil(coreSet);
        XCTAssertEqual(33, coreSet.items.count);
    }

    {
        DockSet* reliantSet = [DockSet setForId: @"71121" context: _context];
        XCTAssertNotNil(reliantSet);
        XCTAssertEqual(12, reliantSet.items.count);
    }
}

- (DockSquad *)loadSquad:(NSString *)rom2Path
{
    NSData* rom2Data = [NSData dataWithContentsOfFile: rom2Path];
    XCTAssertNotNil(rom2Data);
    NSError* error = nil;
    NSDictionary* squadDictionary = [NSJSONSerialization JSONObjectWithData: rom2Data options: 0 error: &error];
    XCTAssertNil(error);
    XCTAssertNotNil(squadDictionary);
    DockSquad* squad = [DockSquad squad: _context];
    XCTAssertNotNil(squad);
    [squad importIntoSquad: squadDictionary replaceUUID: NO];
    return squad;
}

-(void)testImport
{
    NSBundle* testBundle = [NSBundle bundleForClass: [self class]];
    NSString* rom2Path = [testBundle pathForResource: @"romulan_2_ship" ofType: @"spacedock"];
    XCTAssertNotNil(rom2Path);
    DockSquad *squad = [self loadSquad:rom2Path];
    XCTAssertEqualObjects(@"Unified Force (0) Strike Force (5)", squad.notes);
    XCTAssertEqualObjects(@"Romulan 2 Ship", squad.name);
    XCTAssertEqual(2, squad.equippedShips.count);
    DockResource* resource = squad.resource;
    XCTAssertNotNil(resource);
    XCTAssertEqualObjects(@"4004", resource.externalId);
    DockEquippedShip* es = [squad.equippedShips objectAtIndex: 0];
    XCTAssertNotNil(es);
    XCTAssertEqualObjects(@"I.R.W. Valdore", es.ship.title);
    XCTAssertEqual(1, es.talentCount);
    XCTAssertEqual(3, es.crewCount);
    XCTAssertEqual(1, es.techCount);
    XCTAssertEqual(2, es.weaponCount);
    XCTAssertEqual(9, es.sortedUpgradesWithFlagship.count);
    XCTAssertEqual(100, squad.cost);
}

-(void)testExport
{
    NSBundle* testBundle = [NSBundle bundleForClass: [self class]];
    NSString* rom2Path = [testBundle pathForResource: @"romulan_2_ship" ofType: @"spacedock"];
    XCTAssertNotNil(rom2Path);
    DockSquad *squad = [self loadSquad:rom2Path];
    NSData* jsonData = [squad asJSONData];
    DockSquad* newSquad = [DockSquad squad: _context];
    NSError* error;
    NSDictionary* squad2Dictionary = [NSJSONSerialization JSONObjectWithData: jsonData options: 0 error: &error];
    XCTAssertNil(error);
    XCTAssertNotNil(squad2Dictionary);
    [newSquad importIntoSquad: squad2Dictionary replaceUUID: NO];
    XCTAssertEqual(squad.cost, newSquad.cost);
}

-(void)listTester:(NSString*)squadfileName
{
    NSString* upgradeIdKey = @"upgradeId";
    NSString* calculatedCostKey = @"calculatedCost";
    NSBundle* testBundle = [NSBundle bundleForClass: [self class]];
    NSString* allSquadsPath = [testBundle pathForResource: squadfileName ofType: @"spacedocksquads"];
    XCTAssertNotNil(allSquadsPath);
    NSData* allSquadsData = [NSData dataWithContentsOfFile: allSquadsPath];
    XCTAssertNotNil(allSquadsData);
    NSError* error = nil;
    NSArray* allSquadsArray = [NSJSONSerialization JSONObjectWithData: allSquadsData options: 0 error: &error];
    XCTAssertNil(error);
    XCTAssertNotNil(allSquadsArray);
    for (NSDictionary* squadData in allSquadsArray) {
        DockSquad* squad = [DockSquad squad: _context];
        [squad importIntoSquad: squadData replaceUUID: NO];
    }
    NSArray* allSquads = [DockSquad allSquads: _context];
    XCTAssertEqual(allSquads.count, allSquadsArray.count);
    NSInteger count = allSquadsArray.count;
    for (int i = 0; i < count; ++i) {
        NSDictionary* jsonObject = allSquadsArray[i];
        NSString* uuid = jsonObject[@"uuid"];
        XCTAssertNotNil(uuid);
        NSString* name = jsonObject[@"name"];
        XCTAssertNotNil(name);
        DockSquad* loadedSquad = [DockSquad squadForUUID: uuid context: _context];
        XCTAssertNotNil(loadedSquad, @"on squad %@", name);
        XCTAssertEqualObjects(loadedSquad.name, name, @"on squad %@", name);
        XCTAssertEqualObjects(loadedSquad.notes, jsonObject[@"notes"], @"on squad %@", name);
        NSString* resourceId = loadedSquad.resource.externalId;
        XCTAssertEqualObjects(resourceId, jsonObject[@"resource"], @"on squad %@", name);
        XCTAssertEqualObjects(loadedSquad.additionalPoints, jsonObject[@"additionalPoints"], @"on squad %@", name);
        NSArray* jsonShips = jsonObject[@"ships"];
        NSOrderedSet* equippedShips = loadedSquad.equippedShips;
        XCTAssertEqual(jsonShips.count, equippedShips.count, @"on squad %@", name);
        for (int i = 0; i < jsonShips.count; ++i) {
            NSDictionary* shipData = jsonShips[i];
            DockEquippedShip* loadedShip = equippedShips[i];
            NSString* shipId = shipData[@"shipId"];
            XCTAssertEqualObjects(shipId, loadedShip.ship.externalId);
            BOOL shipIsSideboard = [shipData[@"sideboard"] boolValue];
            XCTAssertEqual(shipIsSideboard, loadedShip.isResourceSideboard);
            
            NSDictionary* captainData = shipData[@"captain"];
            XCTAssertNotNil(captainData);
            DockCaptain* captain = [loadedShip captain];
            XCTAssertEqualObjects(captainData[upgradeIdKey], captain.externalId, @"on squad %@", name);
            int cost = [captainData[calculatedCostKey] intValue];
            XCTAssertEqual(cost, loadedShip.equippedCaptain.cost, @"on squad %@", name);
            
            NSArray* upgradeDataArray = shipData[@"upgrades"];
            id upgradeDataComparator = ^(NSDictionary* d1, NSDictionary* d2) {
                NSString* uid1 = d1[upgradeIdKey];
                NSString* uid2 = d2[upgradeIdKey];
                NSComparisonResult r = [uid1 compare: uid2];
                if (false && r == NSOrderedSame) {
                    NSNumber* cost1 = d1[calculatedCostKey];
                    NSNumber* cost2 = d2[calculatedCostKey];
                    r = [cost1 compare: cost2];
                }
                return r;
            };
            upgradeDataArray = [upgradeDataArray sortedArrayUsingComparator: upgradeDataComparator];
            NSArray* upgrades = loadedShip.sortedUpgradesWithoutPlaceholders;
            id upgradeComparator = ^(DockEquippedUpgrade* eu1, DockEquippedUpgrade* eu2) {
                NSComparisonResult r = [eu1.upgrade.externalId compare: eu2.upgrade.externalId];
                if (false && r == NSOrderedSame) {
                    NSNumber* cost1 = [NSNumber numberWithInt: [eu1.upgrade costForShip: loadedShip]];
                    NSNumber* cost2 = [NSNumber numberWithInt: [eu2.upgrade costForShip: loadedShip]];
                    r = [cost1 compare: cost2];
                }
                return r;
            };
            upgrades = [upgrades sortedArrayUsingComparator: upgradeComparator];
            NSInteger limit = MIN(upgrades.count, upgradeDataArray.count);
            for (int upgradeIndex = 0; upgradeIndex < limit; ++upgradeIndex) {
                NSDictionary* upgradeData = upgradeDataArray[upgradeIndex];
                DockEquippedUpgrade* upgrade = upgrades[upgradeIndex];
                XCTAssertEqualObjects(upgrade.upgrade.externalId, upgradeData[upgradeIdKey], @"on squad %@", name);
                int equippedUpgradeCost = [upgrade.upgrade costForShip: loadedShip equippedUpgade: upgrade];
                int expectedEquippedUpgradeCost = [upgradeData[calculatedCostKey] intValue];
                XCTAssertEqual(expectedEquippedUpgradeCost, equippedUpgradeCost, @"on squad %@", name);
            }
            XCTAssertEqual(upgrades.count, upgradeDataArray.count, @"on squad %@", name);
            int shipCost = [shipData[calculatedCostKey] intValue];
            XCTAssertEqual(shipCost, loadedShip.cost, @"on squad %@", name);
        }
        int squadCost = [jsonObject[@"cost"] intValue];
        XCTAssertEqual(squadCost, loadedSquad.cost, @"on squad %@", name);
    }
}

-(void)testLoadList
{
    [self listTester: @"squads_for_test"];
}

-(void)testSpecials
{
    [self listTester: @"specials"];
}

-(void)testTags
{
    DockUpgrade* shockwave = [DockUpgrade upgradeForId: @"shockwave_71448" context:_context];
    XCTAssertNotNil(shockwave);
    XCTAssertEqualObjects(@"Shockwave", shockwave.title);
    XCTAssertEqualObjects(@2, shockwave.cost);
    XCTAssertNotEqualObjects(NO, shockwave.unique);
    XCTAssert([shockwave hasTag: @"requires_raptor_class"], @"Shockwave should have the require_raptor_class tag, but doesn't");
    
    DockSquad* targetSquad = [DockSquad squad: _context];
    XCTAssertNotNil(targetSquad);
    
    DockShip* somraw = [DockShip shipForId: @"i_k_s_somraw_71448" context: _context];
    XCTAssertNotNil(somraw);
    
    DockEquippedShip* es = [DockEquippedShip equippedShipWithShip: somraw];
    XCTAssertNotNil(somraw);
    [targetSquad addEquippedShip: es];
    XCTAssertEqual(1, targetSquad.equippedShips.count);
    
    BOOL canAdd = [es canAddUpgrade: shockwave];
    XCTAssert(canAdd, "Should be able to add Shockwave to the Somraw but can't");
    
    DockShip* raptorClass = [DockShip shipForId: @"klingon_starship_71448" context: _context];
    XCTAssertNotNil(raptorClass);

    es = [DockEquippedShip equippedShipWithShip: raptorClass];
    XCTAssertNotNil(raptorClass);
    [targetSquad addEquippedShip: es];
    XCTAssertEqual(2, targetSquad.equippedShips.count);
    
    canAdd = [es canAddUpgrade: shockwave];
    XCTAssert(canAdd, "Should be able to add Shockwave to the Raptor Class but can't");
    
    DockShip* groth = [DockShip shipForId: @"1015" context: _context];
    XCTAssertNotNil(groth);
    es = [DockEquippedShip equippedShipWithShip: groth];
    [targetSquad addEquippedShip: es];
    XCTAssertEqual(3, targetSquad.equippedShips.count);

    canAdd = [es canAddUpgrade: shockwave];
    XCTAssert(!canAdd, "Should not be able to add Shockwave to the Gr''oth but can");
}

@end
