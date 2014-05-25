#import <Cocoa/Cocoa.h>

@class DockShip;

@interface DockMoveGrid : NSView
@property (nonatomic, strong) DockShip* ship;
@property (nonatomic, assign) BOOL whiteBackground;
@end
