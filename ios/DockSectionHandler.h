#import <Foundation/Foundation.h>

@class DockRowHandler;

@interface DockSectionHandler : NSObject
@property (strong, nonatomic) NSString* title;
@property (assign, readonly, nonatomic) NSInteger rowHandlerCount;
-(void)addRowHandler:(DockRowHandler*)rowHandler;
-(DockRowHandler*)rowHandlerForRow:(NSInteger)row;
-(NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section;
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section;
-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath;
-(BOOL)tableView:(UITableView*)tableView shouldHighlightRowAtIndexPath:(NSIndexPath*)indexPath;
-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath;
-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath;
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath;
@end
