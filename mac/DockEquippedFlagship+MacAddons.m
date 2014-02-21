#import "DockEquippedFlagship+MacAddons.h"

#import "DockUtils.h"

@implementation DockEquippedFlagship (MacAddons)

-(NSAttributedString*)formattedCost
{
    return coloredString(@"0", [NSColor blackColor], [NSColor clearColor]);
}


@end
