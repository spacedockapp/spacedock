#import <Foundation/Foundation.h>

typedef void (^ DockDataUpdaterFinished)(NSString* remoteVersion, NSData* downloadData, NSError* error);

@interface DockDataUpdater : NSObject
@property (nonatomic,strong) NSObject* progressBar;
-(void)checkForNewData:(DockDataUpdaterFinished)finished;
-(void)checkForNewDataVersion:(DockDataUpdaterFinished)finished;
@end
