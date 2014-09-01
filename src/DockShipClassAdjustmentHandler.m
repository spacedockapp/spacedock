#import "DockShipClassAdjustmentHandler.h"

@interface DockShipClassAdjustmentHandler () <DockCostAdjustingTag>
@property (assign, nonatomic) int adjustment;
@end

@implementation DockShipClassAdjustmentHandler

-(id)initWithShipClass:(NSString*)shipClass adjustment:(int)adjustment
{
    return [self initWithShipClassSet: [NSSet setWithObject: shipClass] adjustment: adjustment];
}

-(id)initWithShipClasses:(NSArray*)shipClasses adjustment:(int)adjustment
{
    return [self initWithShipClassSet: [NSSet setWithArray: shipClasses] adjustment: adjustment];
}

-(id)initWithShipClassSet:(NSSet*)shipClassSet adjustment:(int)adjustment
{
    self = [super initWithShipClassSet: shipClassSet];
    if (self != nil) {
        _adjustment = adjustment;
    }
    return self;
}

-(int)costAdjustment:(DockUpgrade*)upgrade onShip:(DockEquippedShip*)ship
{
    if (![self matchesShip: ship]) {
        return _adjustment;
    }
    return 0;
}

@end
