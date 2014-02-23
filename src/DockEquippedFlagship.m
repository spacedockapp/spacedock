#import "DockEquippedFlagship.h"

#import "DockFlagship+Addons.h"
#import "DockFlagship+MacAddons.h"
#import "DockUtils.h"

@class DockUpgade;

@implementation DockEquippedFlagship

+(DockEquippedFlagship*)equippedFlagship:(DockFlagship*)flagship forShip:(DockEquippedShip*)ship
{
    DockEquippedFlagship* efs = [[DockEquippedFlagship alloc] init];
    efs.flagship = flagship;
    efs.equippedShip = ship;
    return efs;
}

-(int)baseCost
{
    return 10;
}

-(NSArray*)sortedUpgrades
{
    return nil;
}

-(NSArray*)sortedUpgradesWithFlagship
{
    return nil;
}

-(NSArray*)upgrades
{
    return nil;
}

-(NSAttributedString*)styledDescription
{
    return [[NSAttributedString alloc] initWithString: [self.flagship plainDescription]];
}

-(NSComparisonResult)compareTo:(NSObject*)other
{
    return NSOrderedAscending;
}

-(BOOL)isPlaceholder
{
    return NO;
}

@end
