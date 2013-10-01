#import "NSTreeController+Additions.h"

// Thanks to http://stackoverflow.com/a/9050488

@implementation NSTreeController (Additions)

-(NSIndexPath*)indexPathOfObject:(id)anObject
{
    return [self indexPathOfObject: anObject inNodes: [[self arrangedObjects] childNodes]];
}

-(NSIndexPath*)indexPathOfObject:(id)anObject inNodes:(NSArray*)nodes
{
    for (NSTreeNode* node in nodes) {
        if ([[node representedObject] isEqual: anObject]) {
            return [node indexPath];
        }

        if ([[node childNodes] count]) {
            NSIndexPath* path = [self indexPathOfObject: anObject inNodes: [node childNodes]];

            if (path) {
                return path;
            }
        }
    }
    return nil;
}

@end
