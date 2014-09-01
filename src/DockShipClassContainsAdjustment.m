#import "DockShipClassContainsAdjustment.h"

@interface DockShipClassContainsAdjustment () <DockCostAdjustingTag>
@property (assign, nonatomic) int adjustment;
@end

@implementation DockShipClassContainsAdjustment

-(id)initWithShipClassSubstrings:(NSArray*)shipClassSubstrings adjustment:(int)adjustment
{
    self = [super initWithShipClassSubstrings: shipClassSubstrings];
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
