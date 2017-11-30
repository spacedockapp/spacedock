#import "DockFleetBuildSheet.h"

#import "DockCaptain+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockFlagship+Addons.h"
#import "DockUpgrade+Addons.h"
#import "DockResource+Addons.h"
#import "DockSetItem+Addons.h"
#import "DockSquad+Addons.h"
#import "DockUtils.h"

@interface DockTwoPageSheet : NSView {
    NSRect _pageBounds;
}
-(id)initWithFrame:(NSRect)frameRect pageBounds:(NSRect)pageBounds;
@end

@implementation DockTwoPageSheet

-(id)initWithFrame:(NSRect)frameRect pageBounds:(NSRect)pageBounds
{
    self = [super initWithFrame: frameRect];
    if (self != nil) {
        _pageBounds = pageBounds;
    }
    return self;
}

- (BOOL)knowsPageRange:(NSRangePointer)range
{
    range->location = 1;
    range->length = 2;
    return YES;
}

- (NSRect)rectForPage:(NSInteger)page
{
    NSRect bounds = [self bounds];
    float pageHeight = [self calculatePrintHeight];
    return NSMakeRect( NSMinX(bounds), NSMaxY(bounds) - page * pageHeight,
                      NSWidth(bounds), pageHeight );
}

- (float)calculatePrintHeight
{
    return _pageBounds.size.height;
}

@end

@interface DockFleetBuildSheetShip : NSObject <NSTableViewDataSource,NSTableViewDelegate>
@property (nonatomic, strong) NSArray* topLevelObjects;
@property (nonatomic, strong) IBOutlet NSView* gridContainer;
@property (nonatomic, strong) IBOutlet NSTableView* shipGrid;
@property (nonatomic, strong) IBOutlet NSTextField* totalSP;
@property (nonatomic, strong) DockEquippedShip* equippedShip;
@property (nonatomic, strong) NSMutableArray* upgrades;
@property (nonatomic, assign) int extraRows;
@property (nonatomic, assign) double fontSize;
@property (nonatomic, assign) BOOL usesBlindBoosters;
@end

const int kExtraRows = 3;

@implementation DockFleetBuildSheetShip

-(id)init
{
    self = [super init];
    if (self != nil) {
        self.fontSize = 7;
    }
    return self;
}

-(void)setEquippedShip:(DockEquippedShip *)equippedShip
{
    _equippedShip = equippedShip;
    _extraRows = kExtraRows;
    if (_equippedShip.flagship) {
        _extraRows += 1;
    } else if (_equippedShip.isFighterSquadron) {
        _extraRows -= 1;
    }

    if (_equippedShip) {
        NSArray* equippedUpgrades = equippedShip.sortedUpgrades;
        _upgrades = [[NSMutableArray alloc] initWithCapacity: equippedUpgrades.count];

        for (DockEquippedUpgrade* upgrade in equippedUpgrades) {
            if (![upgrade isPlaceholder] && [upgrade.upgrade isCaptain] && [upgrade.specialTag isEqualToString:@"AdditionalCaptain"]) {
                [_upgrades addObject: upgrade];
            }
            if (![upgrade isPlaceholder] && ![upgrade.upgrade isCaptain]) {
                [_upgrades addObject: upgrade];
            }
        }
    } else {
        _upgrades = nil;
    }
    int cost = _equippedShip.cost;
    if (cost > 0) {
        [_totalSP setIntValue: cost];
    }
    [_shipGrid reloadData];
    int linesCount = (int)_upgrades.count + _extraRows;
    if (linesCount > 15) {
        self.fontSize = 3.5;
        self.shipGrid.rowHeight = 7;
    } else if (linesCount > 10) {
        self.fontSize = 5;
        self.shipGrid.rowHeight = 8;
    } else if (_upgrades.count == 0 && self.usesBlindBoosters) {
        self.shipGrid.rowHeight = 15;
    } else {
        self.fontSize = 7;
        self.shipGrid.rowHeight = 11;
    }
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if (_upgrades) {
        return _upgrades.count + _extraRows;
    }
    return 1;
}

