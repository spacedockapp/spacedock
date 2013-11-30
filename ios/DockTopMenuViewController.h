#import <UIKit/UIKit.h>

@class DockSquad;

@interface DockTopMenuViewController : UITableViewController
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) DockSquad* targetSquad;
-(void)showSquad:(DockSquad*)squad;
@end
