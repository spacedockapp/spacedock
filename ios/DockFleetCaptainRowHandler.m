#import "DockFleetCaptainRowHandler.h"

#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockFleetCaptain+Addons.h"
#import "DockExtrasTableViewCell.h"

@implementation DockFleetCaptainRowHandler

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row
{
    DockEquippedUpgrade* efc = _equippedShip.equippedFleetCaptain;

    NSString* upType = @"Fleet Captain";

    UITableViewCell* flagshipSlotCell = [tableView dequeueReusableCellWithIdentifier: @"upgrade" forIndexPath: indexPath];

    if (efc != nil) {
        DockFleetCaptain* fc = (DockFleetCaptain*)efc.upgrade;
        flagshipSlotCell.textLabel.text = fc.title;
        flagshipSlotCell.textLabel.textColor = [UIColor blackColor];
        flagshipSlotCell.detailTextLabel.text = [[fc cost] stringValue];
    } else {
        flagshipSlotCell.textLabel.text = upType;
        flagshipSlotCell.textLabel.textColor = [UIColor grayColor];
        flagshipSlotCell.detailTextLabel.text = @" ";
    }
    return flagshipSlotCell;
}

-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row;
{
    [_equippedShip removeUpgrade: [_equippedShip equippedFleetCaptain]];
}

-(void)tableView:(UITableView*)tableView didHighlightRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row;
{
    [self.controller performSegueWithIdentifier: @"PickFleetCaptain" sender: nil];
}

@end
