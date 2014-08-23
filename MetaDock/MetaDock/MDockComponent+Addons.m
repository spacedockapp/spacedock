#import "MDockComponent+Addons.h"

#import "MDockCategory+Addons.h"
#import "MDockGameSystem+Addons.h"
#import "MDockIntProperty+Addons.h"
#import "MDockProperty+Addons.h"

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

    NSArray* propertyData = componentData[@"properties"];
    for (NSDictionary* oneProperty in propertyData) {
        NSString* propertyName = oneProperty[@"name"];
        id propertyValue = oneProperty[@"value"];
        MDockIntProperty* property = [self findOrCreateIntPropertyWithName: propertyName];
        property.val = [propertyValue intValue];
    }
}

// properties
-(MDockProperty*)findPropertyWithName:(NSString*)name
{
    for (MDockProperty* property in self.properties) {
        if ([name isEqualToString: property.name]) {
            return property;
        }
    }
    return nil;
}

-(MDockIntProperty*)findIntPropertyWithName:(NSString*)name
{
    for (MDockProperty* property in self.properties) {
        if ([name isEqualToString: property.name] && [property isKindOfClass: [MDockIntProperty class]]) {
            return (MDockIntProperty*)property;
        }
    }
    return nil;
}

-(MDockIntProperty*)findOrCreateIntPropertyWithName:(NSString*)name
{
    MDockIntProperty* property = [self findIntPropertyWithName: name];
    if (property == nil) {
        NSManagedObjectContext* context = self. managedObjectContext;
        NSEntityDescription* propertyEntity = [NSEntityDescription entityForName: kIntPropertyEntityName inManagedObjectContext: context];
        property = [[MDockIntProperty alloc] initWithEntity: propertyEntity insertIntoManagedObjectContext: self.managedObjectContext];
        property.name = name;
        [self addPropertiesObject: property];
    }
    return property;
}

@end
