#import "DockTitledShipTagHandler.h"

#import "DockEquippedShip+Addons.h"
#import "DockShip+Addons.h"

@implementation DockTitledShipTagHandler

-(id)initWithShipTitle:(NSString*)shipTitle
{
    self = [super init];
    if (self != nil) {
        self.shipTitle = shipTitle;
    }
    return self;
}

-(BOOL)matchesShip:(DockEquippedShip*)equippedShip
{
    DockShip* ship = equippedShip.ship;
    
    return [ship.title isEqualToString: self.shipTitle];
}

-(BOOL)refersToShipOrShipClass
{
    return YES;
}

@end
