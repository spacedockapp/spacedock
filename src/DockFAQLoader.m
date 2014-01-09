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
    NSMutableString* s = [[NSMutableString alloc] initWithString: @"<HTML>\n<HEAD>\n<meta charset=\"UTF-8\">\n<link rel=\"stylesheet\" type=\"text/css\" href=\"http://spacedock.funnyhatsoftware.com/css_for_faq.css\">\n</HEAD>\n<BODY>\n"];
    for (NSDictionary* d in _articles) {
        NSString* userName = d[@"username"];
        if (!andrewOnly || [userName isEqualToString: @"Andrew Parks"]) {
            [s appendFormat: @"<div class=\"article\">\n"];
            [s appendFormat: @"<div>\n%@ <a href=\"%@\">%@</a></div>", d[@"username"], d[@"link"], d[@"id"]];
            [s appendFormat: @"<div>\n%@</div>\n", d[@"body"]];
            [s appendFormat: @"</div>\n"];
        }
    }
    [s appendString: @"</BODY>\n</HTML>\n"];
    return s;
}

@end
