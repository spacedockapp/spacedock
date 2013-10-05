#import "DockUtils.h"

NSAttributedString* coloredString(NSString* text, NSColor* color, NSColor* backColor)
{
    id attr = @{
        NSForegroundColorAttributeName: color,
        NSBackgroundColorAttributeName : backColor,
        NSExpansionAttributeName: @0.0
    };
    NSString* t = [NSString stringWithFormat: @" %@ ", text];
    return [[NSAttributedString alloc] initWithString: t attributes: attr];
}

