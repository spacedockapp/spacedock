#import "DockViperAppDelegate.h"

#import "DockViperDataLoader.h"

@implementation DockViperAppDelegate

-(NSString*)viperDockDirectory
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* docsDirectory = [[[fileManager URLsForDirectory: NSDocumentDirectory inDomains: NSUserDomainMask] lastObject] path];
    NSString* viperDockFiles = [docsDirectory stringByAppendingPathComponent: @"Viper Dock"];
    BOOL isDir;
    if (![fileManager fileExistsAtPath: viperDockFiles isDirectory: &isDir]) {
        [fileManager createDirectoryAtPath: viperDockFiles withIntermediateDirectories: YES attributes: nil error: nil];
    }
    return viperDockFiles;
}

-(void)loadData
{
    NSString* viperDockFiles = [self viperDockDirectory];
    DockViperDataLoader* loader = [[DockViperDataLoader alloc] initWithContext: self.managedObjectContext pathToDataFiles: viperDockFiles];
    NSError* error;
    if (![loader loadData: &error]) {
        NSAlert* alert = [NSAlert alertWithError: error];
        [alert runModal];
    }
}

-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication*)sender
{
    NSString* viperDockFiles = [self viperDockDirectory];
    NSString* allSquadsPath = [viperDockFiles stringByAppendingPathComponent: @"All Squads.spacedocksquads"];
    [self saveSquadsToDisk: allSquadsPath];
    return [super applicationShouldTerminate: sender];
}
@end
