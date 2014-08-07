#import <Foundation/Foundation.h>

#define EXTRA_ROW_HEIGHT 38

@interface DockRowHandler : NSObject
@property (strong, nonatomic) id target;
@property (strong, nonatomic) UITableViewController* controller;
-(BOOL)shouldPerformSegueWithIdentifier:(NSString*)identifier sender:(id)sender;
-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row;
-(BOOL)tableView:(UITableView*)tableView shouldHighlightRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row;
-(void)tableView:(UITableView*)tableView didHighlightRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row;
-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row;
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath row:(NSInteger)row;
-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath row:(NSInteger)row;
@end
