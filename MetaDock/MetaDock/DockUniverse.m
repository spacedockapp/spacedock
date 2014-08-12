#import "DockUniverse.h"

#import "DockGameSystem.h"

@implementation DockUniverse

-(id)initWithDataStorePath:(NSString*)dataStore templatesPath:(NSString*)templatesPath
{
    self = [super init];
    if (self != nil) {
        [self setupGameSystems: templatesPath];
    }
    return self;
}

#pragma mark - Game Systems

-(void)setupGameSystems:(NSString*)templatesPath
{
    NSFileManager* fm = [NSFileManager defaultManager];
    NSError* error;
    NSArray* gameSystemFolders = [fm contentsOfDirectoryAtPath: templatesPath error: &error];
    NSMutableArray* gameSystems = [[NSMutableArray alloc] initWithCapacity: gameSystemFolders.count];
    for (NSString* folderName in gameSystemFolders) {
        NSString* gameSystemPath = [templatesPath stringByAppendingPathComponent: folderName];
        BOOL isDir;
        if ([fm fileExistsAtPath: gameSystemPath isDirectory: &isDir] && isDir) {
            DockGameSystem* gameSystem = [[DockGameSystem alloc] initWithPath: gameSystemPath];
            [gameSystems addObject: gameSystem];
        }
    }
    _gameSystems = [NSSet setWithArray: gameSystems];
}

-(DockGameSystem*)gameSystemWithIdentifier:(NSString*)identifier
{
    id objectWithIdentifier = ^(id obj, BOOL* stop) {
        NSString* objIdentifier = [obj identifier];
        return [identifier isEqualToString: objIdentifier];
    };
    NSSet* matching = [_gameSystems objectsPassingTest: objectWithIdentifier];
    return matching.anyObject;
}

@end
