#import "DockSquadImporteriOS.h"

@interface DockSquadImporteriOS ()
@end

@implementation DockSquadImporteriOS

- (void)announceError:(NSError *)error window:(id)window
{
    NSString* title = @"Update Squads Error";
    NSString* info = [NSString stringWithFormat: @"Error %@ occured while trying to load squads.", error];
    UIAlertView* view = [[UIAlertView alloc] initWithTitle: title
                                                   message: info
                                                  delegate: nil
                                         cancelButtonTitle: nil
                                         otherButtonTitles: @"OK", nil];
    [view show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self performImport];
    }
}

- (void)showAirbag:(NSString *)importWarning window:(id)window
{
    NSString* title = @"Update Squads";
    UIAlertView* view = [[UIAlertView alloc] initWithTitle: title
                                                   message: importWarning
                                                  delegate: self
                                         cancelButtonTitle: @"Cancel"
                                         otherButtonTitles: @"Import", nil];
    [view show];
}


@end
