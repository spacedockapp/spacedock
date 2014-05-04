#import "DockWeapon+MacAddons.h"

#import "DockUpgrade+Addons.h"
#import "DockUpgrade+MacAddons.h"
#import "DockUtilsMac.h"
#import "DockWeapon+Addons.h"

@implementation DockWeapon (MacAddons)

-(NSAttributedString*)formattedAttack
{
    int attackValue = [self attackValue];
    if (attackValue == 0) {
        return nil;
    }
    return makeCentered(coloredString(intToString([self.attack intValue]), [NSColor whiteColor], [NSColor redColor]));
}

-(NSAttributedString*)formattedRange
{
    NSString* range = [self range];

    if (range != nil && range.length > 0) {
        return makeCentered(coloredString(range, [NSColor whiteColor], [NSColor blackColor]));
    }
    return nil;
}

-(int)attackValue
{
    return [self.attack intValue];
}

-(NSAttributedString*)styledDescription
{
    if ([self isPlaceholder]) {
        return [super styledDescription];
    }

    NSMutableAttributedString* as = [[NSMutableAttributedString alloc] initWithAttributedString: [super styledDescription]];
    NSNumber* attack = [self attack];
    int attackValue = [attack intValue];

    if (attackValue != 0) {
        [as appendAttributedString: [[NSMutableAttributedString alloc] initWithString: @" "]];
        [as appendAttributedString: coloredString([attack stringValue], [NSColor redColor], [NSColor blackColor])];
    }

    NSString* range = [self range];

    if (range != nil && range.length > 0) {
        [as appendAttributedString: [[NSMutableAttributedString alloc] initWithString: @" "]];
        [as appendAttributedString: coloredString(range, [NSColor whiteColor], [NSColor blackColor])];
    }

    return as;
}


@end
