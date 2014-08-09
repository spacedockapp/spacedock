#import "DockAdmiralRowHandler.h"

#import "DockAdmiral+Addons.h"
#import "DockConstants.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockExtrasTableViewCell.h"

@implementation DockAdmiralRowHandler

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row
{
    DockEquippedUpgrade* efc = _equippedShip.equippedAdmiral;

    NSString* upType = kAdmiralUpgradeType;

    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"upgrade" forIndexPath: indexPath];

    if (efc != nil) {
        DockAdmiral* adm = (DockAdmiral*)efc.upgrade;
        cell.textLabel.text = adm.title;
        cell.detailTextLabel.text = [[adm cost] stringValue];
        cell.textLabel.textColor = [UIColor blackColor];
    } else {
        cell.textLabel.text = upType;
        cell.textLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.text = @"";
    }

    return cell;
}

-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row;
{
    [_equippedShip removeUpgrade: [_equippedShip equippedAdmiral]];
}

-(void)tableView:(UITableView*)tableView didHighlightRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row;
{
    [self.controller performSegueWithIdentifier: @"PickAdmiral" sender: nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath row:(NSInteger)row
{
    DockEquippedUpgrade* efc = _equippedShip.equippedAdmiral;
    if (efc != nil) {
        return EXTRA_ROW_HEIGHT;
    }
    return tableView.rowHeight;
}

@end
