#import "DockBuildMat.h"

#import "DockAdmiral+MacAddons.h"
#import "DockCaptain+Addons.h"
#import "DockEquippedFlagship.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockMoveGrid.h"
#import "DockShip+Addons.h"
#import "DockSquad+Addons.h"
#import "DockUpgrade+Addons.h"
#import "DockWeapon+Addons.h"

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

-(id)init
{
    self = [super init];
    if (self != nil) {
        self.view = [[NSView alloc] init];
    }
    return self;
}

@end

@interface DockShipTile : DockBuildMatTile
@property (strong, nonatomic) DockEquippedShip* ship;
-(id)initWithShip:(DockEquippedShip*)ship;
@end

@implementation DockShipTile

-(id)initWithShip:(DockEquippedShip*)ship
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
        grid.whiteBackground = YES;
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

@interface DockAdmiralTile : DockBuildMatTile
@property (strong, nonatomic) DockAdmiral* admiral;
-(id)initWithAdmiral:(DockAdmiral*)admiral;
@end

@implementation DockAdmiralTile

-(id)initWithAdmiral:(DockAdmiral*)admiral
{
    self = [super initWithNib: @"AdmiralTile"];
    if (self != nil) {
        self.admiral = admiral;
    }
    return self;
}

-(NSAttributedString*)styledSkillModifier
{
    return self.admiral.styledSkillModifier;
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

@interface DockUpgradeTile : DockBuildMatTile
@property (strong, nonatomic) DockUpgrade* upgrade;
-(id)initWithUpgrade:(DockUpgrade*)upgrade;
@end

@implementation DockUpgradeTile

-(id)initWithUpgrade:(DockUpgrade*)upgrade
{
    self = [super initWithNib: @"UpgradeTile"];
    if (self != nil) {
        self.upgrade = upgrade;
    }
    return self;
}

@end

@interface DockWeaponTile : DockBuildMatTile
@property (strong, nonatomic) DockWeapon* weapon;
-(id)initWithWeapon:(DockWeapon*)weapon;
@end

@implementation DockWeaponTile

-(id)initWithWeapon:(DockWeapon*)weapon
{
    self = [super initWithNib: @"WeaponTile"];
    if (self != nil) {
        self.weapon = weapon;
    }
    return self;
}

@end

@interface DockBuildMat () <NSTableViewDataSource>
@property (strong, nonatomic) NSArray* topLevelObjects;
@property (nonatomic, strong) NSMutableArray* rows;
@property (nonatomic, strong) DockSquad* targetSquad;
@property (nonatomic, strong) IBOutlet NSTableView* tableView;
@end

@implementation DockBuildMat

-(id)initWithSquad:(DockSquad*)targetSquad
{
    self = [super init];
    if (self != nil) {
        self.targetSquad = targetSquad;
        _rows = [[NSMutableArray alloc] initWithCapacity: 0];
    }
    return self;
}

-(void)update
{
    [_rows removeAllObjects];
    NSComparator c = ^(id a, id b) {
        NSNumber* skillA = @6;
        NSNumber* skillB = @6;
        DockEquippedShip* shipA = a;
        DockCaptain* captainA = shipA.captain;
        if (captainA) {
            skillA = captainA.skill;
        }
        DockEquippedShip* shipB = b;
        DockCaptain* captainB = shipB.captain;
        if (captainB) {
            skillB = captainB.skill;
        }
        NSComparisonResult res = [skillA compare: skillB];
        if (res == NSOrderedSame) {
            res = [shipA.plainDescription compare: shipB.plainDescription];
        }
        if (res == NSOrderedSame) {
            NSString* bTitle = captainB.plainDescription;
            if (bTitle == nil) {
                return NSOrderedAscending;
            }
            res = [captainA.title compare: bTitle];
        }
        return res;
    };
    NSArray* sortedShips = [_targetSquad.equippedShips sortedArrayUsingComparator: c];
    NSUInteger rowCount = sortedShips.count;
    for (NSUInteger i = 0; i < rowCount; ++i) {
        NSMutableArray* oneRow = [[NSMutableArray alloc] initWithCapacity: 6];
        [_rows addObject: oneRow];
        DockEquippedShip* equippedShip = sortedShips[i];
        DockShip* ship = equippedShip.ship;
        DockMoveGridTile* moveTile = [[DockMoveGridTile alloc] initWithShip: ship];
        [oneRow addObject: moveTile];
        DockShipTile* shipTile = [[DockShipTile alloc] initWithShip: equippedShip];
        [oneRow addObject: shipTile];
        DockFlagship* flagship = equippedShip.flagship;
        if (flagship) {
            DockFlagshipTile* flagshipTile = [[DockFlagshipTile alloc] initWithFlagship: flagship];
            [oneRow addObject: flagshipTile];
        }
        for (DockEquippedUpgrade* equippedUpgrade in equippedShip.sortedUpgrades) {
            DockBuildMatTile* tile = nil;
            DockUpgrade* upgrade = equippedUpgrade.upgrade;
            if (upgrade.isCaptain) {
                //tile = [[DockCaptainTile alloc] initWithCaptain: equippedShip.captain];
                tile = [[DockCaptainTile alloc] initWithCaptain: (DockCaptain*)upgrade];
            } else if (upgrade.isAdmiral) {
                DockAdmiral* admiral = (DockAdmiral*)upgrade;
                tile = [[DockAdmiralTile alloc] initWithAdmiral: admiral];
                [oneRow addObject: tile];
                tile = [[DockCaptainTile alloc] initWithCaptain: admiral];
            } else if (!upgrade.isPlaceholder) {
                if (upgrade.isWeapon) {
                    tile = [[DockWeaponTile alloc] initWithWeapon: (DockWeapon*)upgrade];
                } else {
                    tile = [[DockUpgradeTile alloc] initWithUpgrade: upgrade];
                }
            }
            
            if (tile != nil) {
                if (oneRow.count > 5) {
                    oneRow = [[NSMutableArray alloc] initWithCapacity: 6];
                    [_rows addObject: oneRow];
                    [oneRow addObject: [[DockBuildMatTile alloc] init]];
                }
                [oneRow addObject: tile];
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

-(void)print
{
    if (_tableView == nil) {
        NSArray* a;
        NSBundle* mainBundle = [NSBundle mainBundle];
        [mainBundle loadNibNamed: @"BuildMat" owner: self topLevelObjects: &a];
        _topLevelObjects = a;
    }
    [self update];
    NSPrintInfo* info = [NSPrintInfo sharedPrintInfo];
    info.leftMargin = 0;
    info.rightMargin = 0;
    info.topMargin = 0;
    info.bottomMargin = 0;
    NSMutableDictionary* dict = [info dictionary];
    dict[NSPrintHorizontalPagination] = [NSNumber numberWithInt: NSFitPagination];
    dict[NSPrintVerticalPagination] = [NSNumber numberWithInt: NSAutoPagination];
    dict[NSPrintHorizontallyCentered] = [NSNumber numberWithBool: YES];
    dict[NSPrintVerticallyCentered] = [NSNumber numberWithBool: YES];
    dict[NSPrintOrientation] = [NSNumber numberWithInt: NSLandscapeOrientation];
    NSRect r = [info imageablePageBounds];
    [_tableView setFrameSize: r.size];
    [_tableView sizeToFit];
    [[NSPrintOperation printOperationWithView: _tableView] runOperation];
}

@end
