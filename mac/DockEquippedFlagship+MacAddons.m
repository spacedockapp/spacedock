#import "DockEquippedFlagship+MacAddons.h"

#import "DockUtilsMac.h"

@implementation DockEquippedFlagship (MacAddons)

-(NSAttributedString*)formattedCost
{
    return coloredString(@"10", [NSColor blackColor], [NSColor clearColor]);
}


@end
