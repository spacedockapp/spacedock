#import "DockFlagship+MacAddons.h"

#import "DockShip+MacAddons.h"
#import "DockUtils.h"

@implementation DockFlagship (MacAddons)

-(NSAttributedString*)styledAttack
{
    return styledAttack(self);
}

-(NSAttributedString*)styledAgility
{
    return styledAgility(self);
}

-(NSAttributedString*)styledHull
{
    return styledHull(self);
}

-(NSAttributedString*)styledShield
{
    return styledShield(self);
}

@end
