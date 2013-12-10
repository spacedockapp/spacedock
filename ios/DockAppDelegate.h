#import <UIKit/UIKit.h>

@interface DockAppDelegate : UIResponder<UIApplicationDelegate>

@property (strong, nonatomic) UIWindow* window;
@property (assign, readonly, nonatomic) BOOL hasUpdatedData;

-(void)installData:(NSData*)data;
-(void)revertData;
@end
