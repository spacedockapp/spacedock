#import <Foundation/Foundation.h>

typedef void (^ DockDataUpdaterFinished)(NSString* remoteVersion, NSData* downloadData, NSError* error);

@interface DockDataUpdater : NSObject
-(void)checkForNewData:(DockDataUpdaterFinished)finished;
@end
