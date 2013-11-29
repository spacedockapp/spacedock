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
