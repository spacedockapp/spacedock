#import "DockUtils.h"

NSAttributedString* coloredString(NSString* text, NSColor* color, NSColor* backColor)
{
    id attr = @{
        NSForegroundColorAttributeName: color,
        NSBackgroundColorAttributeName : backColor,
        NSExpansionAttributeName: @0.4
    };
    return [[NSAttributedString alloc] initWithString: text attributes: attr];
}

