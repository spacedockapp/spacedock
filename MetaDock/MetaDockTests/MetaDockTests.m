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
    NSString* templatesPath = [[NSBundle mainBundle] pathForResource: @"GameSystems" ofType: @""];
    _universe = [[DockUniverse alloc] initWithDataStorePath: @"" templatesPath: templatesPath];
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

-(void)testGameSystemComponents
{
    DockGameSystem* staw = [_universe gameSystemWithIdentifier: @"staw"];
    XCTAssertNotNil(staw);

    NSSet* components = [staw components];
    XCTAssertNotNil(staw);
    int minComponents = 100;
    XCTAssertTrue(components.count > 100,  @"Expected staw to have more than %d components, but it has %d instead", minComponents, (int)components.count);
}

@end
