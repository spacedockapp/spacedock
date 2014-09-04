#import "DockTitledShipRequirementHandler.h"

#import "DockEquippedShip+Addons.h"
#import "DockExplanation.h"
#import "DockShip+Addons.h"

@interface DockTitledShipRequirementHandler () <DockRestrictionTag>
@end

@implementation DockTitledShipRequirementHandler

#pragma mark - Tag attributes

-(BOOL)restriction
{
    return YES;
}

#pragma mark - Restriction

-(DockExplanation*)canAdd:(DockUpgrade*)upgrade toShip:(DockEquippedShip*)equippedShip
{
    if ([self matchesShip: equippedShip]) {
        return [DockExplanation success];
    }
    
    NSString* result = [self standardFailureResult: upgrade toShip: equippedShip];
    NSString* explanationFragment = [NSString stringWithFormat: @"a ship titled %@", self.shipTitle];
    NSString* explanation = [self standardFailureExplanation: explanationFragment];
    
    return [[DockExplanation alloc] initWithResult: result explanation: explanation];
}

@end