NSAttributedString* headerText(NSString* string)
{
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSCenterTextAlignment];
    NSDictionary* attributes = @{
                                 NSFontAttributeName: [NSFont userFontOfSize: 7],
                                 NSParagraphStyleAttributeName: paragraphStyle
                                 };
    return [[NSAttributedString alloc] initWithString: string attributes: attributes];
}

-(id)handleHeader:(NSString*)identifier
{
    if ([identifier isEqualToString: @"type"]) {
        return headerText(@"Type");
    }

    if ([identifier isEqualToString: @"faction"]) {
        return headerText(@"Faction");
    }

    if ([identifier isEqualToString: @"sp"]) {
        return headerText(@"SP");
    }
    
    return headerText(@"Card Title");
}

-(id)handleShip:(NSString*)identifier
{
    if ([identifier isEqualToString: @"type"]) {
        return @"Ship";
    }

    if ([identifier isEqualToString: @"faction"]) {
        return [_equippedShip factionCode];
    }

    if ([identifier isEqualToString: @"sp"]) {
        return [NSNumber numberWithInt: [_equippedShip baseCost]];
    }
    
    return [_equippedShip descriptiveTitleWithSet];
}

-(id)handleFlagship:(NSString*)identifier
{
    if ([identifier isEqualToString: @"type"]) {
        return @"Flag";
    }
    
    DockFlagship* fs = _equippedShip.flagship;
    
    if ([identifier isEqualToString: @"faction"]) {
        return [fs factionCode];
    }

    if ([identifier isEqualToString: @"sp"]) {
        return _equippedShip.squad.resource.cost;
    }
    
    return [fs name];
}

-(id)handleCaptain:(NSString*)identifier
{
    if ([identifier isEqualToString: @"type"]) {
        return @"Cap";
    }

    DockEquippedUpgrade* equippedCaptain = [_equippedShip equippedCaptain];
    DockCaptain* captain = (DockCaptain*)[equippedCaptain upgrade];

    if ([identifier isEqualToString: @"faction"]) {
        return [captain factionCode];
    }

    if ([identifier isEqualToString: @"sp"]) {
        return costString(equippedCaptain);
    }
    

    return [equippedCaptain descriptionForBuildSheet];
}

