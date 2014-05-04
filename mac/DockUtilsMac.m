#import "DockUtilsMac.h"

NSAttributedString* makeCentered(NSAttributedString* s)
{
    NSMutableAttributedString* as = [[NSMutableAttributedString alloc] initWithAttributedString: s];
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
    ps.alignment = NSCenterTextAlignment;
    NSRange r = NSMakeRange(0, s.length);
    [as addAttribute: NSParagraphStyleAttributeName value: ps range: r];
    return [[NSAttributedString alloc] initWithAttributedString: as];
}

NSAttributedString* makeRightAligned(NSAttributedString* s)
{
    NSMutableAttributedString* as = [[NSMutableAttributedString alloc] initWithAttributedString: s];
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
    ps.alignment = NSRightTextAlignment;
    NSRange r = NSMakeRange(0, s.length);
    [as addAttribute: NSParagraphStyleAttributeName value: ps range: r];
    return [[NSAttributedString alloc] initWithAttributedString: as];
}

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

