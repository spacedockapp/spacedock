
#import "DockAbilityDelegate.h"

#import "DockAppDelegate.h"

@interface DockAbilityDelegate ()
@property (assign) CGFloat abilityWidth;
@property (strong, nonatomic) NSDictionary* textAttributes;
@property (strong, atomic) NSOperationQueue* measureQueue;
@property (strong, atomic) NSDictionary* lineHeights;
-(BOOL)updateAbiltyWidth;
@end

@implementation DockAbilityDelegate

-(NSIndexSet*)rowsToChange
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
    return set;
}

-(void)allLineHeightsChanged
{
    [_targetTable reloadData];
}

-(void)acceptLineHeights:(NSDictionary*)lineHeights
{
    if (_lineHeights == nil || ![lineHeights isEqualToDictionary: _lineHeights]) {
        _lineHeights = lineHeights;
        [self allLineHeightsChanged];
    }
}

-(void)measureRows
{
    if (!_expandedRows) {
        return;
    }
    CGFloat minHeight = _targetTable.rowHeight;
    NSManagedObjectContext* parentContext = _targetController.managedObjectContext;
    NSString* entityName = _targetController.entityName;
    id measureBlock = ^() {
        NSManagedObjectContext* workContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
        workContext.parentContext = parentContext;
        NSMutableDictionary* lineHeights = [[NSMutableDictionary alloc] init];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        NSDictionary* textAttributes = @{
                                     NSParagraphStyleAttributeName : paragraphStyle,
                                     NSFontAttributeName: [NSFont systemFontOfSize: 13]
                                     };

        NSEntityDescription* entity = [NSEntityDescription entityForName: entityName inManagedObjectContext: workContext];
        NSFetchRequest* request = [[NSFetchRequest alloc] init];
        [request setEntity: entity];
        NSError* err;
        NSArray* work = [workContext executeFetchRequest: request error: &err];

        for (id target in work) {
            id objectId = [target valueForKey: @"objectID"];
            NSString* ability = [target valueForKey: @"ability"];
            CGFloat height = minHeight;
            if (ability != nil) {
                NSAttributedString* as = [[NSAttributedString alloc] initWithString: ability attributes: textAttributes];
                NSRect r = [as boundingRectWithSize: NSMakeSize(_abilityWidth, 10000) options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine];
                height = r.size.height;
                if (height < minHeight) {
                    height = minHeight;
                }
            }
            lineHeights[objectId] = [NSNumber numberWithFloat: height];
        }
        NSDictionary* finalLineHeights = [NSDictionary dictionaryWithDictionary: lineHeights];
        id measureDoneBlock = ^() {
            [self acceptLineHeights: finalLineHeights];
        };
        [[NSOperationQueue mainQueue] addOperationWithBlock: measureDoneBlock];
    };
    [_measureQueue cancelAllOperations];
    [_measureQueue addOperationWithBlock: measureBlock];
}

-(void)updateRows
{
    [self measureRows];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    BOOL expandedRows = [object boolForKey: kExpandedRows];
    if (expandedRows != _expandedRows) {
        _expandedRows = expandedRows;
        if (_expandedRows) {
            [self measureRows];
        } else {
            _lineHeights = nil;
            [self allLineHeightsChanged];
        }
    }
}

-(void)awakeFromNib
{
    _measureQueue = [[NSOperationQueue alloc] init];
    _measureQueue.maxConcurrentOperationCount = 1;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    _expandedRows = [defaults boolForKey: kExpandedRows];
    [defaults addObserver: self forKeyPath: kExpandedRows options: 0 context: 0];
    [_targetController.defaultFetchRequest setReturnsObjectsAsFaults: NO];
    if ([self updateAbiltyWidth]) {
        [self measureRows];
    }
}

- (void)tableViewColumnDidResize:(NSNotification *)aNotification
{
    if (_expandedRows) {
        NSDictionary* info = [aNotification userInfo];
        NSTableColumn* col = [info valueForKey: @"NSTableColumn"];
        NSString* identifier = [col identifier];
        if ([identifier isEqualToString: @"ability"]) {
            _abilityWidth = 0;
            [self updateAbiltyWidth];
            [self measureRows];
        }
    }
}

-(BOOL)updateAbiltyWidth
{
    if (_abilityWidth == 0) {
        NSInteger columnIndex = [_targetTable columnWithIdentifier: @"ability"];
        if (columnIndex != -1) {
            NSArray* allColumns = [_targetTable tableColumns];
            NSTableColumn* col = allColumns[columnIndex];
            _abilityWidth = col.width;
            return YES;
        }
    }
    return NO;
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row
{
    if (_expandedRows) {
        if ([self updateAbiltyWidth]) {
            [self measureRows];
        }
    }
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    if (_expandedRows) {
        if(_lineHeights) {
            id target = _targetController.arrangedObjects[row];
            NSNumber* height = _lineHeights[[target objectID]];
            if (height != nil) {
                return [height floatValue];
            }
        }
        return tableView.rowHeight;
    }
    return tableView.rowHeight;
}

@end
