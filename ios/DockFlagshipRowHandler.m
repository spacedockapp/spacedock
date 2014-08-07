#import "DockFlagshipRowHandler.h"

#import "DockEquippedShip+Addons.h"
#import "DockFlagship+Addons.h"
#import "DockExtrasTableViewCell.h"

@implementation DockFlagshipRowHandler

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row
{
    DockFlagship* fs = _equippedShip.flagship;

    static NSString* flagshipType = @"Flagship";

    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"upgrade" forIndexPath: indexPath];

    if (fs != nil) {
        cell.textLabel.text = fs.title;
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.text = [[fs cost] stringValue];
    } else {
        cell.textLabel.text = flagshipType;
        cell.textLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.text = @"";
    }

    return cell;
}

-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row;
{
    _equippedShip.flagship = nil;
}

-(BOOL)tableView:(UITableView*)tableView shouldHighlightRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row;
{
    return YES;
}

-(void)tableView:(UITableView*)tableView didHighlightRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row;
{
    [self.controller performSegueWithIdentifier: @"PickFlagship" sender: nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath row:(NSInteger)row
{
    DockFlagship* fs = _equippedShip.flagship;
    if (fs != nil) {
        return EXTRA_ROW_HEIGHT;
    }
    return tableView.rowHeight;
}

@end
