#import <UIKit/UIKit.h>

@class DockSquad;

@interface DockSquadsListController : UITableViewController<NSFetchedResultsControllerDelegate,UIDocumentInteractionControllerDelegate,UIActionSheetDelegate>
@property (nonatomic, strong) IBOutlet UIBarButtonItem* shareItem;
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) DockSquad* targetSquad;
-(void)selectSquad:(DockSquad*)squad;
@end
