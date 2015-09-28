#import "DockShipRowHandler.h"

#import "DockEquippedShip+Addons.h"

@implementation DockShipRowHandler

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row
{
    UITableViewCell* shipCell = [tableView dequeueReusableCellWithIdentifier: @"upgrade" forIndexPath: indexPath];
    shipCell.textLabel.text = _equippedShip.plainDescription;
    NSString* costString = [NSString stringWithFormat: @"%d (%d)", [_equippedShip cost], [_equippedShip baseCost]];
    NSMutableAttributedString* costAttribString = [[NSMutableAttributedString alloc] initWithString:costString];
    [costAttribString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,costString.length)];
    if (_mark50spShip && [_equippedShip cost] > 50) {
        [costAttribString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, [NSString stringWithFormat:@"%d",[_equippedShip cost]].length)];
    }
    shipCell.detailTextLabel.attributedText = costAttribString;
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
