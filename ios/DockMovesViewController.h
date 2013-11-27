#import <UIKit/UIKit.h>

@class DockMoveGridView;
@class DockShip;

@interface DockMovesViewController : UIViewController
@property (strong, nonatomic) IBOutlet DockMoveGridView* moveGrid;
@property (strong, nonatomic) DockShip* ship;
@end
