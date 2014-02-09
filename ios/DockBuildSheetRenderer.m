#import "DockBuildSheetRenderer.h"

#import <CoreText/CoreText.h>

#import "DockEquippedShip+Addons.h"
#import "DockCaptain+Addons.h"
#import "DockUpgrade+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockSquad+Addons.h"

NSString* kLabelFont = @"AvenirNext-Medium";
NSString* kFieldFont = @"Noteworthy-Light";
CGFloat kDefaultMargin = 6;
CGFloat kFieldHeight = 20;
CGFloat kDefaultLineWidth = 1;
CGFloat kGridDividerWidth = .6;
const int kGridRows = 12;
const int kGridTotalSPHeight = 20;
const int kLabelFontSize = 13;
const int kTotalSPLabelFontSize = 11;
const CGFloat kFixedGridColumnWidth = 40;
const CGFloat kShipGridHeight = 150;


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
    NSMutableParagraphStyle* centered = [[NSMutableParagraphStyle alloc] init];
    centered.alignment = _alignment;
    _attributes = @{
                    NSParagraphStyleAttributeName: centered,
                    NSForegroundColorAttributeName: _color,
                    NSFontAttributeName: _font
                    };
    if (_frame) {
        [_color set];
        UIBezierPath* framePath = [UIBezierPath bezierPathWithRect: bounds];
        framePath.lineWidth = kDefaultLineWidth;
        [framePath stroke];
    }
    bounds = CGRectInset(bounds, 4, 0);
    [_text drawInRect: bounds withAttributes: _attributes];
}

@end

@interface DockLabeledField : NSObject
@property (strong, nonatomic) DockTextBox* label;
@property (strong, nonatomic) DockTextBox* field;
-(id)initWithLabel:(NSString*)label text:(NSString*)text;
-(void)draw:(CGRect)bounds;
@end

@implementation DockLabeledField

-(id)initWithLabel:(NSString*)label text:(NSString*)text
{
    self = [super init];
    if (self != nil) {
        _field = [[DockTextBox alloc] initWithText: text];
        _field.font = [UIFont fontWithName: kFieldFont size: 11];
        _field.frame = YES;
        _label = [[DockTextBox alloc] initWithText: label];
        _label.alignment = NSTextAlignmentRight;
        _label.font = [UIFont fontWithName: kLabelFont size: kLabelFontSize];
    }
    return self;
}

-(void)draw:(CGRect)bounds
{
    CGFloat labelWidth = bounds.size.width / 4;
    CGFloat fieldWidth = bounds.size.width - labelWidth;
    CGFloat baselineAdjust = 10;
    CGFloat y = bounds.origin.y + baselineAdjust;
    CGRect labelRect = CGRectMake(bounds.origin.x, y,
                                  labelWidth, bounds.size.height);
    [_label draw: labelRect];
    CGRect fieldRect = CGRectMake(bounds.origin.x + labelWidth, y,
                                  fieldWidth, bounds.size.height);
    [_field draw: fieldRect];
}

@end

@interface DockShipGrid : NSObject
@property (assign, nonatomic) CGRect bounds;
@property (strong, nonatomic) UIBezierPath* boundsPath;
@property (strong, nonatomic) DockEquippedShip* ship;
@property (strong, nonatomic) NSMutableArray* upgrades;
-(id)initWithBounds:(CGRect)bounds ship:(DockEquippedShip*)ship;
@end

@implementation DockShipGrid

-(id)initWithBounds:(CGRect)bounds ship:(DockEquippedShip*)ship
{
    self = [super init];
    if (self != nil) {
        _bounds = bounds;
        _ship = ship;
        CGRect upgradeListBounds = _bounds;
        upgradeListBounds.size.height -= kGridTotalSPHeight;
        _boundsPath = [UIBezierPath bezierPathWithRect: upgradeListBounds];
        _boundsPath.lineWidth = kDefaultLineWidth;
        NSArray* equippedUpgrades = _ship.sortedUpgrades;
        _upgrades = [[NSMutableArray alloc] initWithCapacity: equippedUpgrades.count];

        for (DockEquippedUpgrade* upgrade in equippedUpgrades) {
            if (![upgrade isPlaceholder] && ![upgrade.upgrade isCaptain]) {
                [_upgrades addObject: upgrade];
            }
        }
    }
    return self;
}

-(NSString*)handleShip:(int)col
{
    switch(col) {
    case 0:
        return @"Ship";

    case 2:
        return [_ship factionCode];

    case 3:
        return [NSString stringWithFormat: @"%d", [_ship baseCost]];
    }
    
    return [_ship descriptiveTitle];
}