-(id)handleUpgrade:(NSString*)identifier index:(long)index
{
    if (index < _upgrades.count) {
        DockEquippedUpgrade* equippedUpgrade = _upgrades[index];
        if ([identifier isEqualToString: @"type"]) {
            return equippedUpgrade.upgrade.typeCode;
        }
        if ([identifier isEqualToString: @"faction"]) {
            if ([equippedUpgrade.specialTag hasPrefix:@"Quark"]) {
                return @"";
            }
            return equippedUpgrade.upgrade.factionCode;
        }

        if ([identifier isEqualToString: @"sp"]) {
            if ([[equippedUpgrade descriptionForBuildSheet] isEqualToString:@"Federation Elite Talent"] || [[equippedUpgrade descriptionForBuildSheet] isEqualToString:@"Romulan Elite Talent"] || [[equippedUpgrade descriptionForBuildSheet] isEqualToString:@"Tech Upgrade"] || [[equippedUpgrade descriptionForBuildSheet] isEqualToString:@"Weapon Upgrade"] || [[equippedUpgrade descriptionForBuildSheet] isEqualToString:@"Klingon Elite Talent"]) {
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

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    switch (row) {
        case 0:
            return [self handleHeader: tableColumn.identifier];
            
        case 1:
            return [self handleShip: tableColumn.identifier];
            
        case 2:
            if (_extraRows == 4) {
                return [self handleFlagship: tableColumn.identifier];
            }
            return [self handleCaptain: tableColumn.identifier];
            
        case 3:
            if (_extraRows == 4) {
                return [self handleCaptain: tableColumn.identifier];
            }
            return [self handleUpgrade: tableColumn.identifier index: row - _extraRows];
            
        default:
            return [self handleUpgrade: tableColumn.identifier index: row - _extraRows];
    }
    return nil;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    if (row == 0) {
        return 11;
    }
    return tableView.rowHeight;
}

@end

@interface DockFleetBuildSheet () <NSTableViewDataSource> {
    NSMutableArray* _shipDataList;
    NSNumber* _squadTotalCost;
    NSString* _date;
    NSDictionary* _dataForResource;
    NSMutableArray* _buildShips;
}
@property (strong, nonatomic) IBOutlet NSWindow* mainWindow;
@property (strong, nonatomic) IBOutlet NSWindow* fleetBuildDetails;
@property (strong, nonatomic) IBOutlet NSBox* sheetBox;
@property (strong, nonatomic) IBOutlet NSBox* sheetBox2;
@property (strong, nonatomic) IBOutlet NSView* box1;
@property (strong, nonatomic) IBOutlet NSView* box2;
@property (strong, nonatomic) IBOutlet NSView* box3;
@property (strong, nonatomic) IBOutlet NSView* box4;
@property (strong, nonatomic) IBOutlet NSView* box5;
@property (strong, nonatomic) IBOutlet NSView* box6;
@property (strong, nonatomic) IBOutlet NSView* box7;
@property (strong, nonatomic) IBOutlet NSView* box8;
@property (strong, nonatomic) IBOutlet NSView* box9;
@property (strong, nonatomic) IBOutlet NSView* box10;
@property (strong, nonatomic) IBOutlet NSTextField* resourceTitleField;
@property (strong, nonatomic) IBOutlet NSTextField* resourceCostField;
@property (strong, nonatomic) IBOutlet NSTextField* nameField;
@property (strong, nonatomic) IBOutlet NSTextField* notesField;
@property (nonatomic, strong) NSString* notes;
@property (strong, nonatomic) DockSquad* targetSquad;
@end

@implementation DockFleetBuildSheet

+(NSSet*)keyPathsForValuesAffectingNotesFontSize
{
    return [NSSet setWithObjects: @"notes", nil];
}


-(void)awakeFromNib
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    self.name = [defaults stringForKey: @"name"];
    self.eventName = [defaults stringForKey: @"eventName"];
    self.email = [defaults stringForKey: @"email"];
    self.faction = [defaults stringForKey: @"faction"];
    self.usesBlindBoosters = [defaults boolForKey: @"usesBlindBoosters"];

    self.eventDate = [NSDate date];
    _buildShips = [[NSMutableArray alloc] init];
    NSArray* views = @[_box1, _box2, _box3, _box4, _box5, _box6, _box7, _box8, _box9, _box10];
    NSBundle* mainBundle = [NSBundle mainBundle];
    for (int i = 0; i < views.count; ++i) {
        DockFleetBuildSheetShip* ship = [[DockFleetBuildSheetShip alloc] init];
        NSArray* a;
        [mainBundle loadNibNamed: @"ShipGrid" owner: ship topLevelObjects: &a];
        ship.topLevelObjects = a;
        NSView* view = views[i];
        [ship.gridContainer setFrameSize: view.frame.size];
        [view addSubview: ship.gridContainer];
        [_buildShips addObject: ship];
        ship.usesBlindBoosters = self.usesBlindBoosters;
    }
    
}

static float heightForStringDrawing(NSString *targetString, NSFont *targetFont, float targetWidth)
{
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString: targetString];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize: NSMakeSize(targetWidth, FLT_MAX)];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    
 	[layoutManager addTextContainer:textContainer];
	[textStorage addLayoutManager:layoutManager];
    
    [textStorage addAttribute:NSFontAttributeName value:targetFont range:NSMakeRange(0, [textStorage length])];
    [textContainer setLineFragmentPadding:0.0];
    
    [layoutManager glyphRangeForTextContainer:textContainer];
    return [layoutManager usedRectForTextContainer:textContainer].size.height;
}

