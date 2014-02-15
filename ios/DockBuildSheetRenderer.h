#import <Foundation/Foundation.h>

@class DockSquad;

@interface DockBuildSheetRenderer : NSObject
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* event;
@property (strong, nonatomic) NSString* faction;
@property (strong, nonatomic) NSDate* date;
-(id)initWithSquad:(DockSquad*)targetSquad;
-(void)draw:(CGRect)bounds;
@end
