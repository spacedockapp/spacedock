#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@class DockSquad;

@interface DockFleetBuildSheet : NSObject
@property (assign) IBOutlet NSWindow* fleetBuildWindow;
@property (assign) IBOutlet NSWindow* mainWindow;
@property (assign) IBOutlet WebView* webView;
-(void)show:(DockSquad*)targetSquad;
-(IBAction)cancel:(id)sender;
-(IBAction)print:(id)sender;
@end
