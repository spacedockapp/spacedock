#import "DockRowHandler.h"

@implementation DockRowHandler

-(BOOL)shouldPerformSegueWithIdentifier:(NSString*)identifier sender:(id)sender
{
    return NO;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row
{
    return nil;
}

-(BOOL)tableView:(UITableView*)tableView shouldHighlightRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row;
{
    return YES;
}

-(void)tableView:(UITableView*)tableView didHighlightRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row
{
}

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row;
{
    return YES;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath row:(NSInteger)row
{
    return tableView.rowHeight;
}

-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row;
{
}
@end
