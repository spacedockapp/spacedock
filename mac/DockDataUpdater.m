#import "DockDataUpdater.h"

@interface DockDataUpdater () <NSURLDownloadDelegate,NSXMLParserDelegate>
@property (strong, nonatomic) NSURLRequest* request;
@property (strong, nonatomic) NSURLDownload* download;
@property (strong, nonatomic) NSString* downloadPath;
@property (strong, nonatomic) NSString* remoteVersion;
@property (strong, nonatomic) DockDataUpdaterFinished onFinished;
@end

@implementation DockDataUpdater

-(void)parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qName attributes:(NSDictionary*)attributeDict
{
    if ([elementName isEqualToString: @"Data"]) {
        _remoteVersion = attributeDict[@"version"];
        [parser abortParsing];
    }
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
    NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL: [NSURL fileURLWithPath: _downloadPath]];
    [parser setDelegate: self];
    [parser parse];
    _onFinished(_remoteVersion, _downloadPath, nil);
}

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
    _onFinished(nil, nil, error);
}

-(void)checkForNewData:(DockDataUpdaterFinished)finished
{
    _onFinished = finished;
    NSURL* url = [NSURL URLWithString: @"http://spacedock.funnyhatsoftware.com/Data.xml"];
    _request = [NSURLRequest requestWithURL: url];
    _download = [[NSURLDownload alloc] initWithRequest: _request delegate: self];
    _downloadPath = NSTemporaryDirectory();
    _downloadPath = [_downloadPath stringByAppendingPathComponent: @"Data.xml"];
    [_download setDestination: _downloadPath allowOverwrite: YES];
}

@end
