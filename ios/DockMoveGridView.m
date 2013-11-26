#import "DockMoveGridView.h"

@implementation DockMoveGridView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
    
    CGRect bounds = self.bounds;
    CGSize availableSize = bounds.size;
    CGFloat availableSpace = availableSize.height < availableSize.width ? availableSize.height : availableSize.width;
    CGFloat lineWidth = availableSpace / 100.0;
    CGFloat offsetX = (bounds.size.width - availableSpace)/2;
    CGFloat offsetY = (bounds.size.height - availableSpace)/2;
    
    CGRect blackBox = CGRectMake(0, 0, availableSpace, availableSpace);
    [[UIColor blackColor] set];
    UIBezierPath* blackBoxPath = [UIBezierPath bezierPathWithRect: blackBox];
    [blackBoxPath fill];
    [[UIColor whiteColor] set];
    CGFloat inset = lineWidth * 5;
    CGRect gridBox = CGRectInset(blackBox, inset, inset);
    UIBezierPath* gridBoxPath = [UIBezierPath bezierPathWithRect: gridBox];
    [gridBoxPath stroke];
#if 0
    CGFloat rowSize = gridBox.size.width / 7.0;
    CGFloat fontSize = rowSize;
    
    CGFloat x = gridBox.origin.x + rowSize - 1;
    for (int i = 0; i < 6; ++i) {
        CGRect lineRect = NSMakeRect(x, gridBox.origin.y, lineWidth, gridBox.size.height);
        UIBezierPath* line = [UIBezierPath bezierPathWithRect: lineRect];
        [line fill];
        x += rowSize;
    }
    
    CGFloat y = gridBox.origin.y + rowSize - 1;
    for (int i = 0; i < 6; ++i) {
        CGRect lineRect = NSMakeRect(gridBox.origin.x, y, gridBox.size.width, lineWidth);
        UIBezierPath* line = [UIBezierPath bezierPathWithRect: lineRect];
        [line fill];
        y += rowSize;
    }
    
    int moveValues[] = {5,4,3,2,1,-1,-2};
    y = gridBox.origin.y - 1;
    NSFont* font = [NSFont fontWithName: @"Helvetica" size: fontSize];
    NSDictionary* attr = @{
                           NSForegroundColorAttributeName: [UIColor whiteColor],
                           NSFontAttributeName: font
                           };
    
    NSArray* kinds = @[@"left-turn", @"left-bank", @"straight", @"right-bank", @"right-turn", @"about"];
    DockShipClassDetails* details = _ship.shipClassDetails;
    for (int i = 6; i >= 0; --i) {
        x = gridBox.origin.x;
        int speed = moveValues[i];
        int absSpeed = speed;
        if (speed < 0) {
            absSpeed = -speed;
        }
        for (int j = 0; j < 7; ++j) {
            if (j == 0) {
                NSString* move = [NSString stringWithFormat: @"%d", absSpeed];
                CGSize moveStringSize = [move sizeWithAttributes: attr];
                CGFloat deltaX = (rowSize - moveStringSize.width)/2.0;
                CGFloat deltaY = (rowSize - moveStringSize.height)/2.0;
                CGRect moveRect = NSMakeRect(x + deltaX, y + deltaY + lineWidth, moveStringSize.width, moveStringSize.height);
                [move drawInRect: moveRect withAttributes: attr];
            } else if (details != nil ){
                NSString* kind = kinds[j-1];
                DockManeuver* maneuver = [details getDockManeuver: speed kind: kind];
                if (maneuver != nil) {
                    NSString* kind = maneuver.kind;
                    NSString* color = maneuver.color;
                    NSString* directionName = kind;
                    if (speed < 0) {
                        directionName = @"backup";
                    }
                    NSString* fileName = [NSString stringWithFormat: @"%@-%@", [color lowercaseString], directionName];
                    NSImage* image = [NSImage imageNamed: fileName];
                    if (image) {
                        CGRect moveRect = NSMakeRect(x, y, rowSize, rowSize);
                        [image drawInRect:moveRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
                    }
                }
            }
            x += rowSize;
        }
        y += rowSize;
    }
#endif
}

@end
