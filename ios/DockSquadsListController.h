#import <UIKit/UIKit.h>

@interface DockSquadsListController : UITableViewController<NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end
