#import <Foundation/Foundation.h>

typedef void (^ DockDataUpdaterFinished)(NSString* remoteVersion, NSString* downloadPath, NSError* error);

@interface DockDataUpdater : NSObject
-(void)checkForNewData:(DockDataUpdaterFinished)finished;
@end
