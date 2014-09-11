#import "DockFleetCaptain+MacAddons.h"

#import "DockCaptain+MacAddons.h"
#import "DockFleetCaptain+Addons.h"
#import "DockUtilsMac.h"

@implementation DockFleetCaptain (MacAddons)

+(NSSet*)keyPathsForValuesAffectingStyledSkillModifier
{
    return [NSSet setWithObjects: @"captainSkillBonus", nil];
}

-(NSAttributedString*)styledSkillModifier
{
    NSColor* c = [DockCaptain captainSkillColor];
    NSString* s = [NSString stringWithFormat: @"+%@", [self captainSkillBonus]];
    return makeCentered(coloredString(s, c, [NSColor clearColor]));
}
@end
