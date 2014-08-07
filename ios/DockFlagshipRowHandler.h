#import "DockRowHandler.h"

@class DockEquippedShip;
@class DockFlagship;

@interface DockFlagshipRowHandler : DockRowHandler
@property (strong, nonatomic) DockEquippedShip* equippedShip;
@end
