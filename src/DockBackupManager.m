#import "DockBackupManager.h"

#import "DockConstants.h"
#import "DockSquad+Addons.h"
#import "DockUtils.h"
#import "ISO8601DateFormatter.h"
#import "NSFileManager+Addons.h"

@interface DockBackupManager ()
@property (strong, nonatomic) ISO8601DateFormatter* dateFormatter;
@end

const int kMaxBackupFilesCount = 10;

@implementation DockBackupManager

DockBackupManager* sManager = nil;

+(DockBackupManager*)sharedBackupManager
{
    if (sManager == nil) {
        sManager = [[DockBackupManager alloc] init];
    }
    return sManager;
}

-(id)init
{
    self = [super init];
    if (self != nil) {
        self.dateFormatter = [[ISO8601DateFormatter alloc] init];
    }
    return self;
}

-(NSString*)backupDirectory
{
    NSString* appData = [applicationFilesDirectory() path];
    NSString* backupPath = [appData stringByAppendingPathComponent: @"backup"];
    return backupPath;
}

-(BOOL)backupNow:(NSManagedObjectContext*)context error:(NSError**)error
{
    self.squadHasChanged = NO;
    NSString* backupDirectory = [self backupDirectory];
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL isDir;
    if ([fm fileExistsAtPath: backupDirectory isDirectory: &isDir]) {
        if (!isDir) {
            return NO;
        }
    } else {
        if (![fm createDirectoryAtPath: backupDirectory withIntermediateDirectories: YES attributes: nil error: error]) {
            return NO;
        }
    }
    NSArray* allSquads = [DockSquad allSquads: context];
    if (allSquads.count == 0) {
        return YES;
    }
    NSString* dateString = [self.dateFormatter stringFromDate: [NSDate date]];
    NSString* backupFileName = [NSString stringWithFormat: @"backup-%@-%@", dateString, [[NSUUID UUID] UUIDString]];
    backupFileName = [backupFileName stringByAppendingPathExtension: kSpaceDockSquadListFileExtension];
    NSString* backupFilePath = [backupDirectory stringByAppendingPathComponent: backupFileName];
    NSError* saveError = [DockSquad saveSquadsToDisk: backupFilePath context: context];
    if (saveError != nil && error != nil) {
        *error = saveError;
    }
    if (saveError == nil) {
        NSArray* contents = [[NSFileManager defaultManager] sortedContentsOfDirectoryAtPath: backupDirectory error: nil];
        if (contents.count > kMaxBackupFilesCount) {
            NSArray* onesToDelete = [contents subarrayWithRange: NSMakeRange(kMaxBackupFilesCount, contents.count - kMaxBackupFilesCount)];
            for (NSString* oneTarget in onesToDelete) {
                NSString* oneTargetPath = [backupDirectory stringByAppendingPathComponent: oneTarget];
                [fm removeItemAtPath: oneTargetPath error: nil];
            }
        }
    }
    return saveError == nil;
}

@end
