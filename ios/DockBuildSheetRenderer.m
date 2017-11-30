#import "DockBuildSheetRenderer.h"

#import <CoreText/CoreText.h>

#import "DockEquippedShip+Addons.h"
#import "DockCaptain+Addons.h"
#import "DockUpgrade+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockFlagship+Addons.h"
#import "DockResource+Addons.h"
#import "DockSquad+Addons.h"
#import "DockSetItem+Addons.h"
#import "DockShip+Addons.h"
#import "DockUtils.h"

NSString* kLabelFont = @"AvenirNext-Medium";
NSString* kLabelFontNarrow = @"AvenirNextCondensed-Medium";
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

NSString* kPlayerNameKey = @"playerName";
NSString* kPlayerEmailKey = @"playerEmail";
NSString* kEventFactionKey = @"eventFaction";
NSString* kEventNameKey = @"eventName";
NSString* kBlindBuyKey = @"blindBuy";
NSString* kLightHeaderKey = @"lightHeader";

@interface DockTextBox : NSObject
@property (assign, nonatomic) NSInteger alignment;
@property (assign, nonatomic) NSInteger linebreak;
@property (assign, nonatomic) BOOL frame;
@property (assign, nonatomic) BOOL centerVertically;
@property (strong, nonatomic) UIColor* color;
@property (strong, nonatomic) UIFont* font;
@property (strong, nonatomic) NSStringDrawingContext* stringContext;
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
        _linebreak = NSLineBreakByWordWrapping;
        _color = [UIColor blackColor];
        _font = [UIFont systemFontOfSize: 25];
        _stringContext = [[NSStringDrawingContext alloc] init];
        self.text = text;
    }
    return self;
}

-(void)draw:(CGRect)bounds
{
    NSMutableParagraphStyle* centered = [[NSMutableParagraphStyle alloc] init];
    centered.alignment = _alignment;
    centered.lineBreakMode = _linebreak;
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
    if (_centerVertically) {
        CGRect r = [_text boundingRectWithSize: bounds.size
                            options: NSStringDrawingUsesLineFragmentOrigin
                         attributes: _attributes
                            context: _stringContext];
        bounds.origin.y += (bounds.size.height - r.size.height)/2;
    }
    [_text drawInRect: bounds withAttributes: _attributes];
}

@end

@interface DockLabeledField : NSObject
@property (strong, nonatomic) DockTextBox* label;
@property (strong, nonatomic) DockTextBox* field;
@property (assign, nonatomic) CGFloat labelFraction;
@property (assign, nonatomic) NSInteger textAlignment;
-(id)initWithLabel:(NSString*)label text:(NSString*)text;
-(void)draw:(CGRect)bounds;
@end

@implementation DockLabeledField

-(id)initWithLabel:(NSString*)label text:(NSString*)text
{
    self = [super init];
    if (self != nil) {
        _textAlignment = NSTextAlignmentLeft;
        _field = [[DockTextBox alloc] initWithText: text];
        _field.font = [UIFont fontWithName: kFieldFont size: 11];
        _field.frame = YES;
        _field.alignment = _textAlignment;
        _label = [[DockTextBox alloc] initWithText: label];
        _label.alignment = NSTextAlignmentRight;
        _label.font = [UIFont fontWithName: kLabelFont size: kLabelFontSize];
        _labelFraction = 1.0/4.0;
    }
    return self;
}

