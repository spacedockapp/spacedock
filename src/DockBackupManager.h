#import <Foundation/Foundation.h>

@interface DockBackupManager : NSObject
@property (assign, nonatomic) BOOL squadHasChanged;
+(DockBackupManager*)sharedBackupManager;
-(BOOL)backupNow:(NSManagedObjectContext*)context error:(NSError**)error;
@end
