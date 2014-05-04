#import <Foundation/Foundation.h>

@class DockSquad;

@interface DockBuildMat : NSObject
-(id)initWithSquad:(DockSquad*)targetSquad;
-(void)print;
@end
