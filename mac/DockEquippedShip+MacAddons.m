#import "DockEquippedShip+MacAddons.h"

#import "DockEquippedShip+Addons.h"
#import "DockResource+Addons.h"
#import "DockSquad+Addons.h"
#import "DockUtilsMac.h"

@implementation DockEquippedShip (MacAddons)

-(NSAttributedString*)styledDescription
{
    if ([self isResourceSideboard]) {
        return [[NSAttributedString alloc] initWithString: self.squad.resource.title];
    }

    NSMutableAttributedString* desc = [[NSMutableAttributedString alloc] initWithString: [self plainDescription]];
    NSAttributedString* space = [[NSAttributedString alloc] initWithString: @" "];
    [desc appendAttributedString: space];
    [desc appendAttributedString: coloredString(intToString(self.attack), [NSColor whiteColor], [NSColor redColor])];
    [desc appendAttributedString: space];
    [desc appendAttributedString: coloredString(intToString(self.agility), [NSColor blackColor], [NSColor greenColor])];
    [desc appendAttributedString: space];
    [desc appendAttributedString: coloredString(intToString(self.hull), [NSColor blackColor], [NSColor yellowColor])];
    [desc appendAttributedString: space];
    [desc appendAttributedString: coloredString(intToString(self.shield), [NSColor whiteColor], [NSColor blueColor])];
    return desc;
}

-(NSAttributedString*)formattedCost
{
    NSString* costString = [NSString stringWithFormat: @"%d", self.cost];
    return coloredString(costString, [NSColor textColor], [NSColor clearColor]);
}


@end
