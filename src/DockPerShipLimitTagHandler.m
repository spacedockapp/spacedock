#import "DockPerShipLimitTagHandler.h"

#import "DockEquippedShip+Addons.h"
#import "DockExplanation.h"
#import "DockShip+Addons.h"
#import "DockUpgrade+Addons.h"

@interface DockPerShipLimitTagHandler ()
@property (assign, nonatomic) int limit;
@end

@implementation DockPerShipLimitTagHandler

-(id)initWithLimit:(int)limit
{
    self = [super init];
    if (self != nil) {
        _limit = limit;
    }
    return self;
}

#pragma mark - Tag attributes

-(BOOL)restriction
{
    return YES;
}

#pragma mark - Restriction

-(DockExplanation*)canAdd:(DockUpgrade*)upgrade toShip:(DockEquippedShip*)equippedShip
{
    NSArray* equipped = [equippedShip allUpgradesWithId: upgrade.externalId];
    
    if (equipped.count < _limit) {
        return [DockExplanation success];
    }
    
    NSString* result = [self standardFailureResult: upgrade toShip: equippedShip];
    NSString* explanationFragment = @"";
    if (_limit == 1) {
        explanationFragment = [NSString stringWithFormat: @"a ship has none already equipped"];
    } else {
        explanationFragment = [NSString stringWithFormat: @"a ship with fewer than %d already equipped", _limit];
    }
    NSString* explanation = [self standardFailureExplanation: explanationFragment];
    
    return [[DockExplanation alloc] initWithResult: result explanation: explanation];
}

@end
