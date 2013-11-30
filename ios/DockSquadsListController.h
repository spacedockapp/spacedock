#import <UIKit/UIKit.h>

@class DockSquad;

@interface DockSquadsListController : UITableViewController<NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) DockSquad* targetSquad;
-(void)selectSquad:(DockSquad*)squad;
@end
