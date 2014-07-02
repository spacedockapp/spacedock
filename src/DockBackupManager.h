#import <Foundation/Foundation.h>

@interface DockBackupManager : NSObject
+(DockBackupManager*)sharedBackupManager;
-(BOOL)backupNow:(NSManagedObjectContext*)context error:(NSError**)error;
@end
