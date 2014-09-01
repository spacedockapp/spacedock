#import "DockShipClassRequirementHandler.h"

#import "DockEquippedShip+Addons.h"
#import "DockExplanation.h"
#import "DockShip+Addons.h"

@interface DockShipClassRequirementHandler () <DockRestrictionTag>
@end

@implementation DockShipClassRequirementHandler

#pragma mark - Restriction

-(DockExplanation*)canAdd:(DockUpgrade*)upgrade toShip:(DockEquippedShip*)equippedShip
{
    if ([self matchesShip: equippedShip]) {
        return [DockExplanation success];
    }
    NSString* result = [self standardFailureResult: upgrade toShip: equippedShip];
    NSString* shipClassString = @"";
    if (self.targetShipClassSet.count > 2) {
        NSMutableArray* shipClasses = [NSMutableArray arrayWithArray: [self.targetShipClassSet allObjects]];
        NSArray* allButLast = [shipClasses subarrayWithRange: NSMakeRange(0, shipClasses.count - 1)];
        NSString* firstClassesString = [allButLast componentsJoinedByString: @", "];
        shipClassString = [@[firstClassesString, shipClasses.lastObject] componentsJoinedByString: @" or "];
    } else if (self.targetShipClassSet.count == 2) {
        shipClassString = [[self.targetShipClassSet allObjects] componentsJoinedByString: @" or "];
    } else {
        shipClassString = self.targetShipClassSet.anyObject;
    }
    NSString* explanationFragment = [NSString stringWithFormat: @"ships of class %@", shipClassString];
    NSString* explanation = [self standardFailureExplanation: explanationFragment];
    
    return [[DockExplanation alloc] initWithResult: result explanation: explanation];
}

@end