-(CGFloat)notesFontSize
{
    const CGFloat kMaxFontSize = 13.0;
    const CGFloat kMinFontSize = 6;

    NSString* notes = self.notes;
    if (notes == nil) {
        return kMaxFontSize;
    }
    float fontSize = kMaxFontSize;
    NSSize frameSize = [_notesField frame].size;
    CGFloat targetHeight = frameSize.height - 10;
    NSFont* originalFont = _notesField.font;
    CGFloat notesHeight = FLT_MAX;
    while (fontSize > kMinFontSize)
    {
        NSFont* newFont = [NSFont fontWithName: [originalFont fontName] size: fontSize];
        notesHeight = heightForStringDrawing(notes, newFont, frameSize.width);
        if (notesHeight < targetHeight) {
            break;
        }
        fontSize--;
    }
    
    return fontSize;
}

-(void)print
{
    NSOrderedSet* equippedShips = _targetSquad.equippedShips;
    NSUInteger shipCount = equippedShips.count;
    for (int i = 0; i < 10; ++i) {
        DockEquippedShip* equippedShip = nil;
        if (i < shipCount) {
            equippedShip = equippedShips[i];
        }
        DockFleetBuildSheetShip* buildSheetShip = _buildShips[i];
        buildSheetShip.equippedShip = equippedShip;
        buildSheetShip.usesBlindBoosters = self.usesBlindBoosters;
    }
    
    [_resourceTitleField setStringValue: [self resourceTile]];
    [_resourceCostField setStringValue: [self resourceCost]];
    
    self.notes = _targetSquad.notes;

    NSPrintInfo* info = [NSPrintInfo sharedPrintInfo];
    info.leftMargin = 0;
    info.rightMargin = 0;
    info.topMargin = 0;
    info.bottomMargin = 0;
    NSMutableDictionary* dict = [info dictionary];
    dict[NSPrintHorizontalPagination] = [NSNumber numberWithInt: shipCount > 4 ? NSAutoPagination : NSFitPagination];
    dict[NSPrintVerticalPagination] = [NSNumber numberWithInt: NSFitPagination];
    dict[NSPrintHorizontallyCentered] = [NSNumber numberWithBool: YES];
    dict[NSPrintVerticallyCentered] = [NSNumber numberWithBool: YES];
    dict[NSPrintOrientation] = [NSNumber numberWithInt: NSPortraitOrientation];
    NSRect r = [info imageablePageBounds];
    [_sheetBox setFrameSize: r.size];
    if (shipCount > 4) {
        NSRect twoPageBounds = NSMakeRect(0, 0, r.size.width, 2*r.size.height);
        [_sheetBox2 setFrameSize: r.size];
        NSView* twoPageView = [[DockTwoPageSheet alloc] initWithFrame: twoPageBounds pageBounds: r];
        [twoPageView addSubview: _sheetBox];
        [twoPageView addSubview: _sheetBox2];
        [_sheetBox setFrameOrigin: NSMakePoint(0, r.size.height)];
        [[NSPrintOperation printOperationWithView: twoPageView] runOperation];
    } else {
        [[NSPrintOperation printOperationWithView: _sheetBox] runOperation];
    }
}

-(NSString*)shipCost:(int)index
{
    NSOrderedSet* equippedShips = _targetSquad.equippedShips;
    if (index < equippedShips.count) {
        DockEquippedShip* equippedShip = equippedShips[index];
        int cost = equippedShip.cost;
        if (cost == 0) {
            return @"";
        }
        return [NSString stringWithFormat: @"%d", equippedShip.cost];
    }
    return @"";
}

-(NSString*)resourceCost
{
    return resourceCost(_targetSquad);
}

-(NSString*)otherCost
{
    return otherCost(_targetSquad);
}

-(NSString*)resourceTile
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

-(id)beforeValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString* identifier = tableColumn.identifier;
    if (row == 0) {
        NSDictionary* labels = @{
            @"round" : @"Battle Round",
            @"name" : @"Opponent's Name",
            @"initials" : @"Opponent's\nInitials\n(Verify Build)"
        };
        return headerText(labels[identifier]);
    }
    
    if ([identifier isEqualToString: @"round"]) {
        return [NSString stringWithFormat: @"%ld", (long)row];
    }
    return @"";
}

