#import "DockBuildMat.h"

#import "DockEquippedFlagship.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockMoveGrid.h"
#import "DockShip+Addons.h"
#import "DockSquad+Addons.h"
#import "DockUpgrade+Addons.h"

@interface DockBuildMatTile : NSObject
@property (strong, nonatomic) IBOutlet NSView* view;
@property (strong, nonatomic) NSArray* topLevelObjects;
-(id)initWithNib:(NSString*)nibName;
@end

@implementation DockBuildMatTile

-(id)initWithNib:(NSString*)nibName
{
    self = [super init];
    if (self != nil) {
        NSArray* tla;
        [[NSBundle mainBundle] loadNibNamed: nibName owner: self topLevelObjects: &tla];
        self.topLevelObjects = tla;
    }
    return self;
}

@end

@interface DockShipTile : DockBuildMatTile
@property (strong, nonatomic) DockShip* ship;
-(id)initWithShip:(DockShip*)ship;
@end

@implementation DockShipTile

-(id)initWithShip:(DockShip*)ship
{
    self = [super initWithNib: @"ShipTile"];
    if (self != nil) {
        self.ship = ship;
    }
    return self;
}

@end

@interface DockMoveGridTile : DockBuildMatTile
@property (strong, nonatomic) DockShip* ship;
-(id)initWithShip:(DockShip*)ship;
@end

@implementation DockMoveGridTile

-(id)initWithShip:(DockShip*)ship
{
    self = [super init];
    if (self != nil) {
        self.ship = ship;
        DockMoveGrid* grid = [[DockMoveGrid alloc] init];
        grid.ship = ship;
        self.view = grid;
    }
    return self;
}

@end

@interface DockCaptainTile : DockBuildMatTile
@property (strong, nonatomic) DockCaptain* captain;
-(id)initWithCaptain:(DockCaptain*)captain;
@end

@implementation DockCaptainTile

-(id)initWithCaptain:(DockCaptain*)captain
{
    self = [super initWithNib: @"CaptainTile"];
    if (self != nil) {
        self.captain = captain;
    }
    return self;
}

@end

@interface DockFlagshipTile : DockBuildMatTile
@property (strong, nonatomic) DockFlagship* flagship;
-(id)initWithFlagship:(DockFlagship*)flagship;
@end

@implementation DockFlagshipTile

-(id)initWithFlagship:(DockFlagship*)flagship
{
    self = [super initWithNib: @"FlagshipTile"];
    if (self != nil) {
        self.flagship = flagship;
    }
    return self;
}

@end

@interface DockBuildMat () <NSTableViewDataSource>
@property (strong, nonatomic) NSArray* topLevelObjects;
@property (nonatomic, strong) NSMutableArray* rows;
@property (nonatomic, strong) DockSquad* targetSquad;
@property (nonatomic, strong) NSArrayController* squadsController;
@property (nonatomic, strong) IBOutlet NSWindow* window;
@property (nonatomic, strong) IBOutlet NSTableView* tableView;
@end

@implementation DockBuildMat

-(id)initWithSquads:(NSArrayController*)squadsController
{
    self = [super init];
    if (self != nil) {
        _rows = [[NSMutableArray alloc] initWithCapacity: 0];
        self.squadsController = squadsController;
        [_squadsController addObserver: self forKeyPath: @"selectionIndexes" options: 0 context: 0];
    }
    return self;
}

-(void)show
{
    if (_window == nil) {
        NSArray* a;
        NSBundle* mainBundle = [NSBundle mainBundle];
        [mainBundle loadNibNamed: @"BuildMat" owner: self topLevelObjects: &a];
        _topLevelObjects = a;
        self.targetSquad = _squadsController.selectedObjects.firstObject;
        [self update];
    }
    [_window makeKeyAndOrderFront: nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSArray* selected = _squadsController.selectedObjects;
    DockSquad* target = selected.firstObject;
    if (_targetSquad != target) {
        self.targetSquad = target;
        [self update];
    }
}

-(void)update
{
    [_rows removeAllObjects];
    NSUInteger rowCount = _targetSquad.equippedShips.count;
    for (NSUInteger i = 0; i < rowCount; ++i) {
        NSMutableArray* oneRow = [[NSMutableArray alloc] initWithCapacity: 6];
        [_rows addObject: oneRow];
        DockEquippedShip* equippedShip = _targetSquad.equippedShips[i];
        DockShip* ship = equippedShip.ship;
        DockMoveGridTile* moveTile = [[DockMoveGridTile alloc] initWithShip: ship];
        [oneRow addObject: moveTile];
        DockShipTile* shipTile = [[DockShipTile alloc] initWithShip: ship];
        [oneRow addObject: shipTile];
        DockFlagship* flagship = equippedShip.flagship;
        if (flagship) {
            DockFlagshipTile* flagshipTile = [[DockFlagshipTile alloc] initWithFlagship: flagship];
            [oneRow addObject: flagshipTile];
        }
        for (DockEquippedUpgrade* equippedUpgrade in equippedShip.sortedUpgrades) {
            DockUpgrade* upgrade = equippedUpgrade.upgrade;
            if (upgrade.isCaptain) {
                DockCaptainTile* captainTile = [[DockCaptainTile alloc] initWithCaptain: equippedShip.captain];
                [oneRow addObject: captainTile];
            }
            if (oneRow.count > 5) {
                oneRow = [[NSMutableArray alloc] initWithCapacity: 6];
                [_rows addObject: oneRow];
            }
        }
    }
    [_tableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _rows.count;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSUInteger column = [[tableView tableColumns] indexOfObject: tableColumn];
    NSRect c = [tableView rectOfColumn: column];
    NSRect r = [tableView rectOfRow: row];
    NSRect cellRect = NSIntersectionRect(c, r);
    NSArray* oneRow = _rows[row];
    if (column < oneRow.count) {
        DockBuildMatTile* tile = oneRow[column];
        return tile.view;
    }
    return [[NSView alloc] initWithFrame: cellRect];
}

@end
