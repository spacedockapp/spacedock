#import "DockFleetBuildSheet.h"

#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockShip+Addons.h"
#import "DockCaptain+Addons.h"
#import "DockResource+Addons.h"
#import "DockSquad+Addons.h"
#import "DockUpgrade+Addons.h"

#import "GRMustache.h"

@implementation DockFleetBuildSheet

static NSDictionary* dataForUpgrade(DockEquippedUpgrade* theUpgrade)
{
    DockUpgrade * upgrade = theUpgrade.upgrade;
    return @{
        @"title": [upgrade title],
        @"faction": [upgrade factionCode],
        @"upType": [upgrade typeCode],
        @"cost": [NSNumber numberWithInt: [theUpgrade cost]]};
}

static NSDictionary* dataForResource(DockResource* theResource)
{
    if (theResource == nil) {
        return nil;
    }

    return @{@"title": theResource.title, @"cost": theResource.cost};
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
        @"index": [NSNumber numberWithInt: index],
        @"title": [theShip title],
        @"faction": [theShip.ship factionCode],
        @"cost": [theShip.ship cost],
        @"captain" : dataForUpgrade(theShip.equippedCaptain),
        @"upgrades" : upgrades,
        @"totalCost": [NSNumber numberWithInt: [theShip cost]]
    };
}

-(void)show:(DockSquad*)targetSquad
{
    NSMutableDictionary* squadData = [[NSMutableDictionary alloc] initWithCapacity: 0];
    NSArray* equippedShips = [[targetSquad equippedShips] array];
    NSInteger shipCount = equippedShips.count;
    NSMutableArray* ships = [[NSMutableArray alloc] initWithCapacity: 3];
    squadData[@"ships"] = ships;
    squadData[@"squadTotalCost"] = [NSNumber numberWithInt: targetSquad.cost];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setDateStyle:NSDateFormatterShortStyle];

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
    for (int i = 0; i < 6; i+=1) {
        NSDictionary* shipData;
        if (i < shipCount) {
            shipData = [self printableData: equippedShips[i] index: i+1 upgradeCount: upgradeCount];
        } else {
            shipData = @{};
        }
        [list addObject: shipData];
        if (i%2 == 1) {
            [ships addObject: @{@"list": list }];
            list = [[NSMutableArray alloc] initWithCapacity: 2];
        }
    }
    NSURL* url = [NSURL URLWithString: @"http://sample.com"];
    NSString *rendering = [GRMustacheTemplate renderObject: squadData
                                              fromResource: @"fleet"
                                                    bundle: nil
                                                     error: NULL]; 

    NSMutableDictionary* dict = [[NSPrintInfo sharedPrintInfo] dictionary];
    dict[NSPrintHorizontallyCentered] = [NSNumber numberWithBool: YES];
    dict[NSPrintVerticallyCentered] = [NSNumber numberWithBool: NO];
    dict[NSPrintHorizontalPagination] = [NSNumber numberWithInt: NSFitPagination];
    dict[NSPrintVerticalPagination] = [NSNumber numberWithInt: NSFitPagination];

    [[_webView mainFrame] loadHTMLString: rendering baseURL: url];
    [NSApp beginSheet: _fleetBuildWindow modalForWindow: _mainWindow modalDelegate: self didEndSelector: @selector(sheetDidEnd:returnCode:contextInfo:) contextInfo: nil];
}

-(void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [_fleetBuildWindow orderOut: nil];
}

-(IBAction)cancel:(id)sender
{
    [NSApp endSheet: _fleetBuildWindow];
}

-(IBAction)print:(id)sender
{
    [[_webView preferences] setShouldPrintBackgrounds: YES];
    [_webView print: sender];
    [self cancel: sender];
}

@end
