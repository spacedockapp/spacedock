#import <UIKit/UIKit.h>

@interface DockSetTableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel* title;
@property (nonatomic, strong) IBOutlet UILabel* setName;
@property (nonatomic, strong) IBOutlet UISwitch* includeSwitch;
@end