-(NSString*)handleCaptain:(int)col
{
    DockEquippedUpgrade* equippedCaptain = [_ship equippedCaptain];
    DockCaptain* captain = (DockCaptain*)[equippedCaptain upgrade];

    switch(col) {
    case 0:
        return @"Cap";

    case 2:
        return [captain factionCode];

    case 3:
        return [NSString stringWithFormat: @"%d", equippedCaptain.cost];
    }
    
    return captain.title;
}

-(NSString*)handleUpgrade:(int)col index:(long)index
{
    if (index < _upgrades.count) {
        DockEquippedUpgrade* equippedUpgrade = _upgrades[index];
        if (equippedUpgrade.isPlaceholder) {
            return @"";
        }
        if (col == 0) {
            return equippedUpgrade.upgrade.typeCode;
        }
        if (col == 2) {
            return equippedUpgrade.upgrade.factionCode;
        }

        if (col == 3) {
            if ([[equippedUpgrade overridden] boolValue]) {
                return [NSString stringWithFormat: @"%@ (%d)", [equippedUpgrade overriddenCost], [equippedUpgrade nonOverriddenCost]];
            }
            return [NSString stringWithFormat: @"%d", [equippedUpgrade cost]];
        }
        
        return equippedUpgrade.upgrade.title;
    }

    return nil;
}

-(void)draw
{
    CGFloat upgradeListHeight = _bounds.size.height - kGridTotalSPHeight;
    CGFloat rowHeight = upgradeListHeight / kGridRows;
    int dividerCount = kGridRows - 1;
    CGFloat left = _bounds.origin.x;
    CGFloat right = left + _bounds.size.width;
    CGFloat y = _bounds.origin.y + rowHeight;
    [[UIColor lightGrayColor] set];
    for (int i = 0; i < dividerCount; ++i) {
        UIBezierPath* p = [UIBezierPath bezierPath];
        [p moveToPoint: CGPointMake(left, y)];
        [p addLineToPoint: CGPointMake(right, y)];
        p.lineWidth = kGridDividerWidth;
        [p stroke];
        y += rowHeight;
    }
    
    CGFloat secondColumnWidth = _bounds.size.width - 3 * kFixedGridColumnWidth;
    CGFloat top = _bounds.origin.y;
    CGFloat bottom = top + upgradeListHeight;
    CGFloat x = _bounds.origin.x + kFixedGridColumnWidth;
    for (int i = 0; i < 3; ++i) {
        UIBezierPath* p = [UIBezierPath bezierPath];
        [p moveToPoint: CGPointMake(x, top)];
        [p addLineToPoint: CGPointMake(x, bottom)];
        p.lineWidth = kGridDividerWidth;
        [p stroke];
        if (i == 0) {
            x += secondColumnWidth;
        } else {
            x += kFixedGridColumnWidth;
        }
    }

    NSArray* labels = @[@"Type", @"Card Title", @"Faction", @"Cost"];
    CGRect labelBox = CGRectMake(_bounds.origin.x, _bounds.origin.y, kFixedGridColumnWidth, rowHeight);
    x = _bounds.origin.x;
    y = _bounds.origin.y;
    DockTextBox* labelTextBox = [[DockTextBox alloc] initWithText: @""];
    labelTextBox.alignment = NSTextAlignmentCenter;
    for (int j = 0; j < kGridRows; ++j) {
        CGRect r = labelBox;
        for (int i = 0; i < 4; ++i) {
            NSString* s = nil;
            labelTextBox.alignment = NSTextAlignmentCenter;
            if (j == 0) {
                s = labels[i];
                labelTextBox.font = [UIFont fontWithName: kLabelFont size: 7];
            } else {
                if (_ship != nil) {
                    switch (j) {
                        case 1:
                            s = [self handleShip: i];
                            break;
                            
                        case 2:
                            s = [self handleCaptain: i];
                            break;
                            
                        default:
                            s = [self handleUpgrade: i index: j - 3];
                            break;
                    }
                    if (i == 1) {
                        labelTextBox.alignment = NSTextAlignmentLeft;
                    }
                    labelTextBox.font = [UIFont fontWithName: kFieldFont size: 7];
                }
            }
            if (i == 1) {
                labelBox.size.width = secondColumnWidth;
            } else {
                labelBox.size.width = kFixedGridColumnWidth;
            }
            labelTextBox.text = s;
            [labelTextBox draw: labelBox];
            labelBox = CGRectOffset(labelBox, labelBox.size.width, 0);
        }
        r.origin.y += rowHeight;
        labelBox = r;
    }

    CGFloat totalWidth = 2*kFixedGridColumnWidth + secondColumnWidth;
    CGFloat spTop = top + _bounds.size.height - kGridTotalSPHeight;
    CGRect totalSPBox = CGRectMake(left, spTop + 3, totalWidth, 14);
    DockTextBox* totalSP = [[DockTextBox alloc] initWithText: @"Total SP"];
    totalSP.alignment = NSTextAlignmentRight;
    totalSP.font = [UIFont fontWithName: kLabelFont size: kTotalSPLabelFontSize];
    [totalSP draw: totalSPBox];
    totalSPBox = CGRectMake(CGRectGetMaxX(totalSPBox), spTop, kFixedGridColumnWidth, 20);
    CGRect totalSPBoxText = totalSPBox;
    totalSPBoxText.origin.y += 3;
    totalSPBoxText.size.height -= 6;
    totalSP.text = [NSString stringWithFormat: @"%d", [_ship cost]];
    totalSP.alignment = NSTextAlignmentCenter;
    [totalSP draw: totalSPBoxText];
    UIBezierPath* totalSPPath = [UIBezierPath bezierPathWithRect: totalSPBox];
    totalSPPath.lineWidth = kDefaultLineWidth;
    [[UIColor blackColor] set];
    [totalSPPath stroke];
    [_boundsPath stroke];
}

