#import "DockDialPrinter.h"

#import "DockDialView.h"

@interface DockDialPrinter ()
@property (nonatomic, strong) IBOutlet NSArrayController* shipsController;
@property (nonatomic, strong) IBOutlet NSArrayController* craftController;
@property (nonatomic, strong) IBOutlet NSTabView* tabView;
@property (nonatomic, strong) IBOutlet NSTableView* dialsTable;
@property (nonatomic, strong) NSArray* shipsToPrint;
@end

@implementation DockDialPrinter

-(void)awakeFromNib
{
    [_shipsController addObserver: self forKeyPath: @"selectionIndexes" options: 0 context: 0];
    [_craftController addObserver: self forKeyPath: @"selectionIndexes" options: 0 context: 0];
    [_tabView addObserver: self forKeyPath: @"selectedTabViewItem" options: 0 context: 0];
}

-(void)updateShips
{
    NSArray* selected = nil;
    NSTabViewItem* tabViewItem = _tabView.selectedTabViewItem;
    if ([tabViewItem.identifier isEqualToString: @"ships"]) {
        selected = [_shipsController selectedObjects];
    } else if ([tabViewItem.identifier isEqualToString: @"craft"]) {
        selected = [_craftController selectedObjects];
    }
    _shipsToPrint = [NSArray arrayWithArray: selected];
    [_dialsTable reloadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    @try {
        [self updateShips];
    } @catch (NSException *exception) {
        NSLog(@"caught exception %@", exception);
    } @finally {
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSArray* columns = tableView.tableColumns;
    return ceil(_shipsToPrint.count / (float)columns.count);
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSUInteger column = [[tableView tableColumns] indexOfObject: tableColumn];
    NSRect c = [tableView rectOfColumn: column];
    NSRect r = [tableView rectOfRow: row];
    NSRect cellRect = NSIntersectionRect(c, r);
    DockDialView* dialView = [[DockDialView alloc] initWithFrame: cellRect];
    NSArray* columns = tableView.tableColumns;
    NSInteger index = row * columns.count + [columns indexOfObject: tableColumn];
    if (index >= 0 && index < _shipsToPrint.count) {
        DockShip* ship = _shipsToPrint[index];
        dialView.ship = ship;
    }
    return dialView;
}

-(IBAction)print:(id)sender
{
    [self updateShips];
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
    [_dialsTable setFrameSize: r.size];
    [_dialsTable sizeToFit];
    [[NSPrintOperation printOperationWithView: _dialsTable] runOperation];
}



@end
