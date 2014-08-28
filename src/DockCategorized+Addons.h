#import "DockCategorized.h"

@interface DockCategorized (Addons)
-(NSSet*)categoriesOfType:(NSString*)type;
-(NSSet*)valuesForCategoriesOfType:(NSString*)type;
-(BOOL)hasCategoryType:(NSString*)type withValue:(NSString*)value;
@end
