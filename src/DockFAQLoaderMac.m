#import "DockFAQLoaderMac.h"

@interface DockFAQLoaderMac (Private) <NSURLDownloadDelegate,NSXMLParserDelegate>

@end

@implementation DockFAQLoaderMac

- (void)downloadDidFinish:(NSURLDownload *)download
{
    self.articles = [NSMutableArray arrayWithCapacity: 0];
    self.messageTags = [NSSet setWithArray: @[@"body", @"subject"]];
    NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL: [NSURL fileURLWithPath: self.downloadPath]];
    [parser setDelegate: self];
    [parser parse];
    self.downloadFinished();
}

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
}

-(void)downloadFaq
{
    NSURL* url = [NSURL URLWithString: @"http://boardgamegeek.com/xmlapi2/thread?id=1031156"];
    self.request = [NSURLRequest requestWithURL: url];
    self.download = [[NSURLDownload alloc] initWithRequest: self.request delegate: self];
    self.downloadPath = NSTemporaryDirectory();
    self.downloadPath = [self.downloadPath stringByAppendingPathComponent: @"FAQ.xml"];
    [self.download setDestination: self.downloadPath allowOverwrite: YES];
}

@end
