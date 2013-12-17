#import "DockFleetBuildSheet2.h"

#import "DockCaptain+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockUpgrade+Addons.h"
#import "DockResource+Addons.h"
#import "DockSquad+Addons.h"

@interface DockFleetBuildSheetShip : NSObject <NSTableViewDataSource>
@property (nonatomic, strong) NSArray* topLevelObjects;
@property (nonatomic, strong) IBOutlet NSView* gridContainer;
@property (nonatomic, strong) IBOutlet NSTableView* shipGrid;
@property (nonatomic, strong) IBOutlet NSTextField* totalSP;
@property (nonatomic, strong) DockEquippedShip* equippedShip;
@property (nonatomic, strong) NSMutableArray* upgrades;
@end

const int kExtraRows = 3;

@implementation DockFleetBuildSheetShip

-(void)setEquippedShip:(DockEquippedShip *)equippedShip
{
    if (_equippedShip != equippedShip) {
        _equippedShip = equippedShip;

        if (_equippedShip) {
            NSArray* equippedUpgrades = equippedShip.sortedUpgrades;
            _upgrades = [[NSMutableArray alloc] initWithCapacity: equippedUpgrades.count];

            for (DockEquippedUpgrade* upgrade in equippedUpgrades) {
                if (![upgrade isPlaceholder] && ![upgrade.upgrade isCaptain]) {
                    [_upgrades addObject: upgrade];
                }
            }
        } else {
            _upgrades = nil;
        }
        [_totalSP setIntValue: _equippedShip.cost];
    }
    [_shipGrid reloadData];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if (_upgrades) {
        return _upgrades.count + kExtraRows;
    }
    return 0;
}

NSAttributedString* headerText(NSString* string)
{
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSCenterTextAlignment];
    NSDictionary* attributes = @{
                                 NSFontAttributeName: [NSFont userFontOfSize: 7],
                                 NSParagraphStyleAttributeName: paragraphStyle
                                 };
    return [[NSAttributedString alloc] initWithString: string attributes: attributes];
}

-(id)handleHeader:(NSString*)identifier
{
    if ([identifier isEqualToString: @"type"]) {
        return headerText(@"Type");
    }

    if ([identifier isEqualToString: @"faction"]) {
        return headerText(@"Faction");
    }

    if ([identifier isEqualToString: @"sp"]) {
        return headerText(@"SP");
    }
    
    return headerText(@"Card Title");
}

-(id)handleShip:(NSString*)identifier
{
    if ([identifier isEqualToString: @"type"]) {
        return @"Ship";
    }

    if ([identifier isEqualToString: @"faction"]) {
        return [_equippedShip factionCode];
    }

    if ([identifier isEqualToString: @"sp"]) {
        return [NSNumber numberWithInt: [_equippedShip baseCost]];
    }
    
    return [_equippedShip descriptiveTitle];
}

-(id)handleCaptain:(NSString*)identifier
{
    if ([identifier isEqualToString: @"type"]) {
        return @"Cap";
    }

    DockEquippedUpgrade* equippedCaptain = [_equippedShip equippedCaptain];
    DockCaptain* captain = (DockCaptain*)[equippedCaptain upgrade];

    if ([identifier isEqualToString: @"faction"]) {
        return [captain factionCode];
    }

    if ([identifier isEqualToString: @"sp"]) {
        return [NSNumber numberWithInt: equippedCaptain.cost];
    }
    

    return captain.title;
}

-(id)handleUpgrade:(NSString*)identifier index:(long)index
{
    if (index < _upgrades.count) {
        DockEquippedUpgrade* equippedUpgrade = _upgrades[index];
        if ([identifier isEqualToString: @"type"]) {
            return equippedUpgrade.upgrade.typeCode;
        }
        if ([identifier isEqualToString: @"faction"]) {
            return equippedUpgrade.upgrade.factionCode;
        }

        if ([identifier isEqualToString: @"sp"]) {
            return [NSNumber numberWithInt: [equippedUpgrade cost]];
        }
        
        return equippedUpgrade.upgrade.title;
    }

    return nil;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    switch (row) {
        case 0:
            return [self handleHeader: tableColumn.identifier];
            
        case 1:
            return [self handleShip: tableColumn.identifier];
            
        case 2:
            return [self handleCaptain: tableColumn.identifier];
            
        default:
            return [self handleUpgrade: tableColumn.identifier index: row - kExtraRows];
    }
    return nil;
}

@end

@interface DockFleetBuildSheet2 () <NSTableViewDataSource> {
    NSMutableArray* _shipDataList;
    NSNumber* _squadTotalCost;
    NSString* _date;
    NSDictionary* _dataForResource;
    NSMutableArray* _buildShips;
}
@property (strong, nonatomic) IBOutlet NSBox* sheetBox;
@property (strong, nonatomic) IBOutlet NSView* box1;
@property (strong, nonatomic) IBOutlet NSView* box2;
@property (strong, nonatomic) IBOutlet NSView* box3;
@property (strong, nonatomic) IBOutlet NSView* box4;
@property (strong, nonatomic) DockSquad* targetSquad;
@end

@implementation DockFleetBuildSheet2


-(void)awakeFromNib
{
    _buildShips = [[NSMutableArray alloc] init];
    NSArray* views = @[_box1, _box2, _box3, _box4];
    NSBundle* mainBundle = [NSBundle mainBundle];
    for (int i = 0; i < 4; ++i) {
        DockFleetBuildSheetShip* ship = [[DockFleetBuildSheetShip alloc] init];
        NSArray* a;
        [mainBundle loadNibNamed: @"ShipGrid" owner: ship topLevelObjects: &a];
        ship.topLevelObjects = a;
        NSView* view = views[i];
        [ship.gridContainer setFrameSize: view.frame.size];
        [view addSubview: ship.gridContainer];
        [_buildShips addObject: ship];
    }
}

-(void)print:(DockSquad*)squad;
{
    _targetSquad = squad;
    NSOrderedSet* equippedShips = _targetSquad.equippedShips;
    for (int i = 0; i < 4; ++i) {
        DockEquippedShip* equippedShip = nil;
        if (i < equippedShips.count) {
            equippedShip = _targetSquad.equippedShips[i];
        }
        DockFleetBuildSheetShip* buildSheetShip = _buildShips[i];
        buildSheetShip.equippedShip = equippedShip;
    }

    NSPrintInfo* info = [NSPrintInfo sharedPrintInfo];
    info.leftMargin = 0;
    info.rightMargin = 0;
    info.topMargin = 0;
    info.bottomMargin = 0;
    NSMutableDictionary* dict = [info dictionary];
    dict[NSPrintHorizontalPagination] = [NSNumber numberWithInt: NSFitPagination];
    dict[NSPrintVerticalPagination] = [NSNumber numberWithInt: NSFitPagination];
    dict[NSPrintHorizontallyCentered] = [NSNumber numberWithBool: YES];
    dict[NSPrintVerticallyCentered] = [NSNumber numberWithBool: YES];
    NSRect r = [info imageablePageBounds];
    [_sheetBox setFrameSize: r.size];
    [[NSPrintOperation printOperationWithView: _sheetBox] runOperation];
}

@end
