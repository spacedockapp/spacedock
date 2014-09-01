#import "DockShipClassContainsRestriction.h"

#import "DockEquippedShip+Addons.h"
#import "DockExplanation.h"
#import "DockShip+Addons.h"

@interface DockShipClassContainsRestriction () <DockRestrictionTag>
@property (strong,nonatomic) NSString* explanationFragment;
@end

@implementation DockShipClassContainsRestriction

-(id)initWithShipClassSubstrings:(NSArray*)shipClassSubstrings explanationFragment:(NSString*)explanationFragment
{
    self = [super initWithShipClassSubstrings: shipClassSubstrings];
    if (self != nil) {
        self.explanationFragment = explanationFragment;
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
    if ([self matchesShip: equippedShip]) {
        return [DockExplanation success];
    }
    
    NSString* result = [self standardFailureResult: upgrade toShip: equippedShip];
    NSString* explanation = [self standardFailureExplanation: _explanationFragment];
    
    return [[DockExplanation alloc] initWithResult: result explanation: explanation];
}
@end
