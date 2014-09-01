#import "DockShipClassTagHandler.h"

#import "DockEquippedShip+Addons.h"
#import "DockExplanation.h"
#import "DockShip+Addons.h"

@interface DockShipClassTagHandler ()
@end

@implementation DockShipClassTagHandler

-(id)initWithShipClassSet:(NSSet*)shipClassSet
{
    self = [super init];
    if (self != nil) {
        self.targetShipClassSet = shipClassSet;
    }
    return self;
}

-(id)initWithShipClass:(NSString*)shipClass
{
    return [self initWithShipClassSet: [NSSet setWithObject: shipClass]];
}

-(id)initWithShipClasses:(NSArray*)shipClasses
{
    return [self initWithShipClassSet: [NSSet setWithArray: shipClasses]];
}

#pragma mark - Tag attributes

-(BOOL)refersToShipOrShipClass
{
    return YES;
}

-(BOOL)restriction
{
    return YES;
}

-(BOOL)matchesShip:(DockEquippedShip*)equippedShip
{
    DockShip* ship = equippedShip.ship;
    return [_targetShipClassSet containsObject: ship.shipClass];
}


@end
