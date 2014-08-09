#import "DockUpgradeRowHandler.h"

#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockUpgrade+Addons.h"

@implementation DockUpgradeRowHandler

-(id)target
{
    return _equippedUpgrade;
}

-(void)tableViewx:(UITableView*)tableView didHighlightRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row;
{
    [self.controller performSegueWithIdentifier: @"PickUpgrade" sender: nil];
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row
{
    static NSString* CellIdentifier = @"upgrade";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier forIndexPath: indexPath];
    DockUpgrade* upgrade = _equippedUpgrade.upgrade;
    cell.textLabel.text = [upgrade title];

    if ([upgrade isPlaceholder]) {
        cell.textLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.text = @"";
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
        int baseCost = [[upgrade cost] intValue];
        int equippedCost = [_equippedUpgrade cost];

        if (equippedCost == baseCost) {
            cell.detailTextLabel.text = [[upgrade cost] stringValue];
        } else {
            cell.detailTextLabel.text = [NSString stringWithFormat: @"%d (%@)", [_equippedUpgrade cost], [upgrade cost]];
        }
    }
    return cell;
}

-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row;
{
    [_equippedUpgrade.equippedShip removeUpgrade: _equippedUpgrade establishPlaceholders: YES];
}

-(void)tableView:(UITableView*)tableView didHighlightRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row;
{
    [self.controller performSegueWithIdentifier: @"PickUpgrade" sender: self.equippedUpgrade];
}

@end
