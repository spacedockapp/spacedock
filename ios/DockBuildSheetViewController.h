#import <UIKit/UIKit.h>

@class DockSquad;

@interface DockBuildSheetViewController : UITableViewController <UITextFieldDelegate,UIDocumentInteractionControllerDelegate,UIActionSheetDelegate>
@property (strong, nonatomic) DockSquad* squad;
@end
