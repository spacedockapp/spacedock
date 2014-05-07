#import "DockFlagship+MacAddons.h"

#import "DockShip+MacAddons.h"
#import "DockUtils.h"

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

@end
