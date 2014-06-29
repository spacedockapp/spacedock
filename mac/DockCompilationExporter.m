#import "DockCompilationExporter.h"

#import "DockSet+Addons.h"
#import "DockSetItem+Addons.h"

@interface DockCompilationExporter()
@property (strong, nonatomic) NSString* path;
@property (strong, nonatomic) NSMutableString* restrictions;
@end

@implementation DockCompilationExporter

-(id)initWithPath:(NSString*)path
{
    self = [super init];
    if (self != nil) {
        self.path = path;
        self.restrictions = [[NSMutableString alloc] init];
    }
    return self;
}

-(void)appendCommentLine:(NSString*)comment
{
    [self.restrictions appendFormat: @"# %@\n", comment];
}

-(void)appendLine:(NSString*)lineContents
{
    [self.restrictions appendFormat: @"%@\n", lineContents];
}

-(void)appendLine:(NSString*)lineContents withComment:(NSString*)comment
{
    [self.restrictions appendFormat: @"%s\t# %@\n", [lineContents UTF8String], comment];
}

-(BOOL)export:(NSManagedObjectContext*)context error:(NSError**)error
{
    self.restrictions = [[NSMutableString alloc] init];
    NSArray* includedSets = [DockSet includedSets: context];
    id compareSets = ^(DockSet* set1, DockSet* set2) {
        NSComparisonResult r = [set1.releaseDate compare: set2.releaseDate];
        if (r == NSOrderedSame) {
            r = [set1.productName compare: set2.productName];
        }
        return r;
    };
    includedSets = [includedSets sortedArrayUsingComparator: compareSets];
    [self appendCommentLine: @""];
    [self appendCommentLine: @"Space Dock selection list"];
    [self appendCommentLine: @""];
    NSUUID* uuid = [NSUUID UUID];
    [self appendLine: [uuid UUIDString]];
    [self appendLine: @"1"];

    for (DockSet* set in includedSets) {
        [self appendCommentLine: @""];
        [self appendCommentLine: set.productName];
        [self appendCommentLine: @""];
        NSArray* items = [set sortedSetItems];
        for (id item in items) {
            NSString* itemDescription = [item itemDescription];
            if (itemDescription != nil) {
                NSString* externalId = [item valueForKey: @"externalId"];
                [self appendLine: externalId withComment: [item itemDescription]];
            }
        }
    }
    return [self.restrictions writeToFile: _path atomically: NO encoding: NSUTF8StringEncoding error: error];
}

@end
