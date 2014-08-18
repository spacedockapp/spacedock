#import "DockReference+Addons.h"

@implementation DockReference (Addons)

-(NSDictionary*)dictionaryForExport
{
    return @{
        @"title": self.title,
        @"category": @"Reference"
    };
}

@end
