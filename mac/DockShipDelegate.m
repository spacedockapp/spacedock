#import "DockShipDelegate.h"

#import "DockMoveGrid.h"

@implementation DockShipDelegate

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    if (self.expandedRows) {
        CGFloat height = [super tableView: tableView heightOfRow: row];
        if (height < 130) {
            return 130;
        }
        return height;
    }
    return tableView.rowHeight;
}

-(void)updateRows
{
    [self.targetTable reloadData];
}

-(NSIndexSet*)rowsToChange
{
    return [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, [self.targetController.arrangedObjects count])];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString* identifier = tableColumn.identifier;
    NSView* view = [tableView makeViewWithIdentifier: identifier owner: self];
    if ([identifier isEqualToString: @"moveGrid"]) {
        DockMoveGrid* grid = view.subviews[0];
        if (!self.expandedRows) {
            [grid setHidden: YES];
        } else {
            [grid setHidden: NO];
            DockShip* ship = self.targetController.arrangedObjects[row];
            grid.ship = ship;
        }
    }
    
    return view;
}

@end
