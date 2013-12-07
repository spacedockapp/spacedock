#import <Foundation/Foundation.h>

@class WebView;
@class DockFAQLoaderMac;

@interface DockFAQViewer : NSObject
@property (strong, nonatomic) IBOutlet NSWindow* window;
@property (strong, nonatomic) IBOutlet WebView* webView;
@property (strong, nonatomic) IBOutlet NSButton* refreshButton;
@property (strong, nonatomic) IBOutlet NSButton* andrewOnlyButton;
@property (strong, nonatomic) IBOutlet NSProgressIndicator* progressIndicator;
@property (strong, nonatomic) IBOutlet NSSearchField* searchField;
@property (strong, nonatomic) DockFAQLoaderMac* faqLoader;
-(IBAction)refresh:(id)sender;
-(void)show;
@end
