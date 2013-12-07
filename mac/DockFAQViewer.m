#import "DockFAQViewer.h"

#import <WebKit/WebKit.h>

#import "DockAppDelegate.h"
#import "DockFAQLoaderMac.h"

@interface DockFAQViewer (Private) <NSTextFinderClient>

@end

@implementation DockFAQViewer

-(void)awakeFromNib
{
    [super awakeFromNib];
}

-(NSURL*)urlForHTMLFile:(BOOL)andrewOnly
{
    NSURL* appData = [DockAppDelegate applicationFilesDirectory];
    if (andrewOnly) {
        return [appData URLByAppendingPathComponent: @"andrew_faq.html"];
    }
   return [appData URLByAppendingPathComponent: @"full_faq.html"];
}

-(void)updateHTML
{
    NSURL* url = [self urlForHTMLFile: YES];
    NSError* error;
    NSString* faq = [_faqLoader asHTML: YES];
    [faq writeToURL: url atomically: NO encoding: NSUTF8StringEncoding error: &error];
    url = [self urlForHTMLFile: NO];
    faq = [_faqLoader asHTML: NO];
    [faq writeToURL: url atomically: NO encoding: NSUTF8StringEncoding error: &error];
    [self displayHTML];
}

-(void)displayHTML
{
    BOOL andrewOnly = [_andrewOnlyButton state] == NSOnState;
    NSURL* fileURL = [self urlForHTMLFile: andrewOnly];
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL isDirectory;
    if ([fm fileExistsAtPath: [fileURL path] isDirectory: &isDirectory]) {
        NSError* error;
        NSString* html = [NSString stringWithContentsOfURL: fileURL encoding: NSUTF8StringEncoding error: &error];
        NSURL* bggURL = [NSURL URLWithString: @"http://boardgamegeek.com"];
        [[_webView mainFrame] loadHTMLString: html baseURL: bggURL];
    } else {
        [self refresh: nil];
    }
}

-(void)updateFinished
{
    [_progressIndicator stopAnimation: nil];
    [_progressIndicator setHidden: YES];
    [_refreshButton setEnabled: YES];
    [self updateHTML];
}

-(IBAction)refresh:(id)sender
{
    [_refreshButton setEnabled: NO];
    [_progressIndicator startAnimation: sender];
    [_progressIndicator setHidden: NO];
    _faqLoader = [[DockFAQLoaderMac alloc] init];
    [_faqLoader load: ^() { [self updateFinished];}];
}

-(IBAction)updateAndrewOnly:(id)sender
{
    [self updateHTML];
    [self displayHTML];
}

-(IBAction)find:(id)sender
{
    [_searchField becomeFirstResponder];
}

-(IBAction)findAgain:(id)sender
{
    [_webView searchFor: _searchField.stringValue direction: YES caseSensitive: NO wrap: YES];
}

-(IBAction)findBackwards:(id)sender
{
    [_webView searchFor: _searchField.stringValue direction: NO caseSensitive: NO wrap: YES];
}

-(void)show
{
    [self displayHTML];
    [_window makeKeyAndOrderFront: nil];
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
    [self findAgain: nil];
}

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation
        request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id)listener
{
    NSURL* url = [request URL];
    NSString *urlString = [url absoluteString];
    if ([urlString hasPrefix:@"http://boardgamegeek.com/article"]) {
        [listener ignore];
        [[NSWorkspace sharedWorkspace] openURL: url];
    } else {
        [listener use];
    }
}


@end
