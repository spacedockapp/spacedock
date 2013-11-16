#import <UIKit/UIKit.h>

@class DockSquad;

@interface DockSquadsListController : UITableViewController<NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
-(void)selectSquad:(DockSquad*)squad;
@end
