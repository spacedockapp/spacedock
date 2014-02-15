#import <UIKit/UIKit.h>

@interface DockEditNotesCell : UITableViewCell
@property (assign, nonatomic) IBOutlet UILabel* labelField;
@property (assign, nonatomic) IBOutlet UITextView* notesView;
@end

@interface DockNotesCell : UITableViewCell
@property (assign, nonatomic) IBOutlet UILabel* labelField;
@property (assign, nonatomic) IBOutlet UILabel* notesLabel;
@end
