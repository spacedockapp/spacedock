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

    NSArray* moveValues = @[@5, @4, @3, @2, @1, @-1, @-2];
    NSSet* speeds = _ship.shipClassDetails.speeds;
    if ([speeds containsObject:@0] && [speeds containsObject:@5]) {
        moveValues = @[@5, @4, @3, @2, @1, @0, @-1, @-2];
    } else if ([speeds containsObject:@0] && ![speeds containsObject:@5]) {
        moveValues = @[@4, @3, @2, @1, @0, @-1, @-2];
    }
    if ([speeds containsObject:@-3]) {
        if (![speeds containsObject:@5]) {
            moveValues = [moveValues subarrayWithRange: NSMakeRange(1, moveValues.count - 1)];
        }
        moveValues = [moveValues arrayByAddingObject: @-3];
    }
    if ([speeds containsObject:@6]) {
        if (moveValues.count >= 7 && ![speeds containsObject:[moveValues objectAtIndex:(moveValues.count -1)]]) {
            moveValues = [moveValues subarrayWithRange: NSMakeRange(0, moveValues.count - 1)];
        }
        moveValues = [@[@6] arrayByAddingObjectsFromArray: moveValues];
    }

    CGRect bounds = self.bounds;
    CGSize availableSize = bounds.size;
    CGFloat availableSpace = availableSize.height < availableSize.width ? availableSize.height : availableSize.width;
    CGFloat lineWidth = availableSpace / 100.0;
    CGFloat rowSize = (availableSpace - (lineWidth*10)) / 7.0;
    CGFloat boxHeight = availableSpace;
    CGFloat boxWidth = availableSpace;
    if (moveValues.count > 7) {
        rowSize = (availableSpace - (lineWidth*10)) / moveValues.count;
        boxWidth = rowSize * 7 + (lineWidth*10);
    }
    
    CGRect blackBox = CGRectMake(0, 0, boxWidth, boxHeight);
    [[UIColor blackColor] set];
    UIBezierPath* blackBoxPath = [UIBezierPath bezierPathWithRect: blackBox];
    [blackBoxPath fill];
    [[UIColor whiteColor] set];
    CGFloat inset = lineWidth * 5;
    CGRect gridBox = CGRectInset(blackBox, inset, inset);
    UIBezierPath* gridBoxPath = [UIBezierPath bezierPathWithRect: gridBox];
    gridBoxPath.lineWidth = lineWidth;
    [gridBoxPath stroke];

    CGFloat fontSize = rowSize;

    CGFloat x = gridBox.origin.x + rowSize - 1;

    CGFloat y = gridBox.origin.y + rowSize - 1;
    
    for (int i = 0; i < 6; ++i) {
        CGRect lineRect = CGRectMake(x, gridBox.origin.y, lineWidth, gridBox.size.height);
        UIBezierPath* line = [UIBezierPath bezierPathWithRect: lineRect];
        [line fill];
        x += rowSize;
    }
    
    for (int i = 0; i < moveValues.count - 1; ++i) {
        CGRect lineRect = CGRectMake(gridBox.origin.x, y, gridBox.size.width, lineWidth);
        UIBezierPath* line = [UIBezierPath bezierPathWithRect: lineRect];
        [line fill];
        y += rowSize;
    }

    y = gridBox.origin.y + 1;
    UIFont* font = [UIFont fontWithName: @"Helvetica" size: fontSize];
    NSArray* kinds = @[@"left-turn", @"left-bank", @"straight", @"right-bank", @"right-turn", @"about"];
    DockShipClassDetails* details = _ship.shipClassDetails;
    if (details.hasSpins) {
        kinds = @[@"", @"left-spin", @"straight", @"right-spin", @"", @""];
    } else if (details.hasFlanks) {
        kinds = @[@"left-90-degree-rotate", @"left-flank", @"straight", @"right-flank", @"right-90-degree-rotate", @""];
    }

    for (int i = 0; i < moveValues.count; ++i) {
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
                    CGSize moveStringSize = [move sizeWithAttributes: @{NSFontAttributeName:font}];
                    CGFloat deltaX = (rowSize - moveStringSize.width) / 2.0;
                    CGFloat deltaY = (rowSize - moveStringSize.height) / 2.0;
                    CGPoint movePoint = CGPointMake(x + deltaX, y + deltaY + lineWidth * 0.);

                    if (speed < 0) {
                        [[UIColor grayColor] set];
                    } else {
                        [[UIColor whiteColor] set];
                    }

                    [move drawAtPoint: movePoint withAttributes: @{NSFontAttributeName:font}];
                }
            } else if (details != nil) {
                NSString* kind = kinds[j - 1];
                if (speed == 0) {
                    if ([kind isEqualToString:@"left-flank"]) {
                        kind = @"left-45-degree-rotate";
                    } else if ([kind isEqualToString:@"right-flank"]) {
                        kind = @"right-45-degree-rotate";
                    } else if ([kind isEqualToString:@"straight"]) {
                        kind = @"stop";
                    }
                }
                DockManeuver* maneuver = [details getDockManeuver: speed kind: kind];

                if (maneuver != nil) {
                    NSString* kind = maneuver.kind;
                    NSString* color = maneuver.color;
                    NSString* directionName = kind;

                    if (speed < 0) {
                        directionName = @"backup";
                    } else if (speed == 0) {
                        if ([directionName isEqualToString:@"left-flank"]) {
                            directionName = @"left-45-degree-rotate";
                        } else if ([directionName isEqualToString:@"right-flank"]) {
                            directionName = @"right-45-degree-rotate";
                        } else if ([directionName isEqualToString:@"straight"]) {
                            directionName = @"stop";
                        }
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
