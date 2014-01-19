#import "NSMutableDictionary+Addons.h"

@implementation NSMutableDictionary (Addons)

- (void)setNonNilObject:(id)anObject forKey:(id <NSCopying>)aKey
{
    if (anObject != nil) {
        [self setObject: anObject forKey: aKey];
    }
}

@end
