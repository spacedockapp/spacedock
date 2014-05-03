#import "DockUpgrade+MacAddons.h"

#import "DockUpgrade+Addons.h"

@implementation DockUpgrade (MacAddons)

-(NSAttributedString*)formattedAttack
{
    return nil;
}

-(int)attackValue
{
    return 0;
}

-(NSAttributedString*)styledDescription
{
    NSString* s = [self plainDescription];

    if ([self isPlaceholder]) {
        NSMutableAttributedString* as = [[NSMutableAttributedString alloc] initWithString: s];
        NSRange r = NSMakeRange(0, s.length);
        [as applyFontTraits: NSItalicFontMask range: r];
        return as;
    }

    return [[NSAttributedString alloc] initWithString: s];
}

-(NSString*)shipRange
{
    return @"";
}

@end
