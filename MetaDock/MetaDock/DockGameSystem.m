#import "DockGameSystem.h"

static NSString* kTitleKey = @"title";
static NSString* kPropertiesFileName = @"properties.json";

@implementation DockGameSystem
-(id)initWithPath:(NSString*)path
{
    self = [super init];
    if (self != nil) {
        [self loadProperties: path];
    }
    return self;
}

-(void)loadProperties:(NSString*)path
{
    assert(path != nil);
    NSString* propertiesPath = [path stringByAppendingPathComponent: kPropertiesFileName];
    NSData* data = [NSData dataWithContentsOfFile:propertiesPath];
    if (data == nil) {
        return;
    }
    NSError* error;
    id json = [NSJSONSerialization JSONObjectWithData: data options: 0 error: &error];
    if (json == nil) {
        return;
    }
    assert([json isKindOfClass: [NSDictionary class]]);
    NSDictionary* properties = json;
    _title = properties[kTitleKey];
}

@end
