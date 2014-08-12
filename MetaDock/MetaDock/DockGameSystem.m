#import "DockGameSystem.h"

static NSString* kTitleKey = @"title";
static NSString* kTermsKey = @"terms";
static NSString* kZeroTermKey = @"zero";
static NSString* kOneTermKey = @"one";
static NSString* kManyTermKey = @"many";
static NSString* kPropertiesFileName = @"properties.json";

@interface DockGameSystem()
@property (strong, nonatomic) NSDictionary* terms;
@end

@implementation DockGameSystem
-(id)initWithPath:(NSString*)path
{
    self = [super init];
    if (self != nil) {
        [self setupIdentifier: path];
        [self loadProperties: path];
    }
    return self;
}

-(void)setupIdentifier:(NSString*)path
{
    NSString* folderName = [path lastPathComponent];
    _identifier = [folderName stringByDeletingPathExtension];
}

-(void)loadProperties:(NSString*)path
{
    assert(path != nil);
    NSString* propertiesPath = [path stringByAppendingPathComponent: kPropertiesFileName];
    NSError* error;
    NSData* data = [NSData dataWithContentsOfFile:propertiesPath options: 0 error: &error];
    if (data == nil) {
        @throw error;
    }
    id json = [NSJSONSerialization JSONObjectWithData: data options: 0 error: &error];
    if (json == nil) {
        @throw error;
    }
    assert([json isKindOfClass: [NSDictionary class]]);
    NSDictionary* properties = json;
    _title = properties[kTitleKey];
    _terms = properties[kTermsKey];
}

-(NSString*)term:(NSString*)term count:(int)count
{
    NSDictionary* termEntry = _terms[term];
    if (!termEntry) {
        return [NSString stringWithFormat: @"No term %@ in %@", term, self.identifier];
    }
    switch (count) {
        case 0:
            return termEntry[kZeroTermKey];
        case 1:
            return termEntry[kOneTermKey];
    }
    return termEntry[kManyTermKey];
}

@end
