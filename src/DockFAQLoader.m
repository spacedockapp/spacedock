#import "DockFAQLoader.h"

@interface DockFAQLoader (Private) <NSURLDownloadDelegate,NSXMLParserDelegate>

@end

@implementation DockFAQLoader

- (void)downloadDidFinish:(NSURLDownload *)download
{
    _articles = [NSMutableArray arrayWithCapacity: 0];
    NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL: [NSURL fileURLWithPath: _downloadPath]];
    [parser setDelegate: self];
    [parser parse];
    _downloadFinished();
}

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
}

-(void)load:(DockFAQDownloadFinished)whenFinished
{
    _messageTags = [NSSet setWithArray: @[@"body", @"subject"]];
    _downloadFinished = whenFinished;
    NSURL* url = [NSURL URLWithString: @"http://boardgamegeek.com/xmlapi2/thread?id=1031156"];
    _request = [NSURLRequest requestWithURL: url];
    _download = [[NSURLDownload alloc] initWithRequest: _request delegate: self];
    _downloadPath = NSTemporaryDirectory();
    _downloadPath = [_downloadPath stringByAppendingPathComponent: @"FAQ.xml"];
    [_download setDestination: _downloadPath allowOverwrite: YES];
}

-(void)parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qName attributes:(NSDictionary*)attributeDict
{
    if ([elementName isEqualToString: @"article"]) {
        _currentArticle = [[NSMutableDictionary alloc] initWithDictionary: attributeDict];
    } else if ([_messageTags containsObject: elementName]) {
        _currentText = [[NSMutableString alloc] init];
    }
}

-(void)parser:(NSXMLParser*)parser didEndElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qName
{
    if ([_messageTags containsObject: elementName]) {
        _currentArticle[elementName] = _currentText;
        _currentText = nil;
    } else if ([elementName isEqualToString: @"article"]) {
        [_articles addObject: _currentArticle];
    }
}

-(void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string
{
    [_currentText appendString: string];
}

-(NSString*)asHTML:(BOOL)andrewOnly
{
    NSMutableString* s = [[NSMutableString alloc] initWithString: @"<HTML><HEAD><link rel=\"stylesheet\" type=\"text/css\" href=\"http://static.geekdo-images.com/static/css_master_51f5d2398b0e4.css\"></HEAD><BODY>"];
    for (NSDictionary* d in _articles) {
        NSString* userName = d[@"username"];
        if (!andrewOnly || [userName isEqualToString: @"Andrew Parks"]) {
            [s appendFormat: @"<div class=\"article\">"];
            [s appendFormat: @"<div>%@ <a href=\"%@\">%@</a></div>", d[@"username"], d[@"link"], d[@"id"]];
            [s appendFormat: @"<div>%@</div>", d[@"body"]];
            [s appendFormat: @"</div>"];
        }
    }
    [s appendString: @"</BODY></HTML>"];
    return s;
}

@end
