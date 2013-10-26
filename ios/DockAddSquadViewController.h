#import <UIKit/UIKit.h>

@protocol DockAddSquadViewControllerDelegate;
@class DockSquad;

@interface DockAddSquadViewController : UITableViewController
@property (nonatomic, weak) id <DockAddSquadViewControllerDelegate> delegate;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) DockSquad* squad;
@end

@protocol DockAddSquadViewControllerDelegate
- (void)addSquadViewController:(DockAddSquadViewController *)controller didFinishWithSave:(BOOL)save;
@end
