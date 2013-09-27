#import <Cocoa/Cocoa.h>

@interface NSTreeController (Additions)
- (NSIndexPath*)indexPathOfObject:(id)anObject;
- (NSIndexPath*)indexPathOfObject:(id)anObject inNodes:(NSArray*)nodes;
@end
