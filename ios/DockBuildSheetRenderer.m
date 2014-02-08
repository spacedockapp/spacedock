#import "DockBuildSheetRenderer.h"

#import <CoreText/CoreText.h>

@interface DockTextBox : NSObject
@property (assign, nonatomic) NSInteger alignment;
@property (assign, nonatomic) BOOL frame;
@property (strong, nonatomic) UIColor* color;
@property (strong, nonatomic) UIFont* font;
@property (copy, nonatomic) NSString* text;

-(id)initWithText:(NSString*)text;
-(void)draw:(CGRect)bounds;
@end

@interface DockTextBox () {
    NSDictionary* _attributes;
}
@end


@implementation DockTextBox

-(id)initWithText:(NSString*)text
{
    self = [super init];
    if (self != nil) {
        _alignment = NSTextAlignmentLeft;
        _color = [UIColor blackColor];
        _font = [UIFont systemFontOfSize: 25];
        self.text = text;
    }
    return self;
}

-(void)draw:(CGRect)bounds
{
    if (_attributes == nil) {
        NSMutableParagraphStyle* centered = [[NSMutableParagraphStyle alloc] init];
        centered.alignment = _alignment;
        _attributes = @{
                        NSParagraphStyleAttributeName: centered,
                        NSForegroundColorAttributeName: _color,
                        NSFontAttributeName: _font
                        };
    }

    if (_frame) {
        [_color set];
        UIBezierPath* framePath = [UIBezierPath bezierPathWithRect: bounds];
        [framePath stroke];
    }
    [_text drawInRect: bounds withAttributes: _attributes];
}

@end

@implementation DockBuildSheetRenderer

-(void)draw:(CGRect)targetBounds
{
    CGFloat left = targetBounds.origin.x;
    CGFloat top = targetBounds.origin.y;
    
    NSString* labelFont = @"AvenirNext-Medium";
    CGRect pageBounds = targetBounds;
    CGFloat boxHeight = 60;
    CGRect blackBox = CGRectMake(left, top, pageBounds.size.width, boxHeight);
    [[UIColor blackColor] set];
    UIBezierPath* blackBoxPath = [UIBezierPath bezierPathWithRect: blackBox];
    [blackBoxPath fill];
    
    NSString* fbs = @"Fleet Build Sheet";
    DockTextBox* box = [[DockTextBox alloc] initWithText: fbs];
    box.color = [UIColor whiteColor];
    box.alignment = NSTextAlignmentCenter;
    box.font = [UIFont fontWithName:labelFont size:25.0];
    CGRect b = CGRectInset(blackBox, 10, 10);
    [box draw: b];
    
    CGFloat halfWidth = targetBounds.size.width/2;
    CGFloat centerH = left + halfWidth;
    CGFloat fieldWidth = halfWidth * 2 / 3;
    DockTextBox* nameLabel = [[DockTextBox alloc] initWithText: @"Date:"];
    nameLabel.font = [UIFont fontWithName: labelFont size: 18];
    nameLabel.alignment = NSTextAlignmentRight;
    CGRect nameLabelBox = CGRectMake(centerH - fieldWidth, top + 200, fieldWidth, 20);
    [nameLabel draw: nameLabelBox];
}

@end
