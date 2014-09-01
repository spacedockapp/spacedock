#import "DockShipFactionTagHandler.h"

#import "DockComponent+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockExplanation.h"
#import "DockShip+Addons.h"

@interface DockShipFactionTagHandler () <DockRestrictionTag>
@property (strong,nonatomic) NSString* faction;
@end

@implementation DockShipFactionTagHandler

-(id)initWithFaction:(NSString*)faction
{
    self = [super init];
    if (self != nil) {
        self.faction = faction;
    }
    return self;
}

#pragma mark - Tag attributes

-(BOOL)restrictsByFaction
{
    return YES;
}

#pragma mark - Restriction

-(DockExplanation*)canAdd:(DockUpgrade*)upgrade toShip:(DockEquippedShip*)equippedShip
{
    DockShip* ship = equippedShip.ship;
    
    if ([ship hasFaction : self.faction]) {
        return [DockExplanation success];
    }
    
    NSString* result = [self standardFailureResult: upgrade toShip: equippedShip];
    NSString* explanationFragment = [NSString stringWithFormat: @"a %@ ship", self.faction];
    NSString* explanation = [self standardFailureExplanation: explanationFragment];
    
    return [[DockExplanation alloc] initWithResult: result explanation: explanation];
}

@end
