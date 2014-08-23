#import "DockReference+Addons.h"

@implementation DockReference (Addons)

-(NSDictionary*)dictionaryForExport
{
    return @{
             @"title": self.title,
             @"categories": @[
                     @{@"value": @"Reference", @"type": @"type" }
                ]
             };
}

@end
