#import "DockEquippedUpgrade+MacAddons.h"

#import "DockUpgrade+MacAddons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockUtilsMac.h"

@implementation DockEquippedUpgrade (MacAddons)

-(NSAttributedString*)formattedCost
{
    NSString* costString = [NSString stringWithFormat: @"%d", self.cost];

    if ([self costIsOverridden]) {
        return coloredString(costString, [NSColor redColor], [NSColor clearColor]);
    }
    
    return coloredString(costString, [NSColor blackColor], [NSColor clearColor]);
}

-(NSAttributedString*)styledDescription
{
    return self.upgrade.styledDescription;
}

@end
