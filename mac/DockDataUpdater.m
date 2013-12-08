#import "DockDataUpdater.h"

@interface DockDataUpdater () <NSXMLParserDelegate>
@property (strong, nonatomic) NSURLRequest* request;
@property (strong, nonatomic) NSURLConnection* connnection;
@property (strong, nonatomic) NSMutableData *downloadData;
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

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_downloadData appendData: data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData: _downloadData];
    [parser setDelegate: self];
    [parser parse];
    _onFinished(_remoteVersion, _downloadData, nil);
}

-(void)checkForNewData:(DockDataUpdaterFinished)finished
{
    _onFinished = finished;
    NSURL* url = [NSURL URLWithString: @"http://spacedock.funnyhatsoftware.com/Data.xml"];
    _request = [NSURLRequest requestWithURL: url];
    _downloadData = [[NSMutableData alloc] init];
    _connnection = [NSURLConnection connectionWithRequest: _request delegate: self];
}

@end
