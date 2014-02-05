#import "DockDataModelExporter.h"

@implementation DockDataModelExporter

-(BOOL)doExport:(NSString*)targetFolder error:(NSError**)error
{
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL isDir;
    BOOL exists = [fm fileExistsAtPath: targetFolder isDirectory: &isDir];
    if (!exists) {
        BOOL created = [fm createDirectoryAtPath: targetFolder withIntermediateDirectories: YES attributes: @{} error: error];
        if (!created) {
            return NO;
        }
    }
    NSString* packageName = @"com.funnyhatsoftware.spacedock";
    NSString* sourcePartialPath = [packageName stringByReplacingOccurrencesOfString: @"." withString: @"/"];
    NSString* sourcePath = [targetFolder stringByAppendingPathComponent: sourcePartialPath];
    exists = [fm fileExistsAtPath: sourcePath isDirectory: &isDir];
    if (!exists) {
        BOOL created = [fm createDirectoryAtPath: sourcePath withIntermediateDirectories: YES attributes: @{} error: error];
        if (!created) {
            return NO;
        }
    }
    return YES;
}

@end
