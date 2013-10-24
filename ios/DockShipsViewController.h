#import <UIKit/UIKit.h>

@interface DockShipsViewController : UITableViewController<NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end
