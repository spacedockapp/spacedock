#import "DockMoveGrid.h"

#import "DockManeuver.h"
#import "DockShip+Addons.h"
#import "DockShipClassDetails+Addons.h"

@implementation DockMoveGrid

-(id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame: frame];

    if (self) {
        // Initialization code here.
    }

    return self;
}

-(void)setShip:(DockShip*)ship
{
    _ship = ship;
    [self setNeedsDisplay: YES];
}

-(void)drawRect:(NSRect)dirtyRect
{
    [super drawRect: dirtyRect];

    NSRect bounds = self.bounds;
    NSSize availableSize = bounds.size;
    CGFloat availableSpace = availableSize.height < availableSize.width ? availableSize.height : availableSize.width;
    CGFloat lineWidth = availableSpace / 100.0;
    CGFloat offsetX = (bounds.size.width - availableSpace) / 2;
    CGFloat offsetY = (bounds.size.height - availableSpace) / 2;

    NSRect blackBox = NSMakeRect(offsetX, offsetY, availableSpace, availableSpace);


    [[NSColor blackColor] set];
    [NSBezierPath setDefaultLineWidth: lineWidth];
    [NSBezierPath fillRect: blackBox];
    [[NSColor whiteColor] set];
    CGFloat inset = lineWidth * 5;
    NSRect gridBox = NSInsetRect(blackBox, inset, inset);
    [NSBezierPath strokeRect: gridBox];
    CGFloat rowSize = gridBox.size.width / 7.0;
    CGFloat fontSize = rowSize;

    CGFloat x = gridBox.origin.x + rowSize - 1;

    for (int i = 0; i < 6; ++i) {
        NSRect lineRect = NSMakeRect(x, gridBox.origin.y, lineWidth, gridBox.size.height);
        NSBezierPath* line = [NSBezierPath bezierPathWithRect: lineRect];
        [line fill];
        x += rowSize;
    }

    CGFloat y = gridBox.origin.y + rowSize - 1;

    for (int i = 0; i < 6; ++i) {
        NSRect lineRect = NSMakeRect(gridBox.origin.x, y, gridBox.size.width, lineWidth);
        NSBezierPath* line = [NSBezierPath bezierPathWithRect: lineRect];
        [line fill];
        y += rowSize;
    }

    NSArray* moveValues = @[@5, @4, @3, @2, @1, @-1, @-2];
    NSSet* speeds = _ship.shipClassDetails.speeds;
    if ([speeds containsObject: @-3]) {
        moveValues = [moveValues subarrayWithRange: NSMakeRange(1, moveValues.count - 1)];
        moveValues = [moveValues arrayByAddingObject: @-3];
    } else if ([speeds containsObject: @6]) {
        moveValues = [moveValues subarrayWithRange: NSMakeRange(0, moveValues.count - 1)];
        moveValues = [@[@6] arrayByAddingObjectsFromArray: moveValues];
    }
    
    y = gridBox.origin.y - 1;
    NSFont* font = [NSFont fontWithName: @"Helvetica" size: fontSize];
    NSDictionary* attr = @{
        NSForegroundColorAttributeName: [NSColor whiteColor],
        NSFontAttributeName: font
    };

    NSArray* kinds = @[@"left-turn", @"left-bank", @"straight", @"right-bank", @"right-turn", @"about"];
    DockShipClassDetails* details = _ship.shipClassDetails;
    if (details.hasSpins) {
        kinds = @[@"", @"left-spin", @"straight", @"right-spin", @"", @""];
    }

    for (int i = 6; i >= 0; --i) {
        x = gridBox.origin.x;
        int speed = [moveValues[i] intValue];
        int absSpeed = speed;

        if (speed < 0) {
            absSpeed = -speed;
        }

        for (int j = 0; j < 7; ++j) {
            if (j == 0) {
                NSString* move = [NSString stringWithFormat: @"%d", absSpeed];
                NSSize moveStringSize = [move sizeWithAttributes: attr];
                CGFloat deltaX = (rowSize - moveStringSize.width) / 2.0;
                CGFloat deltaY = (rowSize - moveStringSize.height) / 2.0;
                NSRect moveRect = NSMakeRect(x + deltaX, y + deltaY + lineWidth, moveStringSize.width, moveStringSize.height);
                [move drawInRect: moveRect withAttributes: attr];
            } else if (details != nil) {
                NSString* kind = kinds[j - 1];
                DockManeuver* maneuver = [details getDockManeuver: speed kind: kind];

                if (maneuver != nil) {
                    NSString* kind = maneuver.kind;
                    NSString* color = maneuver.color;
                    NSString* directionName = kind;

                    if (speed < 0) {
                        directionName = @"backup";
                    }

                    NSString* fileName = [NSString stringWithFormat: @"%@-%@", color, directionName];
                    NSImage* image = [NSImage imageNamed: fileName];

                    if (image) {
                        NSRect moveRect = NSMakeRect(x, y, rowSize, rowSize);
                        [image drawInRect: moveRect fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1.0];
                    }
                }
            }

            x += rowSize;
        }
        y += rowSize;
    }

}

@end
