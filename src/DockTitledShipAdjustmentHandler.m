#import "DockTitledShipAdjustmentHandler.h"

@interface DockTitledShipAdjustmentHandler () <DockCostAdjustingTag>
@property (assign, nonatomic) int adjustment;
@end

@implementation DockTitledShipAdjustmentHandler

-(id)initWithShipTitle:(NSString*)shipTitle adjustment:(int)adjustment
{
    self = [super initWithShipTitle: shipTitle];
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
