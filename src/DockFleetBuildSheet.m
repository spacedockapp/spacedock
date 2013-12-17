#import "DockFleetBuildSheet.h"

#import "DockCaptain+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockResource+Addons.h"
#import "DockShip+Addons.h"
#import "DockSquad+Addons.h"
#import "DockUpgrade+Addons.h"

#import "GRMustache.h"

@interface DockFleetBuildSheet ()
@property (weak, nonatomic) DockSquad* targetSquad;
@end

@implementation DockFleetBuildSheet

static NSDictionary* dataForUpgrade(DockEquippedUpgrade* theUpgrade)
{
    DockUpgrade* upgrade = theUpgrade.upgrade;
    return @{
               @"title": [upgrade title],
               @"faction": [upgrade factionCode],
               @"upType": [upgrade typeCode],
               @"cost": [NSNumber numberWithInt: [theUpgrade cost]]
    };
}

static NSDictionary* dataForResource(DockResource* theResource)
{
    if (theResource == nil) {
        return nil;
    }

    return @{
               @"title": theResource.title, @"cost": theResource.cost
    };
}

-(NSDictionary*)printableData:(DockEquippedShip*)theShip index:(int)index upgradeCount:(NSInteger)upgradeCount
{
    NSArray* equippedUpgrades = theShip.sortedUpgrades;
    NSMutableArray* upgrades = [[NSMutableArray alloc] initWithCapacity: equippedUpgrades.count];

    for (DockEquippedUpgrade* upgrade in equippedUpgrades) {
        if (![upgrade isPlaceholder] && ![upgrade.upgrade isCaptain]) {
            [upgrades addObject: dataForUpgrade(upgrade)];
        }
    }
    id blank = @{
        @"title": @" ",
        @"faction": @" ",
        @"upType": @" ",
        @"cost": @" "
    };

    while (upgrades.count < upgradeCount) {
        [upgrades addObject: blank];
    }
    return @{
               @"sideboard": [NSNumber numberWithBool: [theShip isResourceSideboard]],
               @"index": [NSNumber numberWithInt: index],
               @"title": [theShip plainDescription],
               @"faction": [theShip factionCode],
               @"cost": [NSNumber numberWithInt: [theShip baseCost]],
               @"captain" : dataForUpgrade(theShip.equippedCaptain),
               @"upgrades" : upgrades,
               @"totalCost": [NSNumber numberWithInt: [theShip cost]]
    };
}

-(void)updateWebView:(WebView*)webview forTargetSquad:(DockSquad*)targetSquad
{
    NSMutableDictionary* squadData = [[NSMutableDictionary alloc] initWithCapacity: 0];
    NSArray* equippedShips = [[targetSquad equippedShips] array];
    NSInteger shipCount = equippedShips.count;
    NSMutableArray* ships = [[NSMutableArray alloc] initWithCapacity: 3];
    squadData[@"ships"] = ships;
    squadData[@"squadTotalCost"] = [NSNumber numberWithInt: targetSquad.cost];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle: NSDateFormatterNoStyle];
    [formatter setDateStyle: NSDateFormatterShortStyle];

    squadData[@"date"] = [formatter stringFromDate: [NSDate date]];
    NSDictionary* resourceData = dataForResource(targetSquad.resource);

    if (resourceData != nil) {
        squadData[@"resource"] = resourceData;
    }

    NSMutableArray* list = [[NSMutableArray alloc] initWithCapacity: 2];
    NSInteger upgradeCount = -1;

    for (DockEquippedShip* ship in equippedShips) {
        NSInteger current = [ship upgradeCount];

        if (current > upgradeCount) {
            upgradeCount = current;
        }
    }

    for (int i = 0; i < 6; i += 1) {
        NSDictionary* shipData;

        if (i < shipCount) {
            shipData = [self printableData: equippedShips[i] index: i + 1 upgradeCount: upgradeCount];
        } else {
            shipData = @{};
        }

        [list addObject: shipData];

        if (i % 2 == 1) {
            [ships addObject: @{ @"list": list }
            ];
            list = [[NSMutableArray alloc] initWithCapacity: 2];
        }
    }
    NSURL* url = [NSURL URLWithString: @"http://sample.com"];
    NSString* rendering = [GRMustacheTemplate renderObject: squadData
                                              fromResource: @"fleet"
                                                    bundle: nil
                                                     error: NULL];

    [[webview mainFrame] loadHTMLString: rendering baseURL: url];
}

-(void)sheetDidEnd:(NSWindow*)sheet returnCode:(NSInteger)returnCode contextInfo:(void*)contextInfo
{
    [_fleetBuildWindow orderOut: nil];
}

-(void)show:(DockSquad*)targetSquad
{
    _targetSquad = targetSquad;
    [self updateWebView: _webView forTargetSquad: targetSquad];
    [NSApp beginSheet: _fleetBuildWindow modalForWindow: _mainWindow modalDelegate: self didEndSelector: @selector(sheetDidEnd:returnCode:contextInfo:) contextInfo: nil];
}

-(IBAction)cancel:(id)sender
{
    [NSApp endSheet: _fleetBuildWindow];
}

//  WebView has completed loading, so it can be printed now.
- (void) webView: (WebView *) printView didFinishLoadForFrame: (WebFrame *)frame
{
    [printView print: nil];
    [self cancel: nil];
}

-(IBAction)print:(id)sender
{
    NSPrintInfo* info = [NSPrintInfo sharedPrintInfo];
    NSMutableDictionary* dict = [info dictionary];
    dict[NSPrintHorizontallyCentered] = [NSNumber numberWithBool: YES];
    dict[NSPrintVerticallyCentered] = [NSNumber numberWithBool: NO];
    dict[NSPrintHorizontalPagination] = [NSNumber numberWithInt: NSFitPagination];
    dict[NSPrintVerticalPagination] = [NSNumber numberWithInt: NSFitPagination];

    NSSize paperSize = [info paperSize];
    NSRect frame = NSMakeRect(0, 0, paperSize.width - info.leftMargin - info.rightMargin, paperSize.height - info.topMargin - info.bottomMargin);
    WebView* webView = [[WebView alloc] initWithFrame: frame];
    [[[webView mainFrame] frameView] setAllowsScrolling:NO];
    [webView setShouldUpdateWhileOffscreen: YES];
    [webView setFrameLoadDelegate: self];
    [self updateWebView: webView forTargetSquad: _targetSquad];
    [[webView preferences] setShouldPrintBackgrounds: YES];
}

@end
