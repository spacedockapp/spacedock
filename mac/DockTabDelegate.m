#import "DockTabDelegate.h"

NSString* kTabSelectionChanged = @"DockTabSelectionChanged";

@interface DockTabDelegate () <NSTabViewDelegate>

@end

@implementation DockTabDelegate

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    NSNotification* note = [NSNotification notificationWithName: kTabSelectionChanged object: tabView];
    [center postNotification: note];
}

@end
