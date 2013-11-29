#import <UIKit/UIKit.h>

typedef void (^ DockOnSave)(NSString*);

@interface DockEditValueController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField* valueField;
@property (strong, nonatomic) DockOnSave onSave;
@property (strong, nonatomic) NSString* valueName;
@property (strong, nonatomic) NSString* initialValue;
@end
