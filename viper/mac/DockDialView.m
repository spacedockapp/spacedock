#import "DockDialView.h"

#import "DockManeuver+Addons.h"
#import "DockShip+Addons.h"
#import "DockShipClassDetails+Addons.h"

#import <QuartzCore/QuartzCore.h>

@implementation DockDialView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

const CGFloat kDegrees180 = M_PI;
const CGFloat kDegrees90 = M_PI/2;
const CGFloat kDegrees45 = M_PI/4;
const CGFloat kDegrees270 = kDegrees180 + kDegrees90;

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSaveGState(context);

    NSRect bounds = self.bounds;
    [[NSColor whiteColor] set];
    [NSBezierPath fillRect: bounds];

    CGFloat halfWidth = floor(bounds.size.width/2);
    CGFloat halfHeight = floor(bounds.size.height/2);
    CGFloat minDim = MIN(halfWidth, halfHeight);
    CGFloat imageSize = floor(minDim/4);
    CGFloat r = minDim - imageSize;
    CGContextTranslateCTM(context, halfWidth, bounds.size.height - halfWidth);
    NSInteger count = _ship.shipClassDetails.maneuvers.count;
    CGFloat arc = M_PI * 2.0 / (CGFloat)count;
    CGFloat angle = 0;
    [[NSColor whiteColor] set];

    NSArray* moveValues = @[@5, @4, @3, @2, @1, @-1, @-2];
    NSSet* speeds = _ship.shipClassDetails.speeds;
    if ([speeds containsObject: @-3]) {
        moveValues = [moveValues subarrayWithRange: NSMakeRange(1, moveValues.count - 1)];
        moveValues = [moveValues arrayByAddingObject: @-3];
    } else if ([speeds containsObject: @6]) {
        moveValues = [moveValues subarrayWithRange: NSMakeRange(0, moveValues.count - 1)];
        moveValues = [@[@6] arrayByAddingObjectsFromArray: moveValues];
    }
    
    NSArray* kinds = @[@"left-turn", @"left-bank", @"straight", @"right-bank", @"right-turn", @"about"];
    DockShipClassDetails* details = _ship.shipClassDetails;
    if (details.hasSpins) {
        kinds = @[@"", @"left-spin", @"straight", @"right-spin", @"", @""];
    }

    CGFloat fontSize = minDim / 6;
    NSFont* font = [NSFont fontWithName: @"Helvetica Bold" size: fontSize];
    NSDictionary* attr = @{
        NSForegroundColorAttributeName: [NSColor blackColor],
        NSFontAttributeName: font
    };

    NSMutableDictionary* filteredImages = [[NSMutableDictionary alloc] initWithCapacity: 0];

    for (int i = 6; i >= 0; --i) {
        NSString* speedString = moveValues[i];
        int speed = [speedString intValue];
        int absSpeed = speed;

        if (speed < 0) {
            absSpeed = -speed;
        }

        for (int j = 0; j < 6; ++j) {
            if (details != nil) {
                NSString* kind = kinds[j];
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
                        CGContextSaveGState(context);
                        CGContextRotateCTM(context, angle);
                        CGContextTranslateCTM(context, 0, r);
                        NSRect moveRect = NSMakeRect(-imageSize/2, -imageSize/2, imageSize, imageSize);
                        if ([color isEqualToString: @"white"]) {
                            CIImage* output = [filteredImages objectForKey: fileName];
                            if (output == nil) {
                                CIImage* ciImage = [[CIImage alloc] initWithData:[image TIFFRepresentation]];
                                if ([image isFlipped])
                                {
                                    CGRect cgRect    = [ciImage extent];
                                    CGAffineTransform transform;
                                    transform = CGAffineTransformMakeTranslation(0.0,cgRect.size.height);
                                    transform = CGAffineTransformScale(transform, 1.0, -1.0);
                                    ciImage   = [ciImage imageByApplyingTransform:transform];
                                }
                                CIFilter* filter = [CIFilter filterWithName:@"CIColorInvert"];
                                [filter setDefaults];
                                [filter setValue:ciImage forKey:@"inputImage"];
                                output = [filter valueForKey:@"outputImage"];
                                [filteredImages setObject: output forKey: fileName];
                            }
                            [output drawInRect: moveRect fromRect: NSRectFromCGRect([output extent]) operation: NSCompositeSourceOver fraction: 1.0];
                        } else {
                            [image drawInRect: moveRect fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1.0];
                        }
                        CGContextTranslateCTM(context, 0, -imageSize-minDim/10);
                        NSString* move = [NSString stringWithFormat: @"%d", absSpeed];
                        NSSize moveStringSize = [move sizeWithAttributes: attr];
                        moveRect = NSMakeRect(-floor(moveStringSize.width/2), 0, moveStringSize.width, moveStringSize.height);
                        [move drawInRect: moveRect withAttributes: attr];
                        CGContextRestoreGState(context);
                    }
                    angle -= arc;
                }
            }
        }
    }
    CGContextRestoreGState(context);
    CGFloat titleFontSize = minDim / 5;
    NSFont* titleFont = [NSFont fontWithName: @"Helvetica Bold" size: titleFontSize];
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSCenterTextAlignment;
    NSDictionary* titleAttr = @{
        NSForegroundColorAttributeName: [NSColor blackColor],
        NSFontAttributeName: titleFont,
        NSParagraphStyleAttributeName: paragraphStyle
    };
    NSString* title = _ship.descriptiveTitle;
    NSRect titleRect = self.bounds;
    NSSize titleStringSize = [title sizeWithAttributes: titleAttr];
    titleRect.size.height = titleStringSize.height;
    titleRect.origin.y = 10;
    [title drawInRect: titleRect withAttributes: titleAttr];
    [[NSColor blackColor] set];
    [NSBezierPath strokeRect: bounds];
}

@end
