#import "DockShipFactionAdjustmentHandler.h"

@interface DockShipFactionAdjustmentHandler () <DockCostAdjustingTag>
@property (assign, nonatomic) int adjustment;
@end

@implementation DockShipFactionAdjustmentHandler

-(id)initWithFaction:(NSString*)faction adjustment:(int)adjustment
{
    self = [super initWithFaction: faction];
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
