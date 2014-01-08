#import "DockOverrideEditor.h"

#import "DockEquippedUpgrade+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockSquad+Addons.h"

@interface DockOverrideEditor ()
@property (strong, nonatomic) IBOutlet NSWindow* window;
@property (strong, nonatomic) IBOutlet NSWindow* mainWindow;
@property (strong, nonatomic) DockEquippedUpgrade* targetUpgrade;
@property (strong, nonatomic) NSNumber* cost;
@end

@implementation DockOverrideEditor

-(void)show:(DockEquippedUpgrade*)targetUpgrade
{
    _targetUpgrade = targetUpgrade;
    self.cost = _targetUpgrade.overriddenCost;
    [NSApp beginSheet: _window modalForWindow: _mainWindow modalDelegate: self didEndSelector: @selector(sheetDidEnd:returnCode:contextInfo:) contextInfo: nil];
}

-(void)sheetDidEnd:(NSWindow*)sheet returnCode:(NSInteger)returnCode contextInfo:(void*)contextInfo
{
    [_window orderOut: nil];
}

-(IBAction)cancel:(id)sender
{
    [NSApp endSheet: _window];
}

-(IBAction)override:(id)sender
{
    [_window makeFirstResponder: nil];
    [_targetUpgrade overrideWithCost: [_cost intValue]];
    _targetUpgrade = nil;
    [NSApp endSheet: _window];
}
@end
