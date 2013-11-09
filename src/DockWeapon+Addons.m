#import "DockWeapon+Addons.h"

#import "DockUpgrade+Addons.h"
#import "DockUtils.h"

@implementation DockWeapon (Addons)

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
#if TARGET_OS_IPHONE
#else
        [as appendAttributedString: coloredString([attack stringValue], [NSColor redColor], [NSColor blackColor])];
#endif
    }

    NSString* range = [self range];

    if (range != nil && range.length > 0) {
        [as appendAttributedString: [[NSMutableAttributedString alloc] initWithString: @" "]];
#if TARGET_OS_IPHONE
#else
        [as appendAttributedString: coloredString(range, [NSColor whiteColor], [NSColor blackColor])];
#endif
    }

    return as;
}

@end
