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

/*
        Set reliantSet = universe.sets.get("71121");
        assertNotNil("Couldn't get core set", reliantSet);
        assertEquals("Count of items in reliant expansion wrong", 12,
                reliantSet.getItems().size());
*/
- (void)testLoad
{
    {
        NSArray* allShips = [DockShip allShips: _context];
        XCTAssertEqual(91, allShips.count);
    }
    
    {
        DockShip* entD = [DockShip shipForId: @"1001" context: _context];
        XCTAssertNotNil(entD);
        XCTAssertEqual(4, [entD.attack intValue]);
        XCTAssertEqualObjects(@"Federation", entD.faction);
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
        XCTAssertEqualObjects(@"Independent", fs.faction);
    }
    
    {
        DockResource* tokens = [DockResource resourceForId: @"4002" context: _context];
        XCTAssertNotNil(tokens);
        XCTAssertEqualObjects(@5, tokens.cost);
    }
    
    {
        DockSet* coreSet = [DockSet setForId: @"71120" context: _context];
        XCTAssertNotNil(coreSet);
        XCTAssertEqual(32, coreSet.items.count);
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
        XCTAssertNotNil(loadedSquad);
        XCTAssertEqualObjects(loadedSquad.name, name);
        XCTAssertEqualObjects(loadedSquad.notes, jsonObject[@"notes"]);
        NSString* resourceId = loadedSquad.resource.externalId;
        XCTAssertEqualObjects(resourceId, jsonObject[@"resource"]);
        XCTAssertEqualObjects(loadedSquad.additionalPoints, jsonObject[@"additionalPoints"]);
        NSArray* jsonShips = jsonObject[@"ships"];
        NSOrderedSet* equippedShips = loadedSquad.equippedShips;
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
            XCTAssertEqualObjects(captainData[@"upgradeId"], captain.externalId, @"on squad %@", name);
            int cost = [captainData[@"calculatedCost"] intValue];
            XCTAssertEqual(cost, loadedShip.equippedCaptain.cost, @"on squad %@", name);
            
            NSArray* upgradeDataArray = shipData[@"upgrades"];
            NSArray* upgrades = loadedShip.sortedUpgradesWithoutPlaceholders;
            NSInteger limit = MIN(upgrades.count, upgradeDataArray.count);
            for (int upgradeIndex = 0; upgradeIndex < limit; ++upgradeIndex) {
                NSDictionary* upgradeData = upgradeDataArray[upgradeIndex];
                DockEquippedUpgrade* upgrade = upgrades[upgradeIndex];
                XCTAssertEqualObjects(upgrade.upgrade.externalId, upgradeData[@"upgradeId"], @"on squad %@", name);
                int equippedUpgradeCost = [upgrade.upgrade costForShip: loadedShip];
                int expectedEquippedUpgradeCost = [upgradeData[@"calculatedCost"] intValue];
                XCTAssertEqual(expectedEquippedUpgradeCost, equippedUpgradeCost, @"on squad %@", name);
            }
            XCTAssertEqual(upgrades.count, upgradeDataArray.count);
            int shipCost = [shipData[@"calculatedCost"] intValue];
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

@end
