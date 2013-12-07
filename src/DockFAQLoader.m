#import "DockFAQLoader.h"

@implementation DockFAQLoader

-(void)downloadFaq
{
}

-(void)load:(DockFAQDownloadFinished)whenFinished
{
    self.downloadFinished = whenFinished;
    [self downloadFaq];
}

-(void)parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qName attributes:(NSDictionary*)attributeDict
{
    if ([elementName isEqualToString: @"article"]) {
        self.currentArticle = [[NSMutableDictionary alloc] initWithDictionary: attributeDict];
    } else if ([self.messageTags containsObject: elementName]) {
        self.currentText = [[NSMutableString alloc] init];
    }
}

-(void)parser:(NSXMLParser*)parser didEndElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qName
{
    if ([self.messageTags containsObject: elementName]) {
        self.currentArticle[elementName] = self.currentText;
        self.currentText = nil;
    } else if ([elementName isEqualToString: @"article"]) {
        [self.articles addObject: self.currentArticle];
    }
}

-(void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string
{
    [self.currentText appendString: string];
}

-(NSString*)asHTML:(BOOL)andrewOnly
{
    NSMutableString* s = [[NSMutableString alloc] initWithString: @"<HTML><HEAD><link rel=\"stylesheet\" type=\"text/css\" href=\"http://static.geekdo-images.com/static/css_master_51f5d2398b0e4.css\"></HEAD><BODY>"];
    for (NSDictionary* d in self.articles) {
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
