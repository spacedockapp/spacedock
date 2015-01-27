#import <Foundation/Foundation.h>

@class DockSquad;

extern NSString* kPlayerNameKey;
extern NSString* kPlayerEmailKey;
extern NSString* kEventFactionKey;
extern NSString* kEventNameKey;
extern NSString* kBlindBuyKey;
extern NSString* kLightHeaderKey;

@interface DockBuildSheetRenderer : NSObject
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* event;
@property (strong, nonatomic) NSString* faction;
@property (strong, nonatomic) NSDate* date;
@property (assign, nonatomic) NSInteger pageIndex;
@property (assign, nonatomic) BOOL blindbuy;
@property (assign, nonatomic) BOOL lightHeader;
-(id)initWithSquad:(DockSquad*)targetSquad;
-(void)draw:(CGRect)bounds;
@end
