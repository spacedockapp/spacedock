#import "DockFleetBuildSheet.h"

#import "DockEquippedShip+Addons.h"
#import "DockSquad+Addons.h"

#import "GRMustache.h"

@implementation DockFleetBuildSheet

-(void)show:(DockSquad*)targetSquad
{
    NSMutableDictionary* squadData = [[NSMutableDictionary alloc] initWithCapacity: 0];
    NSArray* equippedShips = [[targetSquad equippedShips] array];
    NSInteger shipCount = equippedShips.count;
    NSMutableArray* ships = [[NSMutableArray alloc] initWithCapacity: 3];
    squadData[@"ships"] = ships;
    for (int i = 0; i < 6; i+=1) {
        NSMutableArray* list = [[NSMutableArray alloc] initWithCapacity: 2];
        if (i < shipCount) {
            [list addObject: @{@"title": [equippedShips[i] title]}];
        } else {
            [list addObject: @{}];
        }
        ++i;
        if (i < shipCount) {
            [list addObject: @{@"title": [equippedShips[i] title]}];
        } else {
            [list addObject: @{}];
        }
        [ships addObject: @{@"list": list }];
    }
    NSURL* url = [NSURL URLWithString: @"http://sample.com"];
    NSString *rendering = [GRMustacheTemplate renderObject: squadData
                                              fromResource: @"fleet"
                                                    bundle: nil
                                                     error: NULL]; 
    [[_webView mainFrame] loadHTMLString: rendering baseURL: url];
    [_fleetBuildWindow makeKeyAndOrderFront: nil];
    [NSApp runModalForWindow: _fleetBuildWindow];
    [_fleetBuildWindow orderOut: nil];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [NSApp stopModal];
}

-(IBAction)cancel:(id)sender
{
    [NSApp stopModal];
}

-(IBAction)print:(id)sender
{
    [[_webView preferences] setShouldPrintBackgrounds: YES];
    [_webView print: sender];
    [self cancel: sender];
}

@end
