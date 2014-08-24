#import "DockCategorized+Addons.h"

#import "DockCategory+Addons.h"

@implementation DockCategorized (Addons)

-(NSSet*)categoriesOfType:(NSString*)type
{
    id testCategoryType = ^(id obj, BOOL *stop) {
        DockCategory* category = obj;
        return [category.type isEqualToString: type];
    };
    
    return [self.categories objectsPassingTest: testCategoryType];
}

@end
