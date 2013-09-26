#import "DockEquippedShip+Addons.h"

#import "DockShip.h"

@implementation DockEquippedShip (Addons)

-(NSString*)title
{
    return self.ship.title;
}

@end
