#import <AppKit/AppKit.h>

@interface DockAbilityDelegate : NSObject <NSTableViewDelegate>
@property (strong) IBOutlet NSArrayController* targetController;
@property (strong) IBOutlet NSTableView* targetTable;
@property (assign) BOOL expandedRows;
-(void)updateRows;
@end
