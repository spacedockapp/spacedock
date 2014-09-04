#import "DockTagHandler.h"

@interface DockTitledShipTagHandler : DockTagHandler
@property (strong,nonatomic) NSString* shipTitle;
-(id)initWithShipTitle:(NSString*)shipTitle;
-(BOOL)matchesShip:(DockEquippedShip*)equippedShip;
@end
