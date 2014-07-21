#import "DockCaptain+MacAddons.h"

#import "DockCaptain+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockUpgrade+Addons.h"
#import "DockUpgrade+MacAddons.h"
#import "DockUtilsMac.h"

@implementation DockCaptain (MacAddons)

+(NSColor*)captainSkillColor
{
    const double kRed = 0xd0 / 256.0;
    const double kGreen = 0x9C / 256.0;
    const double kBlue = 0x23 / 256.0;
    NSColor* c = [NSColor colorWithDeviceRed: kRed green: kGreen blue: kBlue alpha: 1];
    return c;
}

-(NSAttributedString*)styledDescription
{
    NSMutableAttributedString* as = [[NSMutableAttributedString alloc] initWithAttributedString: [super styledDescription]];
    NSColor* c = [DockCaptain captainSkillColor];
    [as appendAttributedString: [[NSMutableAttributedString alloc] initWithString: @" "]];
    [as appendAttributedString: coloredString([[self skill] stringValue], c, [NSColor clearColor])];
    return as;
}

-(NSAttributedString*)styledSkill
{
    NSColor* c = [DockCaptain captainSkillColor];
    return makeCentered(coloredString([[self skill] stringValue], c, [NSColor clearColor]));
}

@end
