#import "DockTableViewController.h"

@interface DockSetsListViewController : DockTableViewController
@property (nonatomic, strong) IBOutlet UIBarButtonItem* selectAll;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* selectNone;
-(IBAction)selectAll:(id)sender;
-(IBAction)selectNone:(id)sender;
@end
