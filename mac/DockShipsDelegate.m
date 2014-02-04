
#import "DockShipsDelegate.h"

#import "DockShip+Addons.h"

@interface DockShipsDelegate ()
@property (strong) IBOutlet NSArrayController* shipsController;
@property (assign) CGFloat abilityWidth;
@end

@implementation DockShipsDelegate

- (void)tableViewColumnDidResize:(NSNotification *)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    NSTableColumn* col = [info valueForKey: @"NSTableColumn"];
    NSString* identifier = [col identifier];
    if ([identifier isEqualToString: @"ability"]) {
        _abilityWidth = 0;
        NSArray* ships = _shipsController.arrangedObjects;
        NSRange indexRange = NSMakeRange(0, ships.count);
        [col.tableView noteHeightOfRowsWithIndexesChanged: [NSIndexSet indexSetWithIndexesInRange: indexRange]];
    }
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row
{
    if (_abilityWidth == 0) {
        NSInteger columnIndex = [tableView columnWithIdentifier: @"ability"];
        NSArray* allColumns = [tableView tableColumns];
        NSTableColumn* col = allColumns[columnIndex];
        _abilityWidth = col.width;
        NSArray* ships = _shipsController.arrangedObjects;
        NSRange indexRange = NSMakeRange(0, ships.count);
        [tableView noteHeightOfRowsWithIndexesChanged: [NSIndexSet indexSetWithIndexesInRange: indexRange]];
    }
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    NSArray* ships = _shipsController.arrangedObjects;
    DockShip* ship = ships[row];
    NSString* ability = ship.ability;
    if (ability.length > 0) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        NSDictionary *attributes = @{
                                     NSParagraphStyleAttributeName : paragraphStyle,
                                     NSFontAttributeName: [NSFont systemFontOfSize: 13]
                                     };
        NSAttributedString* as = [[NSAttributedString alloc] initWithString: ability attributes: attributes];
        NSRect r = [as boundingRectWithSize: NSMakeSize(_abilityWidth, 10000) options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine];
        return r.size.height;
    }
    return tableView.rowHeight;
}

@end
