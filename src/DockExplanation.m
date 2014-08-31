#import "DockExplanation.h"

@implementation DockExplanation

+(DockExplanation*)success
{
    static DockExplanation* sSuccess = nil;
    if (sSuccess == nil) {
        sSuccess = [[DockExplanation alloc] init];
    }
    return sSuccess;
}

-(id)init
{
    self = [super init];
    if (self != nil) {
        _canAdd = YES;
    }
    return self;
}

-(id)initWithResult:(NSString*)result explanation:(NSString*)explanation
{
    self = [super init];
    if (self != nil) {
        _canAdd = NO;
        _explanation = explanation;
        _result = result;
    }
    return self;
}

@end
