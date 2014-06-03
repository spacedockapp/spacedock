#import <Foundation/Foundation.h>

@class DockSquad;

extern NSString* kPlayerNameKey;
extern NSString* kPlayerEmailKey;
extern NSString* kEventFactionKey;
extern NSString* kEventNameKey;

@interface DockBuildSheetRenderer : NSObject
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* event;
@property (strong, nonatomic) NSString* faction;
@property (strong, nonatomic) NSDate* date;
@property (assign, nonatomic) NSInteger pageIndex;
-(id)initWithSquad:(DockSquad*)targetSquad;
-(void)draw:(CGRect)bounds;
@end
