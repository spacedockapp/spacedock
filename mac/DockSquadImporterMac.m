#import "DockSquadImporterMac.h"

#import "DockSquad+Addons.h"
#import "ISO8601DateFormatter.h"

@implementation DockSquadImporterMac

- (void)announceError:(NSError *)error window:(id)window
{
    NSAlert* alert = [NSAlert alertWithError: error];
    [alert beginSheetModalForWindow: window completionHandler: nil];
}

- (void)showAirbag:(NSString *)importWarning window:(id)window
{
    NSAlert* airbag = [[NSAlert alloc] init];
    airbag.messageText = importWarning;
    [airbag addButtonWithTitle: @"Import"];
    [airbag addButtonWithTitle: @"Cancel"];
    id handler = ^(NSModalResponse returnCode) {
        [[airbag window] orderOut: self];
        if (returnCode == NSAlertFirstButtonReturn) {
            [self performImport];
        }
    };
    [airbag beginSheetModalForWindow: window completionHandler: handler];
}

- (void)explainNothingToDo:(NSString *)explanation details:(NSString*)details window:(id)window
{
    NSAlert* warning = [[NSAlert alloc] init];
    warning.messageText = explanation;
    warning.informativeText = details;
    [warning beginSheetModalForWindow: window completionHandler: nil];
}


@end
