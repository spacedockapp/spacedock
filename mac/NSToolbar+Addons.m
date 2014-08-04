#import "NSToolbar+Addons.h"

@implementation NSToolbar (Addons)

-(NSToolbarItem*)itemWithIdentifier:(NSString*)identifier
{
    id finder = ^(id obj, NSUInteger idx, BOOL *stop) {
        NSToolbarItem* item = obj;
        return [item.itemIdentifier isEqualToString: identifier];
    };
    NSArray* items = self.items;
    NSInteger itemIndex = [items indexOfObjectPassingTest: finder];
    if (itemIndex == NSNotFound) {
        return nil;
    }
    return items[itemIndex];
}

@end
