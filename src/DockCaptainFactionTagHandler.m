#import "DockCaptainFactionTagHandler.h"

#import "DockComponent+Addons.h"
#import "DockExplanation.h"
#import "DockEquippedShip+Addons.h"
#import "DockCaptain+Addons.h"

@interface DockCaptainFactionTagHandler ()
@property (strong,nonatomic) NSString* faction;
@end

@implementation DockCaptainFactionTagHandler

-(id)initWithFaction:(NSString*)faction
{
    self = [super init];
    if (self != nil) {
        self.faction = faction;
    }
    return self;
}

#pragma mark - Restriction

-(DockExplanation*)canAdd:(DockUpgrade*)upgrade toShip:(DockEquippedShip*)equippedShip
{
    DockCaptain* captain = equippedShip.captain;
    
    if ([captain hasFaction : self.faction]) {
        return [DockExplanation success];
    }
    
    NSString* result = [self standardFailureResult: upgrade toShip: equippedShip];
    NSString* explanationFragment = [NSString stringWithFormat: @"a %@ captain", self.faction];
    NSString* explanation = [self standardFailureExplanation: explanationFragment];
    
    return [[DockExplanation alloc] initWithResult: result explanation: explanation];
}

#pragma mark - Tag attributes

-(BOOL)refersToShipOrShipClass
{
    return YES;
}

-(BOOL)restrictsByFaction
{
    return YES;
}

@end