-(id)endValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (row == 0) {
        NSDictionary* labels = @{
            @"result" : @"Your Result\n(W-L-B)",
            @"fp" : @"Your\nFleet Points",
            @"cfp" : @"Cumulative\nFleet Points",
            @"initials" : @"Opponent's\nInitials\n(Verify Results)"
        };
        return headerText(labels[tableColumn.identifier]);
    }
    return @"";
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString* identifier = tableView.identifier;
    
    if ([identifier isEqualToString: @"before"]) {
        return [self beforeValueForTableColumn: tableColumn row:row];
    }

    if ([identifier isEqualToString: @"end"]) {
        return [self endValueForTableColumn: tableColumn row:row];
    }

    NSString* columnIdentifier = tableColumn.identifier;
    int index = [columnIdentifier intValue];
    switch(index) {
    case 0:
    case 1:
    case 2:
    case 3:
        return [self shipCost: index];
    case 4:
        return [self resourceCost];
    case 5:
        return [self otherCost];
        
    }

    if (self.usesBlindBoosters) {
        return @"";
    }

    return [NSNumber numberWithInt: _targetSquad.cost];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSString* identifier = tableView.identifier;
    if ([identifier isEqualToString: @"before"] || [identifier isEqualToString: @"end"]) {
        return 4;
    }
    return 1;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    if (row == 0) {
        return tableView.rowHeight*2;
    }
    return tableView.rowHeight;
}

-(void)sheetDidEnd:(NSWindow*)sheet returnCode:(NSInteger)returnCode contextInfo:(void*)contextInfo
{
    [_fleetBuildDetails orderOut: nil];
}

-(void)show:(DockSquad*)targetSquad
{
    _targetSquad = targetSquad;
    [NSApp beginSheet: _fleetBuildDetails modalForWindow: _mainWindow modalDelegate: self didEndSelector: @selector(sheetDidEnd:returnCode:contextInfo:) contextInfo: nil];
}

-(IBAction)cancel:(id)sender
{
    [NSApp endSheet: _fleetBuildDetails];
}

-(IBAction)print:(id)sender
{
    [_fleetBuildDetails endEditingFor: sender];
    [NSApp endSheet: _fleetBuildDetails];
    [self print];
}

-(void)setEventDate:(NSDate *)eventDate
{
    _eventDate = eventDate;
    [self willChangeValueForKey: @"eventDateString"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    _eventDateString = [dateFormatter stringFromDate: eventDate];
    [self didChangeValueForKey: @"eventDateString"];
}

-(void)setEventName:(NSString *)eventName
{
    [self willChangeValueForKey: @"eventName"];
    _eventName = eventName;
    [[NSUserDefaults standardUserDefaults] setObject: _eventName forKey: @"eventName"];
    [self didChangeValueForKey: @"eventName"];
}

-(void)setFaction:(NSString *)faction
{
    [self willChangeValueForKey: @"faction"];
    _faction = faction;
    [[NSUserDefaults standardUserDefaults] setObject: _faction forKey: @"faction"];
    [self didChangeValueForKey: @"faction"];
}

-(void)setEmail:(NSString *)email
{
    [self willChangeValueForKey: @"email"];
    _email = email;
    [[NSUserDefaults standardUserDefaults] setObject: _email forKey: @"email"];
    [self didChangeValueForKey: @"email"];
}

-(void)setName:(NSString *)name
{
    [self willChangeValueForKey: @"name"];
    _name = name;
    [[NSUserDefaults standardUserDefaults] setObject: _name forKey: @"name"];
    [self didChangeValueForKey: @"name"];
}

-(void)setUsesBlindBoosters:(BOOL)usesBlindBoosters
{
    [self willChangeValueForKey: @"usesBlindBoosters"];
    _usesBlindBoosters = usesBlindBoosters;
    [[NSUserDefaults standardUserDefaults] setBool: usesBlindBoosters forKey: @"usesBlindBoosters"];
    [self didChangeValueForKey: @"usesBlindBoosters"];
}

@end
