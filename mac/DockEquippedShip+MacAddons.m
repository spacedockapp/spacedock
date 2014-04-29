#import "DockEquippedShip+MacAddons.h"

#import "DockEquippedShip+Addons.h"
#import "DockResource+Addons.h"
#import "DockShip+MacAddons.h"
#import "DockSquad+Addons.h"
#import "DockUtilsMac.h"

@implementation DockEquippedShip (MacAddons)

-(NSAttributedString*)styledDescription
{
    if ([self isResourceSideboard]) {
        return [[NSAttributedString alloc] initWithString: self.squad.resource.title];
    }

    return [self.ship styledDescription];
}

-(NSAttributedString*)formattedCost
{
    NSString* costString = [NSString stringWithFormat: @"%d", self.cost];
    return coloredString(costString, [NSColor textColor], [NSColor clearColor]);
}


@end
