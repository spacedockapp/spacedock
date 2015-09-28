#import "DockRowHandler.h"

@class DockEquippedShip;

@interface DockShipRowHandler : DockRowHandler
@property (strong, nonatomic) DockEquippedShip* equippedShip;
@property (nonatomic, assign) BOOL mark50spShip;
@end
