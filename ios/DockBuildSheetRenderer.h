#import <Foundation/Foundation.h>

@class DockSquad;

@interface DockBuildSheetRenderer : NSObject
-(id)initWithSquad:(DockSquad*)targetSquad;
-(void)draw:(CGRect)bounds;
@end
