#import <Foundation/Foundation.h>

typedef void (^ DockFAQDownloadFinished)();

@interface DockFAQLoader : NSObject
@property (strong, nonatomic) NSString* downloadPath;
@property (strong, nonatomic) NSMutableString* currentText;
@property (strong, nonatomic) DockFAQDownloadFinished downloadFinished;
@property (strong, nonatomic) NSMutableDictionary* currentArticle;
@property (strong, nonatomic) NSMutableArray* articles;
@property (strong, nonatomic) NSSet* messageTags;

-(void)load:(DockFAQDownloadFinished)whenFinished;
-(NSString*)asHTML:(BOOL)andrewOnly;
@end
