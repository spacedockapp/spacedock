#import "DockUniverse.h"

#import "MDockGameSystem+Addons.h"

@interface DockUniverse ()
@property (strong, nonatomic) NSManagedObjectContext* context;
@end

@implementation DockUniverse

-(id)initWithContext:(NSManagedObjectContext*)context templatesPath:(NSString*)templatesPath
{
    self = [super init];
    if (self != nil) {
        _context = context;
        [self setupGameSystems: templatesPath];
    }
    return self;
}

#pragma mark - Game Systems

-(void)setupGameSystems:(NSString*)templatesPath
{
    NSFileManager* fm = [NSFileManager defaultManager];
    NSManagedObjectContext* context = self.context;
    NSError* error;
    NSArray* gameSystemFolders = [fm contentsOfDirectoryAtPath: templatesPath error: &error];
    for (NSString* folderName in gameSystemFolders) {
        NSString* gameSystemPath = [templatesPath stringByAppendingPathComponent: folderName];
        BOOL isDir;
        if ([fm fileExistsAtPath: gameSystemPath isDirectory: &isDir] && isDir) {
            MDockGameSystem* gameSystem = [MDockGameSystem gameSystemWithId: folderName context: context];
            if (gameSystem == nil) {
                gameSystem  = [MDockGameSystem createGameSystemWithId: folderName context: self.context];
                [gameSystem updateFromPath: gameSystemPath];
            }
        }
    }
}

-(MDockGameSystem*)gameSystemWithIdentifier:(NSString*)identifier
{
    return [MDockGameSystem gameSystemWithId: identifier context: self.context];
}

-(NSArray*)gameSystems
{
    return [MDockGameSystem gameSystems: self.context];
}

@end