@end

@interface DockBuildSheetRenderer ()
@property (strong, nonatomic) DockSquad* targetSquad;
@end

@implementation DockBuildSheetRenderer

-(id)initWithSquad:(DockSquad*)targetSquad
{
    self = [super init];
    if (self != nil) {
        _targetSquad = targetSquad;
    }
    return self;
}

-(void)draw:(CGRect)targetBounds
{
    CGFloat left = targetBounds.origin.x;
    CGFloat right = left + targetBounds.size.width;
    CGFloat top = targetBounds.origin.y;
    
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
    box.font = [UIFont fontWithName: kLabelFont size:25.0];
    CGRect b = CGRectInset(blackBox, kDefaultMargin, kDefaultMargin);
    [box draw: b];
    
    CGFloat halfWidth = targetBounds.size.width/2;
    CGFloat fieldWidth = halfWidth - 3 * kDefaultMargin;
    
    NSArray* leftFields = @[
        @[@"Date:", @"2/3/2014"],
        @[@"Event:", @"Dominion Wary OP 5"],
        @[@"Faction:", @"Romulan"],
    ];

    CGFloat fieldsTop = top + blackBox.size.height;
    CGRect fieldBox = CGRectMake(left + kDefaultMargin, fieldsTop,
                                     fieldWidth,  kFieldHeight);
    for (NSArray* parts in leftFields) {
        DockLabeledField* field = [[DockLabeledField alloc] initWithLabel: parts[0]
                                                                text: parts[1]];
        [field draw: fieldBox];
        fieldBox = CGRectOffset(fieldBox, 0, fieldBox.size.height + kDefaultMargin);
    }

    NSArray* rightFields = @[
        @[@"Name:", @"Rob Tsuk"],
        @[@"Email:", @"rob@tsuk.com"],
    ];
    
    CGFloat fieldBottom = fieldBox.origin.y + fieldBox.size.height;

    fieldBox = CGRectMake(left + halfWidth + kDefaultMargin, fieldsTop,
                                     fieldWidth,  kFieldHeight);
    for (NSArray* parts in rightFields) {
        DockLabeledField* field = [[DockLabeledField alloc] initWithLabel: parts[0]
                                                                text: parts[1]];
        [field draw: fieldBox];
        fieldBox = CGRectOffset(fieldBox, 0, fieldBox.size.height + kDefaultMargin);
    }
    
    CGFloat gridWith = fieldWidth - 5 * kDefaultMargin;
    NSOrderedSet* ships = _targetSquad.equippedShips;
    NSInteger shipCount = ships.count;
    DockEquippedShip* ship = nil;
    for (int i = 0; i < 4; ++i) {
        if (i < shipCount) {
            ship = [ships objectAtIndex: i];
        } else {
            ship = nil;
        }
        CGFloat x, y;
        switch(i) {
        case 0:
            x = left + halfWidth - gridWith - 2*kDefaultMargin;
            y = fieldBottom;
            break;
        case 1:
            x = right - gridWith - 2*kDefaultMargin;
            y = fieldBottom;
            break;
        case 2:
            x = left + halfWidth - gridWith - 2*kDefaultMargin;
            y = fieldBottom + kShipGridHeight + 16;
            break;
        default:
            x = right - gridWith - 2*kDefaultMargin;
            y = fieldBottom + kShipGridHeight + 16;
            break;
        }
        CGRect gridBox = CGRectMake(x, y, gridWith, kShipGridHeight);
        DockShipGrid* grid = [[DockShipGrid alloc] initWithBounds: gridBox ship: ship];
        [grid draw];
    }

}

@end
