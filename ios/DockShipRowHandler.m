#import "DockShipRowHandler.h"

#import "DockEquippedShip+Addons.h"

@implementation DockShipRowHandler
-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row
{
    UITableViewCell* shipCell = [tableView dequeueReusableCellWithIdentifier: @"upgrade" forIndexPath: indexPath];
    shipCell.textLabel.text = _equippedShip.plainDescription;
    shipCell.detailTextLabel.text = [NSString stringWithFormat: @"%d (%d)", [_equippedShip cost], [_equippedShip baseCost]];
    return shipCell;
}

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row;
{
    return NO;
}

-(void)tableView:(UITableView*)tableView didHighlightRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row;
{
    [self.controller performSegueWithIdentifier: @"PickShip" sender: nil];
}

-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row;
{
}
@end
