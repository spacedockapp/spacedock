#import "DockShipClassContainsTagHandler.h"

#import "DockEquippedShip+Addons.h"
#import "DockShip+Addons.h"

@implementation DockShipClassContainsTagHandler

-(id)initWithShipClassSubstrings:(NSArray*)shipClassSubstrings
{
    self = [super init];
    if (self != nil) {
        self.shipClassSubstrings = [NSSet setWithArray: shipClassSubstrings];
    }
    return self;
}

-(BOOL)matchesShip:(DockEquippedShip*)equippedShip
{
    DockShip* ship = equippedShip.ship;
    NSString* shipClass = ship.shipClass;
    
    for (NSString* substring in _shipClassSubstrings) {
        NSRange r = [shipClass rangeOfString: substring options: NSCaseInsensitiveSearch];
        if (r.location != NSNotFound) {
            return YES;
        }
    }
    return NO;
}

@end
