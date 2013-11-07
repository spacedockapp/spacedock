#import <UIKit/UIKit.h>

@class DockUpgrade;

@interface DockUpgradeDetailViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel* abilityField;
@property (strong, nonatomic) IBOutlet UILabel* titleField;
@property (strong, nonatomic) IBOutlet UILabel* upTypeField;
@property (strong, nonatomic) IBOutlet UILabel* costField;
@property (strong, nonatomic) IBOutlet UILabel* attackField;
@property (strong, nonatomic) IBOutlet UILabel* rangeField;
@property (strong, nonatomic) IBOutlet UILabel* captainSkill;
@property (weak, nonatomic) DockUpgrade* upgrade;
@end
