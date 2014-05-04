#import "DockBuildMat.h"

#import "DockEquippedShip+Addons.h"
#import "DockMoveGrid.h"
#import "DockShip+Addons.h"
#import "DockSquad+Addons.h"

@interface DockShipTile : NSObject
-(id)initWithShip:(DockShip*)ship;
@end

@interface DockShipTile ()
@property (assign, nonatomic) IBOutlet NSView* view;
@property (strong, nonatomic) NSArray* topLevelObjects;
@property (strong, nonatomic) DockShip* ship;
@end

@implementation DockShipTile

-(id)initWithShip:(DockShip*)ship
{
    self = [super init];
    if (self != nil) {
        self.ship = ship;
        NSArray* tla;
        [[NSBundle mainBundle] loadNibNamed: @"ShipTile" owner: self topLevelObjects: &tla];
        self.topLevelObjects = tla;
    }
    return self;
}

@end

@interface DockBuildMat () <NSTableViewDataSource>
@property (nonatomic, strong) NSArray* topLevelObjects;
@property (nonatomic, strong) NSMutableArray* tiles;
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
    [_tiles removeAllObjects];
    [_tableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _targetSquad.equippedShips.count;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    DockEquippedShip* equippedShip = _targetSquad.equippedShips[row];
    DockShip* ship = equippedShip.ship;
    NSUInteger column = [[tableView tableColumns] indexOfObject: tableColumn];
    NSRect c = [tableView rectOfColumn: column];
    NSRect r = [tableView rectOfRow: row];
    NSRect cellRect = NSIntersectionRect(c, r);
    if (column == 0) {
        DockMoveGrid* grid = [[DockMoveGrid alloc] initWithFrame: cellRect];
        grid.ship = ship;
        return grid;
    }
    if (column == 1) {
        DockShipTile* shipTile = [[DockShipTile alloc] initWithShip: ship];
        [_tiles addObject: shipTile];
        return shipTile.view;
    }
    return [[NSView alloc] initWithFrame: cellRect];
}

@end
