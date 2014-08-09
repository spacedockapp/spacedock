#import "DockSectionHandler.h"

#import "DockRowHandler.h"

@interface DockSectionHandler ()
@property (strong, nonatomic) NSMutableArray* rowHandlers;
@end

@implementation DockSectionHandler

-(id)init
{
    self = [super init];
    if (self != nil) {
        _rowHandlers = [NSMutableArray arrayWithCapacity: 0];
    }
    return self;
}

-(NSInteger)rowHandlerCount
{
    return _rowHandlers.count;
}

-(void)addRowHandler:(DockRowHandler*)rowHandler
{
    [_rowHandlers addObject: rowHandler];
}

-(DockRowHandler*)rowHandlerForRow:(NSInteger)row
{
    assert(row >= 0 && row < _rowHandlers.count);
    return _rowHandlers[row];
}

-(NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    return _title;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return _rowHandlers.count;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger row = [indexPath indexAtPosition: 1];
    if (row < 0 || row > _rowHandlers.count) {
        return nil;
    }

    DockRowHandler* handler = _rowHandlers[row];
    return [handler tableView: tableView cellForRowAtIndexPath: indexPath row: row];
}

-(BOOL)tableView:(UITableView*)tableView shouldHighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger row = [indexPath indexAtPosition: 1];
    if (row < 0 || row > _rowHandlers.count) {
        return NO;
    }

    DockRowHandler* handler = _rowHandlers[row];
    return [handler tableView: tableView shouldHighlightRowAtIndexPath: indexPath row: row];
}

-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath indexAtPosition: 1];
    if (row < 0 || row > _rowHandlers.count) {
        return;
    }

    DockRowHandler* handler = _rowHandlers[row];
    [handler tableView: tableView didHighlightRowAtIndexPath: indexPath row: row];
}

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger row = [indexPath indexAtPosition: 1];
    if (row < 0 || row > _rowHandlers.count) {
        return NO;
    }

    DockRowHandler* handler = _rowHandlers[row];
    return [handler tableView: tableView canEditRowAtIndexPath: indexPath row: row];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath indexAtPosition: 1];
    if (row < 0 || row > _rowHandlers.count) {
        return tableView.rowHeight;
    }

    DockRowHandler* handler = _rowHandlers[row];
    return [handler tableView: tableView heightForRowAtIndexPath: indexPath row: row];
}

-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger row = [indexPath indexAtPosition: 1];
    if (row < 0 || row > _rowHandlers.count) {
        return;
    }

    DockRowHandler* handler = _rowHandlers[row];
    return [handler tableView: tableView commitEditingStyle: editingStyle forRowAtIndexPath: indexPath row: row];
}


@end
