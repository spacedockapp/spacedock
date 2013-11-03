#import <UIKit/UIKit.h>

@class DockUpgrade;

@interface DockUpgradeDetailViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextView* abilityField;
@property (weak, nonatomic) DockUpgrade* upgrade;
@end
