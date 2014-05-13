#import <Cocoa/Cocoa.h>

@class DockShip;

@interface DockDialView : NSView
@property (nonatomic, strong) IBOutlet NSArrayController* shipsController;
@property (nonatomic, strong) IBOutlet NSTextField* shipName;
@property (nonatomic, strong) DockShip* ship;
@end
