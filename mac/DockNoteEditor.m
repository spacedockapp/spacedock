#import "DockNoteEditor.h"

#import "DockSquad+Addons.h"

@interface DockNoteEditor ()
@property (strong, nonatomic) IBOutlet NSWindow* window;
@property (strong, nonatomic) IBOutlet NSWindow* mainWindow;
@property (strong, nonatomic) DockSquad* targetSquad;
@end

@implementation DockNoteEditor

-(void)show:(DockSquad*)targetSquad
{
    _targetSquad = targetSquad;
    self.additionalPoints = [NSString stringWithFormat: @"%d", [_targetSquad.additionalPoints intValue]];
    self.notes = _targetSquad.notes;
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

-(IBAction)save:(id)sender
{
    _targetSquad.additionalPoints = [NSNumber numberWithInt: [_additionalPoints intValue]];
    _targetSquad.notes = _notes;
    [NSApp endSheet: _window];
}

@end
