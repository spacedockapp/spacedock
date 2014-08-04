#import "DockFlagship+MacAddons.h"

#import "DockEquippedShip+Addons.h"
#import "DockEquippedShip+MacAddons.h"
#import "DockFlagship+Addons.h"
#import "DockShip+MacAddons.h"
#import "DockUtils.h"
#import "DockUtilsMac.h"

@implementation DockFlagship (MacAddons)

-(NSAttributedString*)styledAttack
{
    return styledAttack([[self attack] stringValue]);
}

-(NSAttributedString*)styledAgility
{
    return styledAgility([[self agility] stringValue]);
}

-(NSAttributedString*)styledHull
{
    return styledHull([[self hull] stringValue]);
}

-(NSAttributedString*)styledShield
{
    return styledShield([[self shield] stringValue]);
}

-(NSAttributedString*)titleWithCanInstall
{
    NSString* dt = [self title];
    DockEquippedShip* targetShip = [DockEquippedShip currentTargetShip];
    if (targetShip != nil) {
        if (![self compatibleWithShip: targetShip.ship]) {
            return coloredString(dt, [NSColor grayColor], [NSColor clearColor]);
        }
    }
    return [[NSAttributedString alloc] initWithString: dt];
}

@end
