#import <XCTest/XCTest.h>

#import "DockGameSystem.h"
#import "DockUniverse.h"

@interface MetaDockTests : XCTestCase
@property (strong, nonatomic) DockUniverse* universe;
@end

@implementation MetaDockTests

- (void)setUp
{
    [super setUp];
    NSProcessInfo* info = [NSProcessInfo processInfo];
    NSString* baseDir = info.environment[@"PWD"];
    NSString* gameSystemDir = [baseDir stringByAppendingPathComponent: @"GameSystems"];
    _universe = [[DockUniverse alloc] initWithDataStorePath: @"" templatesPath: gameSystemDir];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testLoadingGameSystems
{
    NSSet* gameSystems = [_universe gameSystems];

    XCTAssertEqual(gameSystems.count, 3);

    NSArray* expectedTitles = @[
        @"Star Trek: Attack Wing",
        @"D&D Attack Wing",
        @"X-Wing"
    ];

    for (NSString* expectedTitle in expectedTitles) {
        id objectWithTitle = ^(id obj, BOOL* stop) {
            NSString* title = [obj title];
            return [title isEqualToString: expectedTitle];
        };
        NSSet* matching = [gameSystems objectsPassingTest: objectWithTitle];
        XCTAssertEqual(matching.count, 1, @"Expected to find a game system titled '%@' but didn't.", expectedTitle);
    }
}

-(void)testGameSystemTerms
{
    DockGameSystem* staw = [_universe gameSystemWithIdentifier: @"staw"];
    XCTAssertNotNil(staw);
    XCTAssertEqualObjects([staw term: @"list" count: 0], @"Squads");
    XCTAssertEqualObjects([staw term: @"list" count: 1], @"Squad");
    XCTAssertEqualObjects([staw term: @"list" count: 3], @"Squads");

    DockGameSystem* ddaw = [_universe gameSystemWithIdentifier: @"ddaw"];
    XCTAssertNotNil(ddaw);
    XCTAssertEqualObjects([ddaw term: @"list" count: 0], @"Legions");
    XCTAssertEqualObjects([ddaw term: @"list" count: 1], @"Legion");
    XCTAssertEqualObjects([ddaw term: @"list" count: 3], @"Legions");

    DockGameSystem* xwing = [_universe gameSystemWithIdentifier: @"xwing"];
    XCTAssertNotNil(xwing);
    XCTAssertEqualObjects([xwing term: @"list" count: 0], @"Squads");
    XCTAssertEqualObjects([xwing term: @"list" count: 1], @"Squad");
    XCTAssertEqualObjects([xwing term: @"list" count: 3], @"Squads");

}

@end
