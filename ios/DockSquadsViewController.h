#import "DockAddSquadViewController.h"

@interface DockSquadsViewController : UITableViewController<DockAddSquadViewControllerDelegate,NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end
