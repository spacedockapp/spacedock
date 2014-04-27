#import "DockViperAppDelegate.h"

#import "DockViperDataLoader.h"

@implementation DockViperAppDelegate

-(void)loadData
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* docsDirectory = [[[fileManager URLsForDirectory: NSDocumentDirectory inDomains: NSUserDomainMask] lastObject] path];
    NSString* viperDockFiles = [docsDirectory stringByAppendingPathComponent: @"Viper Dock"];
    DockViperDataLoader* loader = [[DockViperDataLoader alloc] initWithContext: self.managedObjectContext pathToDataFiles: viperDockFiles];
    NSError* error;
    if (![loader loadData: &error]) {
        NSAlert* alert = [NSAlert alertWithError: error];
        [alert runModal];
    }
}


@end
