#import "NSFileManager+Addons.h"

@implementation NSFileManager (Addons)

- (NSArray *)sortedContentsOfDirectoryAtPath:(NSString *)path error:(NSError **)error
{
    NSArray* contents = [self contentsOfDirectoryAtPath: path error: error];
    NSMutableDictionary* fileDates = [NSMutableDictionary dictionaryWithCapacity: contents.count];
    for (NSString* itemName in contents) {
        NSString* itemPath = [path stringByAppendingPathComponent: itemName];
        NSDictionary* d = [self attributesOfItemAtPath: itemPath error: error];
        if (d == nil) {
            return nil;
        }
        NSLog(@"d = %@", d);
        fileDates[itemName] = d[NSFileModificationDate];
    }
    id byDate = ^(NSString* a, NSString* b) {
        NSDate* d1 = fileDates[a];
        NSDate* d2 = fileDates[b];
        return [d2 compare: d1];
    };
    return [contents sortedArrayUsingComparator: byDate];
}

@end
