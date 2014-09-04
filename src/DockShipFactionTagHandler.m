#import "DockShipFactionTagHandler.h"

#import "DockComponent+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockExplanation.h"
#import "DockShip+Addons.h"

@interface DockShipFactionTagHandler () <DockRestrictionTag>
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

-(BOOL)matchesShip:(DockEquippedShip*)equippedShip
{
    return [equippedShip.ship hasFaction : self.faction];
}

@end
