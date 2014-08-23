#import "MDockComponent+Addons.h"

#import "MDockCategory+Addons.h"
#import "MDockGameSystem+Addons.h"

@implementation MDockComponent (Addons)

-(void)update:(NSDictionary*)componentData
{
    self.title = componentData[@"title"];
    MDockGameSystem* gameSystem = self.gameSystem;
    NSArray* categoryData = componentData[@"categories"];
    for (NSDictionary* oneCategory in categoryData) {
        NSString* categoryType = oneCategory[@"type"];
        NSString* categoryValue = oneCategory[@"value"];
        MDockCategory* category = [gameSystem findCategory: categoryType value: categoryValue];
        if (category == nil) {
            category = [gameSystem createCategory: categoryType value: categoryValue];
        }
        [self addCategoriesObject: category];
    }
}

@end
