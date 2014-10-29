#import <Foundation/Foundation.h>

@class DockSquad;

extern NSString* kPlayerNameKey;
extern NSString* kPlayerEmailKey;
extern NSString* kEventFactionKey;
extern NSString* kEventNameKey;
extern NSString* kBlindBuyKey;

@interface DockBuildSheetRenderer : NSObject
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* event;
@property (strong, nonatomic) NSString* faction;
@property (strong, nonatomic) NSDate* date;
@property (assign, nonatomic) NSInteger pageIndex;
@property (assign, nonatomic) BOOL blindbuy;
-(id)initWithSquad:(DockSquad*)targetSquad;
-(void)draw:(CGRect)bounds;
@end
