
#import "DockAbilityDelegate.h"

#import "DockAppDelegate.h"

@interface DockAbilityDelegate ()
@property (strong) IBOutlet NSArrayController* targetController;
@property (strong) IBOutlet NSTableView* targetTable;
@property (assign) CGFloat abilityWidth;
@property (assign) BOOL expandedRows;
@end

@implementation DockAbilityDelegate

-(void)updateRows
{
    NSArray* targets = _targetController.arrangedObjects;
    NSMutableIndexSet* set = [[NSMutableIndexSet alloc] init];
    int index = 0;
    for (id target in targets) {
        NSString* ability = [target valueForKey: @"ability"];
        if (ability.length > 0) {
            [set addIndex: index];
        }
        index += 1;
    }
    [_targetTable noteHeightOfRowsWithIndexesChanged: set];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    BOOL expandedRows = [object boolForKey: kExpandedRows];
    if (expandedRows != _expandedRows) {
        _expandedRows = expandedRows;
        [self updateRows];
    }
}

-(void)awakeFromNib
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    _expandedRows = [defaults boolForKey: kExpandedRows];
    [defaults addObserver: self forKeyPath: kExpandedRows options: 0 context: 0];
}

- (void)tableViewColumnDidResize:(NSNotification *)aNotification
{
    if (_expandedRows) {
        NSDictionary* info = [aNotification userInfo];
        NSTableColumn* col = [info valueForKey: @"NSTableColumn"];
        NSString* identifier = [col identifier];
        if ([identifier isEqualToString: @"ability"]) {
            _abilityWidth = 0;
            [self updateRows];
        }
    }
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row
{
    if (_expandedRows) {
        if (_abilityWidth == 0) {
            NSInteger columnIndex = [tableView columnWithIdentifier: @"ability"];
            if (columnIndex != -1) {
                NSArray* allColumns = [tableView tableColumns];
                NSTableColumn* col = allColumns[columnIndex];
                _abilityWidth = col.width;
                [self updateRows];
            }
        }
    }
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    if (_expandedRows) {
        NSArray* targets = _targetController.arrangedObjects;
        id target = targets[row];
        NSString* ability = [target valueForKey: @"ability"];
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
    }
    return tableView.rowHeight;
}

@end