-(void)draw:(CGRect)bounds
{
    CGFloat labelWidth = bounds.size.width * _labelFraction;
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

-(void)setTextAlignment:(NSInteger)textAlignment
{
    _textAlignment = textAlignment;
    _field.alignment = textAlignment;
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
            if (![upgrade isPlaceholder] && [upgrade.upgrade isCaptain] && [upgrade.specialTag isEqualToString:@"AdditionalCaptain"]) {
                [_upgrades addObject: upgrade];
            }
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
    return [_ship descriptiveTitleWithSet];
}

-(NSString*)handleCaptain:(int)col
{
    if (_ship.isFighterSquadron || _ship.captainCount == 0) {
        return @"";
    }
    
    DockEquippedUpgrade* equippedCaptain = [_ship equippedCaptain];
    DockCaptain* captain = (DockCaptain*)[equippedCaptain upgrade];

    switch(col) {
    case 0:
        return @"Cap";

    case 2:
        return [captain factionCode];

    case 3:
        return costString(equippedCaptain);
    }
    
    return [equippedCaptain descriptionForBuildSheet];
}

-(NSString*)handleFlagship:(int)col
{
    if (_ship.isFighterSquadron) {
        return @"";
    }

    switch(col) {
    case 0:
        return @"Flag";

    case 2:
        return [_ship.flagship factionCode];

    case 3:
        return [NSString stringWithFormat: @"%@", _ship.squad.resource.cost];
    }
    
    return _ship.flagship.name;
}

-(NSString*)handleUpgrade:(int)col index:(long)index
{
    if (_ship.isFighterSquadron) {
        return @"";
    }

    if (index < _upgrades.count) {
        DockEquippedUpgrade* equippedUpgrade = _upgrades[index];
        if (equippedUpgrade.isPlaceholder) {
            return @"";
        }
        if (col == 0) {
            return equippedUpgrade.upgrade.typeCode;
        }
        if (col == 2) {
            if ([equippedUpgrade.specialTag hasPrefix:@"Quark"]) {
                return @"";
            }
            return equippedUpgrade.upgrade.factionCode;
        }

        if (col == 3) {
            if ([[equippedUpgrade descriptionForBuildSheet] isEqualToString:@"Federation Elite Talent"] || [[equippedUpgrade descriptionForBuildSheet] isEqualToString:@"Romulan Elite Talent"] || [[equippedUpgrade descriptionForBuildSheet] isEqualToString:@"Tech Upgrade"] || [[equippedUpgrade descriptionForBuildSheet] isEqualToString:@"Weapon Upgrade"] || [[equippedUpgrade descriptionForBuildSheet] isEqualToString:@"Klingon Elite Talent"] ) {
                return [NSString stringWithFormat: @"%d",equippedUpgrade.cost];
            }
            if ([[equippedUpgrade overridden] boolValue]) {
                return [NSString stringWithFormat: @"%@ (%d)", [equippedUpgrade overriddenCost], [equippedUpgrade nonOverriddenCost]];
            }
            return costString(equippedUpgrade);
        }
        
        return [equippedUpgrade descriptionForBuildSheet];
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
    //x = _bounds.origin.x;
    //y = _bounds.origin.y;
    int extraLines = 3;
    if (_ship.flagship) {
        extraLines += 1;
    } else if (_ship.isFighterSquadron) {
        extraLines -= 1;
    }
    DockTextBox* labelTextBox = [[DockTextBox alloc] initWithText: @""];
    labelTextBox.linebreak = NSLineBreakByTruncatingTail;
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
                            if (extraLines == 4) {
                                s = [self handleFlagship: i];
                            } else {
                                s = [self handleCaptain: i];
                            }
                            break;
                            
                        case 3:
                            if (extraLines == 4) {
                                s = [self handleCaptain: i];
                            } else {
                                s = [self handleUpgrade: i index: j - extraLines];
                            }
                            break;
                            
                        default:
                            s = [self handleUpgrade: i index: j - extraLines];
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
    if (_ship) {
        [totalSP draw: totalSPBoxText];
    }
    UIBezierPath* totalSPPath = [UIBezierPath bezierPathWithRect: totalSPBox];
    totalSPPath.lineWidth = kDefaultLineWidth;
    [[UIColor blackColor] set];
    [totalSPPath stroke];
    [_boundsPath stroke];
}

@end

@interface DockCostGrid : NSObject
@property (assign, nonatomic) CGRect bounds;
@property (strong, nonatomic) UIBezierPath* boundsPath;
@property (strong, nonatomic) DockSquad* squad;
@property (assign, nonatomic) BOOL blind;
@property NSArray* labels;
@property NSArray* values;
-(id)initWithBounds:(CGRect)bounds squad:(DockSquad*)squad;
@end

@implementation DockCostGrid

-(id)initWithBounds:(CGRect)bounds squad:(DockSquad*)squad blind:(BOOL)blind
{
    _blind = blind;

    return [self initWithBounds:bounds squad:squad];
}

-(id)initWithBounds:(CGRect)bounds squad:(DockSquad*)squad
{
    self = [super init];
    if (self != nil) {
        _bounds = bounds;
        _squad = squad;
        _boundsPath = [UIBezierPath bezierPathWithRect: bounds];
        _boundsPath.lineWidth = kDefaultLineWidth;
        _labels = @[
            @"Ship 1",
            @"Ship 2",
            @"Ship 3",
            @"Ship 4",
            @"Resource",
            @"Other",
            @"Total"
        ];
        NSMutableArray* valuesMut = [[NSMutableArray alloc] initWithCapacity: 6];
        for (int i  = 0; i < 4; ++i) {
            if (i < _squad.equippedShips.count) {
                DockEquippedShip* ship = _squad.equippedShips[i];
                [valuesMut addObject: [NSString stringWithFormat: @"%d", ship.cost]];
            } else {
                [valuesMut addObject: @""];
            }
        }
        [valuesMut addObject: resourceCost(_squad)];
        [valuesMut addObject: otherCost(_squad)];
        if (_blind) {
            [valuesMut addObject: @""];
        } else {
            [valuesMut addObject: [NSString stringWithFormat: @"%d", _squad.cost]];
        }
        _values = [NSArray arrayWithArray: valuesMut];
    }
    return self;
}

-(CGFloat)draw
{
    [[UIColor blackColor] set];
    [_boundsPath stroke];

    int dividerCount = 2;
    CGFloat left = _bounds.origin.x;
    CGFloat rowHeight = _bounds.size.height / 2;
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
    
    CGFloat top = _bounds.origin.y;
    CGFloat bottom = top + _bounds.size.height;
    CGFloat colWidth = _bounds.size.width / _labels.count;
    CGFloat x = _bounds.origin.x + colWidth;
    int horizDividers = (int)_labels.count - 1;
    for (int i = 0; i < horizDividers; ++i) {
        UIBezierPath* p = [UIBezierPath bezierPath];
        [p moveToPoint: CGPointMake(x, top)];
        [p addLineToPoint: CGPointMake(x, bottom)];
        p.lineWidth = kGridDividerWidth;
        [p stroke];
        x += colWidth;
    }

    CGRect labelBox = CGRectMake(_bounds.origin.x, _bounds.origin.y, colWidth, rowHeight);
    //x = _bounds.origin.x;
    //y = _bounds.origin.y;
    DockTextBox* labelTextBox = [[DockTextBox alloc] initWithText: @""];
    labelTextBox.alignment = NSTextAlignmentCenter;
    labelBox.size.width = colWidth;
    for (int j = 0; j < _labels.count; ++j) {
        CGRect r = labelBox;
        for (int i = 0; i < 2; ++i) {
            if (i == 0) {
                labelTextBox.text = _labels[j];
                labelTextBox.font = [UIFont fontWithName: kLabelFont size: kTotalSPLabelFontSize];
                labelTextBox.centerVertically = YES;
            } else {
                labelTextBox.font = [UIFont fontWithName: kFieldFont size: 11];
                labelTextBox.text = _values[j];
                labelTextBox.centerVertically = NO;
            }
            
            [labelTextBox draw: labelBox];
            labelBox.origin.y += rowHeight;
        }
        labelBox = r;
        labelBox = CGRectOffset(labelBox, labelBox.size.width, 0);
    }
    
    return CGRectGetMaxY(_bounds);
}

@end

@interface DockResultsGrid : NSObject
@property (assign, nonatomic) CGRect bounds;
@property (strong, nonatomic) UIBezierPath* boundsPath;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSArray* labels;
@property (strong, nonatomic) NSArray* columnFractions;
@property (assign, nonatomic) BOOL numberRows;
-(id)initWithBounds:(CGRect)bounds;
@end

@implementation DockResultsGrid

-(id)initWithBounds:(CGRect)bounds
{
    self = [super init];
    if (self != nil) {
        _bounds = bounds;
        _boundsPath = [UIBezierPath bezierPathWithRect: bounds];
        _boundsPath.lineWidth = kDefaultLineWidth;
    }
    return self;
}

-(void)draw
{
    DockTextBox* box = [[DockTextBox alloc] initWithText: _title];
    box.alignment = NSTextAlignmentCenter;
    box.font = [UIFont fontWithName: kLabelFont size: kLabelFontSize];
    CGRect textBox = _bounds;
    textBox.origin.y -= 20;
    textBox.size.height = 20;
    [box draw: textBox];
    [[UIColor whiteColor] set];
    [_boundsPath fill];
    [[UIColor blackColor] set];
    [_boundsPath stroke];

    int dividerCount = 4;
    CGFloat left = _bounds.origin.x;
    CGFloat rowHeight = _bounds.size.height / 5;
    CGFloat right = left + _bounds.size.width;
    CGFloat y = _bounds.origin.y + rowHeight*2;
    [[UIColor lightGrayColor] set];
    for (int i = 0; i < dividerCount; ++i) {
        UIBezierPath* p = [UIBezierPath bezierPath];
        [p moveToPoint: CGPointMake(left, y)];
        [p addLineToPoint: CGPointMake(right, y)];
        p.lineWidth = kGridDividerWidth;
        [p stroke];
        y += rowHeight;
    }
    
    CGFloat top = _bounds.origin.y;
    CGFloat bottom = top + _bounds.size.height;
    CGFloat colWidth = _bounds.size.width * [_columnFractions[0] doubleValue];
    CGFloat x = _bounds.origin.x + colWidth;
    int horizDividers = (int)_labels.count - 1;
    for (int i = 0; i < horizDividers; ++i) {
        colWidth = _bounds.size.width * [_columnFractions[i+1] doubleValue];
        UIBezierPath* p = [UIBezierPath bezierPath];
        [p moveToPoint: CGPointMake(x, top)];
        [p addLineToPoint: CGPointMake(x, bottom)];
        p.lineWidth = kGridDividerWidth;
        [p stroke];
        x += colWidth;
    }

    x = _bounds.origin.x;
    y = _bounds.origin.y;
    DockTextBox* labelTextBox = [[DockTextBox alloc] initWithText: @""];
    labelTextBox.alignment = NSTextAlignmentCenter;
    labelTextBox.font = [UIFont fontWithName: kLabelFontNarrow size: 8];
    labelTextBox.centerVertically = YES;
    CGFloat margin = 0.05;
    for (int j = 0; j < _labels.count; ++j) {
        colWidth = _bounds.size.width * [_columnFractions[j] doubleValue];
        CGFloat offsetX = colWidth * margin;
        CGFloat textWidth = colWidth * (1.0 - margin*2);
        CGRect labelBox = CGRectMake(x + offsetX, y, textWidth, rowHeight*2);
        labelTextBox.text = _labels[j];
        [labelTextBox draw: labelBox];
        x += colWidth;
    }

    if (_numberRows) {
        labelTextBox.centerVertically = NO;
        y = _bounds.origin.y + rowHeight*2;
        x = _bounds.origin.x;
        colWidth = _bounds.size.width * [_columnFractions[0] doubleValue];
        CGFloat offsetX = colWidth * margin;
        CGFloat textWidth = colWidth * (1.0 - margin*2);
        labelTextBox.font = [UIFont fontWithName: kLabelFontNarrow size: kLabelFontSize];
        for (int j = 0; j < 3; ++j) {
            CGRect labelBox = CGRectMake(x + offsetX, y, textWidth, rowHeight*2);
            labelTextBox.text = [NSString stringWithFormat: @"%d", j+1];
            [labelTextBox draw: labelBox];
            y += rowHeight;
        }
    }
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
        _event = @"";
        _name = @"";
        _date = [NSDate date];
        _faction = @"";
        _email = @"";
    }
    return self;
}

- (CGRect)drawShipGrids:(CGFloat)fieldWidth gridTop:(CGFloat)gridTop left:(CGFloat)left right:(CGFloat)right center:(CGFloat)center
{
    int startIndex = 0;
    int endIndex = 4;
    if (_pageIndex > 0) {
        startIndex += endIndex;
        endIndex += endIndex;
        endIndex += 2;
    }
    CGFloat gridWith = fieldWidth - 5 * kDefaultMargin;
    NSOrderedSet* ships = _targetSquad.equippedShips;
    NSInteger shipCount = ships.count;
    DockEquippedShip* ship = nil;
    CGFloat x, y, minX, maxX;
    for (int i = startIndex; i < endIndex; ++i) {
        if (i < shipCount) {
            ship = [ships objectAtIndex: i];
        } else {
            ship = nil;
        }
        switch(i - startIndex) {
            case 0:
                minX = x = left + center - gridWith - 2*kDefaultMargin;
                y = gridTop;
                break;
            case 1:
                x = right - gridWith - 2*kDefaultMargin;
                y = gridTop;
                maxX = x + gridWith;
                break;
            case 2:
                x = left + center - gridWith - 2*kDefaultMargin;
                y = gridTop + kShipGridHeight + 16;
                break;
            case 3:
                x = right - gridWith - 2*kDefaultMargin;
                y = gridTop + kShipGridHeight + 16;
                break;
            case 4:
                x = left + center - gridWith - 2*kDefaultMargin;
                y = gridTop + kShipGridHeight*2 + 32;
                break;
            case 5:
            default:
                x = right - gridWith - 2*kDefaultMargin;
                y = gridTop + kShipGridHeight*2 + 32;
                break;
        }
        CGRect gridBox = CGRectMake(x, y, gridWith, kShipGridHeight);
        DockShipGrid* grid = [[DockShipGrid alloc] initWithBounds: gridBox ship: ship];
        [grid draw];
    }
    
    return CGRectMake(minX, y + kShipGridHeight, maxX - minX, 0);
}

- (CGFloat)drawFields:(CGRect)fieldBox fields:(NSArray *)fields
{
    for (NSArray* parts in fields) {
        DockLabeledField* field = [[DockLabeledField alloc] initWithLabel: parts[0]
                                                                     text: parts[1]];
        [field draw: fieldBox];
        fieldBox = CGRectOffset(fieldBox, 0, fieldBox.size.height + kDefaultMargin);
    }
    return fieldBox.origin.y + fieldBox.size.height;
}

static float heightForStringDrawing(NSString *targetString, UIFont *targetFont, float targetWidth)
{
    NSMutableParagraphStyle* centered = [[NSMutableParagraphStyle alloc] init];
    centered.alignment = NSTextAlignmentLeft;
    NSDictionary* attributes = @{
                    NSParagraphStyleAttributeName: centered,
                    NSFontAttributeName: targetFont
                    };
    NSStringDrawingContext* context = [[NSStringDrawingContext alloc] init];
    CGRect bounds = [targetString boundingRectWithSize: CGSizeMake(targetWidth, FLT_MAX)
                                             options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin
                                          attributes: attributes
                                             context: context];
    return bounds.size.height;
}

static CGFloat fontSizeForText(CGSize frameSize, UIFont* originalFont, NSString* targetText)
{
    const CGFloat kMaxFontSize = 11;
    const CGFloat kMinFontSize = 6;

    if (targetText == nil) {
        return kMaxFontSize;
    }
    float fontSize = kMaxFontSize;
    CGFloat targetHeight = frameSize.height;
    CGFloat notesHeight = FLT_MAX;
    while (fontSize > kMinFontSize)
    {
        UIFont* newFont = [UIFont fontWithName: [originalFont fontName] size: fontSize];
        notesHeight = heightForStringDrawing(targetText, newFont, frameSize.width);
        if (notesHeight < targetHeight) {
            break;
        }
        fontSize--;
    }
    
    return fontSize;
}

- (CGFloat)drawNotes:(CGRect)fieldBox
{
    NSString* notes = _targetSquad.notes;
    DockTextBox* notesBox = [[DockTextBox alloc] initWithText: notes];
    notesBox.frame = YES;
    UIFont* fieldFont = [UIFont fontWithName: kFieldFont size: 11];
    notesBox.font = [UIFont fontWithName: kFieldFont size: fontSizeForText(fieldBox.size, fieldFont, notes)];
    
    [notesBox draw: fieldBox];
    return CGRectGetMaxY(fieldBox);
}

-(NSString*)resourceCost
{
    return resourceCost(_targetSquad);
}

-(NSString*)otherCost
{
    return otherCost(_targetSquad);
}

-(NSString*)resourceTitle
{
    DockResource* res = _targetSquad.resource;
    if (res) {
        if ([res isFlagship]) {
            DockFlagship* flagship = _targetSquad.flagship;
            return [flagship plainDescription];
        }
        return res.title;
    }
    return @"";
}

- (CGFloat)drawResources:(CGRect)fieldBox shipGridBox:(CGRect)shipGridBox
{
    DockLabeledField* field = [[DockLabeledField alloc] initWithLabel: @"Resource Used:"
                                                                 text: [self resourceTitle]];
    
    CGFloat resourceNameFraction = 0.85;
    
    fieldBox.size.width *= resourceNameFraction;
    fieldBox.size.height = kFieldHeight;
    [field draw: fieldBox];
    
    fieldBox.origin.x += fieldBox.size.width;
    fieldBox.size.width = shipGridBox.size.width * (1-resourceNameFraction);
    field = [[DockLabeledField alloc] initWithLabel: @"SP" text: [self resourceCost]];
    field.labelFraction = 0.6;
    field.textAlignment = NSTextAlignmentCenter;
    [field draw: fieldBox];
    return CGRectGetMaxY(fieldBox);
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
    if (!_lightHeader) {
        [blackBoxPath fill];
    } else {
        [blackBoxPath stroke];
    }
    
    NSString* fbs = @"Fleet Build Sheet";
    if (_pageIndex > 0) {
        fbs = @"Fleet Build Sheet (cont)";
    }
    DockTextBox* box = [[DockTextBox alloc] initWithText: fbs];
    if (!_lightHeader) {
        box.color = [UIColor whiteColor];
    }
    box.alignment = NSTextAlignmentCenter;
    box.font = [UIFont fontWithName: kLabelFont size:25.0];
    box.centerVertically = YES;
    CGRect b = CGRectInset(blackBox, kDefaultMargin, kDefaultMargin);
    [box draw: b];
    
    CGFloat halfWidth = targetBounds.size.width/2;
    CGFloat fieldWidth = halfWidth - 3 * kDefaultMargin;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString* eventDateString = [dateFormatter stringFromDate: _date];

    NSArray* leftFields = @[
        @[@"Date:", eventDateString],
        @[@"Event:", _event],
        @[@"Faction:", _faction],
    ];

    CGFloat fieldsTop = top + blackBox.size.height;
    CGRect fieldBox = CGRectMake(left + kDefaultMargin, fieldsTop,
                                     fieldWidth,  kFieldHeight);
    CGFloat fieldBottom = [self drawFields:fieldBox fields: leftFields];

    NSArray* rightFields = @[
        @[@"Name:", _name],
        @[@"Email:", _email],
    ];
    
    fieldBox = CGRectMake(left + halfWidth + kDefaultMargin, fieldsTop,
                                     fieldWidth,  kFieldHeight);
    [self drawFields:fieldBox fields: rightFields];
    
    CGRect shipGridBox = [self drawShipGrids:fieldWidth gridTop:fieldBottom left:left right:right center:halfWidth];
    
    if (_pageIndex == 0) {
        fieldBox = CGRectMake(shipGridBox.origin.x, shipGridBox.origin.y + kDefaultMargin,
                                         shipGridBox.size.width, 40);
        CGFloat notesBottom = [self drawNotes:fieldBox];

        CGRect resourceBox = CGRectMake(shipGridBox.origin.x, notesBottom + kDefaultMargin,
                                         shipGridBox.size.width, 40);
        CGFloat resourcesBottom = [self drawResources:resourceBox shipGridBox:shipGridBox];

        CGRect costBox = CGRectMake(shipGridBox.origin.x, resourcesBottom + kDefaultMargin*3,
                                         shipGridBox.size.width, 40);
        DockCostGrid* costGrid = [[DockCostGrid alloc] initWithBounds: costBox squad: _targetSquad blind:_blindbuy];
        CGFloat costBottom = [costGrid draw];
        
        costBottom += (kDefaultMargin * 2);
        
        CGRect resultsBox = targetBounds;
        resultsBox.origin.y = costBottom;
        resultsBox.size.height-= costBottom;
        [self drawResultGrids: resultsBox];
    }
}

- (void)drawResultGrids:(CGRect)resultsBox
{
    [[UIColor lightGrayColor] set];
    UIBezierPath* resultsBoxPath = [UIBezierPath bezierPathWithRect: resultsBox];
    [resultsBoxPath fill];
    CGFloat left = resultsBox.origin.x + kDefaultMargin;
    CGFloat center = resultsBox.origin.x + resultsBox.size.width / 2;
    CGFloat right = center - kDefaultMargin;
    CGFloat top = resultsBox.origin.y + kDefaultMargin + 3 * kDefaultMargin;
    CGFloat bottom = CGRectGetMaxY(resultsBox) - kDefaultMargin*3.5;
    
    CGRect beforeRect = CGRectMake(left, top,
                                     right - left, bottom - top);
    DockResultsGrid* beforeGrid = [[DockResultsGrid alloc] initWithBounds: beforeRect];
    beforeGrid.title = @"Before Battle Starts:";
    beforeGrid.labels = @[@"Battle Round", @"Opponent's Name", @"Opponent's Initials (Verify Build)"];
    beforeGrid.columnFractions = @[@0.15, @0.65, @0.2];
    beforeGrid.numberRows = YES;
    [beforeGrid draw];

    left = center + kDefaultMargin;
    right = CGRectGetMaxX(resultsBox) - kDefaultMargin;
    CGRect afterRect = CGRectMake(left, top, right - left, bottom - top);
    DockResultsGrid* afterGrid = [[DockResultsGrid alloc] initWithBounds: afterRect];
    afterGrid.title = @"After Battle Ends:";
    afterGrid.labels = @[@"Your Result (W-L-B)", @"Your Fleet Points", @"Cumulative Fleet Points", @"Opponent's Initials (Verify Results)"];
    afterGrid.columnFractions = @[@0.25, @0.25, @0.25, @0.25];
    [afterGrid draw];
    
    NSString* pbsd = @"Printed by Space Dock - www.spacedockapp.org";
    DockTextBox* box = [[DockTextBox alloc] initWithText: pbsd];
    box.color = [UIColor whiteColor];
    box.alignment = NSTextAlignmentCenter;
    box.font = [UIFont fontWithName: kLabelFont size:9.0];
    box.centerVertically = YES;
    CGRect adBox = CGRectMake(resultsBox.origin.x, bottom, resultsBox.size.width, CGRectGetMaxY(resultsBox) - bottom);
    [box draw: adBox];
}

@end
