#import "DockMoveGridView.h"

#import "DockManeuver+Addons.h"
#import "DockShip+Addons.h"
#import "DockShipClassDetails+Addons.h"

@implementation DockMoveGridView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];

    if (self) {
        // Initialization code
    }

    return self;
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect: rect];

    CGRect bounds = self.bounds;
    CGSize availableSize = bounds.size;
    CGFloat availableSpace = availableSize.height < availableSize.width ? availableSize.height : availableSize.width;
    CGFloat lineWidth = availableSpace / 100.0;

    CGRect blackBox = CGRectMake(0, 0, availableSpace, availableSpace);
    [[UIColor blackColor] set];
    UIBezierPath* blackBoxPath = [UIBezierPath bezierPathWithRect: blackBox];
    [blackBoxPath fill];
    [[UIColor whiteColor] set];
    CGFloat inset = lineWidth * 5;
    CGRect gridBox = CGRectInset(blackBox, inset, inset);
    UIBezierPath* gridBoxPath = [UIBezierPath bezierPathWithRect: gridBox];
    gridBoxPath.lineWidth = lineWidth;
    [gridBoxPath stroke];

    CGFloat rowSize = gridBox.size.width / 7.0;
    CGFloat fontSize = rowSize;

    CGFloat x = gridBox.origin.x + rowSize - 1;

    for (int i = 0; i < 6; ++i) {
        CGRect lineRect = CGRectMake(x, gridBox.origin.y, lineWidth, gridBox.size.height);
        UIBezierPath* line = [UIBezierPath bezierPathWithRect: lineRect];
        [line fill];
        x += rowSize;
    }

    CGFloat y = gridBox.origin.y + rowSize - 1;

    for (int i = 0; i < 6; ++i) {
        CGRect lineRect = CGRectMake(gridBox.origin.x, y, gridBox.size.width, lineWidth);
        UIBezierPath* line = [UIBezierPath bezierPathWithRect: lineRect];
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

    y = gridBox.origin.y + 1;
    UIFont* font = [UIFont fontWithName: @"Helvetica" size: fontSize];
    NSArray* kinds = @[@"left-turn", @"left-bank", @"straight", @"right-bank", @"right-turn", @"about"];
    DockShipClassDetails* details = _ship.shipClassDetails;
    if (details.hasSpins) {
        kinds = @[@"", @"left-spin", @"straight", @"right-spin", @"", @""];
    }

    for (int i = 0; i < 7; ++i) {
        x = gridBox.origin.x;
        int speed = [moveValues[i] intValue];
        NSNumber* speedNumber = [NSNumber numberWithInt: speed];
        BOOL hasSpeed = [speeds containsObject: speedNumber];
        int absSpeed = speed;

        if (speed < 0) {
            absSpeed = -speed;
        }

        for (int j = 0; j < 7; ++j) {
            if (j == 0) {
                if (hasSpeed) {
                    NSString* move = [NSString stringWithFormat: @"%d", absSpeed];
                    CGSize moveStringSize = [move sizeWithFont: font];
                    CGFloat deltaX = (rowSize - moveStringSize.width) / 2.0;
                    CGFloat deltaY = (rowSize - moveStringSize.height) / 2.0;
                    CGPoint movePoint = CGPointMake(x + deltaX, y + deltaY + lineWidth * 0.);

                    if (speed < 0) {
                        [[UIColor grayColor] set];
                    } else {
                        [[UIColor whiteColor] set];
                    }

                    [move drawAtPoint: movePoint withFont: font];
                }
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
                    UIImage* image = [UIImage imageNamed: fileName];

                    if (image) {
                        CGRect moveRect = CGRectMake(x, y, rowSize, rowSize);
                        [image drawInRect: moveRect blendMode: kCGBlendModeNormal alpha: 1.0];
                    }
                }
            }

            x += rowSize;
        }
        y += rowSize;
    }
}

-(void)setShip:(DockShip*)ship
{
    _ship = ship;
    [self setNeedsDisplay];
}

@end
