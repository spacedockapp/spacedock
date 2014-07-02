#import "DockBackupManager.h"

#import "ISO8601DateFormatter.h"

@interface DockBackupManager ()
@property (strong, nonatomic) ISO8601DateFormatter* dateFormatter;
@end

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

-(BOOL)backupNow:(NSManagedObjectContext*)context error:(NSError**)error
{
    
}

@end
