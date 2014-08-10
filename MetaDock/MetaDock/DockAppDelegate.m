#import "DockAppDelegate.h"

@implementation DockAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    id target = [[[NSProcessInfo processInfo] environment] objectForKey:@"TARGET"];
    NSLog(@"target = %@", target);
    NSDictionary* environment = [[NSProcessInfo processInfo] environment];
    NSString* injectBundle = environment[@"XCInjectBundle"];
    NSLog(@"injectBundle = %@", injectBundle);
}

@end
