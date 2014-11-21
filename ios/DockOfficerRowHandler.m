#import "DockOfficerRowHandler.h"

#import "DockConstants.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockOfficer+Addons.h"
#import "DockUpgrade+Addons.h"

@implementation DockOfficerRowHandler

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row
{
    NSString* upType = kOfficerUpgradeType;

    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"upgrade" forIndexPath: indexPath];

    cell.textLabel.text = upType;
    cell.textLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.text = @" ";

    return cell;
}

-(void)tableView:(UITableView*)tableView didHighlightRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row;
{
    [self.controller performSegueWithIdentifier: @"PickOfficer" sender: nil];
}

@end
