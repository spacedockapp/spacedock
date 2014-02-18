#import "DockUtilsMobile.h"

BOOL saveItem(id targetItem, NSError** error)
{
    NSManagedObjectContext* context = [targetItem managedObjectContext];
    return [context save: error];
}

void presentError(NSError* error)
{
    UIAlertView* view = [[UIAlertView alloc] initWithTitle: @"Error" message: error.localizedDescription delegate: nil cancelButtonTitle: @"" otherButtonTitles: @"", nil];
    [view show];
}

void presentUnsuppportedFeatureDialog()
{
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Not Supported"
                                                         message: @"This feature is only supported on iOS 7 or greater."
                                                        delegate: nil
                                               cancelButtonTitle: @"Cancel"
                                               otherButtonTitles: nil];
        [alert show];
}

BOOL isOS7OrGreater()
{
    UIDevice* device = [UIDevice currentDevice];
    NSString* version = device.systemVersion;
    BOOL is7 = ([version compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending);
    return is7;
}

