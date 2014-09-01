#import "DockTagHandler.h"

@interface DockShipClassTagHandler : DockTagHandler
@property (strong,nonatomic) NSSet* targetShipClassSet;
-(id)initWithShipClass:(NSString*)shipClass;
-(id)initWithShipClasses:(NSArray*)shipClasses;
-(id)initWithShipClassSet:(NSSet*)shipClassSet;
-(BOOL)matchesShip:(DockEquippedShip*)equippedShip;
@end
