#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Addons)
- (void)setNonNilObject:(id)anObject forKey:(id <NSCopying>)aKey;
@end
