#import "DockFleetBuildSheet.h"

#import "GRMustache.h"

@implementation DockFleetBuildSheet

-(void)show:(DockSquad*)targetSquad
{
    NSURL* url = [NSURL URLWithString: @"http://sample.com"];
    NSString *rendering = [GRMustacheTemplate renderObject: targetSquad
                                              fromResource: @"fleetbuild"
                                                    bundle: nil
                                                     error: NULL]; 
    [[_webView mainFrame] loadHTMLString: rendering baseURL: url];
    [_fleetBuildWindow makeKeyAndOrderFront: nil];
    [NSApp runModalForWindow: _fleetBuildWindow];
    [_fleetBuildWindow orderOut: nil];
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
