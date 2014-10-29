#import <UIKit/UIKit.h>

@class DockSquad;

@interface DockBuildSheetViewController : UITableViewController <UITextFieldDelegate>
@property (strong, nonatomic) DockSquad* squad;
@end
