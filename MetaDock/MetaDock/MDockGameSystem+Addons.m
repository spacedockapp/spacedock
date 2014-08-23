#import "MDockGameSystem+Addons.h"

#import "MDockCategory+Addons.h"
#import "MDockComponent+Addons.h"

@implementation MDockGameSystem (Addons)

NSString* kTitleKey = @"title";
NSString* kTermsKey = @"terms";
NSString* kZeroTermKey = @"zero";
NSString* kOneTermKey = @"one";
NSString* kManyTermKey = @"many";
NSString* kPropertiesFileName = @"properties.json";
NSString* kGameSystemEntityName = @"GameSystem";
NSString* kComponentEntityName = @"Component";
NSString* kCategoryEntityName = @"Category";
NSString* kPropertyEntityName = @"Property";
NSString* kIntPropertyEntityName = @"IntProperty";


+(MDockGameSystem*)gameSystemWithId:(NSString*)systemId context:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"GameSystem" inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"systemId == %@", systemId];
    [request setPredicate: predicateTemplate];
    NSError* err;
    NSArray* existingItems = [context executeFetchRequest: request error: &err];

    if (existingItems.count > 0) {
        return existingItems[0];
    }

    return nil;
}

+(MDockGameSystem*)createGameSystemWithId:(NSString*)systemId context:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: kGameSystemEntityName inManagedObjectContext: context];
    assert(entity);
    MDockGameSystem* gameSystem = [[MDockGameSystem alloc] initWithEntity: entity insertIntoManagedObjectContext: context];
    gameSystem.systemId = systemId;
    return gameSystem;
}

+(NSArray*)gameSystems:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: kGameSystemEntityName inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSError* err;
    return [context executeFetchRequest: request error: &err];
}

-(void)setupIdentifier:(NSString*)path
{
    NSString* folderName = [path lastPathComponent];
    self.systemId = [folderName stringByDeletingPathExtension];
}

-(void)loadProperties:(NSString*)path
{
    assert(path != nil);
    NSString* propertiesPath = [path stringByAppendingPathComponent: kPropertiesFileName];
    NSError* error;
    NSData* data = [NSData dataWithContentsOfFile:propertiesPath options: 0 error: &error];
    if (data == nil) {
        @throw error;
    }
    id json = [NSJSONSerialization JSONObjectWithData: data options: 0 error: &error];
    if (json == nil) {
        @throw error;
    }
    assert([json isKindOfClass: [NSDictionary class]]);
    NSDictionary* properties = json;
    self.title = properties[kTitleKey];
    self.terms = properties[kTermsKey];
    NSString* setsPath = [path stringByAppendingPathComponent: @"sets"];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSArray* sets = [fm contentsOfDirectoryAtPath: setsPath error: &error];
    NSEntityDescription* componentEntity = [NSEntityDescription entityForName: kComponentEntityName
                                              inManagedObjectContext: self.managedObjectContext];
    for (NSString* setFileName in sets) {
        NSString* oneSetPath = [setsPath stringByAppendingPathComponent: setFileName];
        data = [NSData dataWithContentsOfFile: oneSetPath options: 0 error: &error];
        if (data == nil) {
            @throw error;
        }
        id json = [NSJSONSerialization JSONObjectWithData: data options: 0 error: &error];
        if (json == nil) {
            @throw error;
        }
        assert([json isKindOfClass: [NSDictionary class]]);
        NSDictionary* setDictionary = json;
        NSArray* components = setDictionary[@"components"];
        for (NSDictionary* oneComponent in components) {
            MDockComponent* component = [[MDockComponent alloc] initWithEntity: componentEntity
                                                insertIntoManagedObjectContext: self.managedObjectContext];
            [self addComponentsObject: component];
            [component update: oneComponent];
        }
    }
    [self.managedObjectContext save: &error];
}

-(void)updateFromPath:(NSString*)path
{
    [self setupIdentifier: path];
    [self loadProperties: path];
}

-(NSString*)term:(NSString*)term count:(int)count;
{
    NSDictionary* terms = self.terms;
    NSDictionary* termEntry = terms[term];
    if (!termEntry) {
        return [NSString stringWithFormat: @"No term %@ in %@", term, self.systemId];
    }
    switch (count) {
        case 0:
            return termEntry[kZeroTermKey];
        case 1:
            return termEntry[kOneTermKey];
    }
    return termEntry[kManyTermKey];
    return terms[term];
}

// components
-(NSArray*)findComponentsWithTitle:(NSString*)title
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: kComponentEntityName inManagedObjectContext: self.managedObjectContext];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"title like %@", title];
    [request setPredicate: predicateTemplate];
    NSError* err;
    return [self.managedObjectContext executeFetchRequest: request error: &err];
}

// categories

-(MDockCategory*)findCategory:(NSString*)type value:(NSString*)value
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: kCategoryEntityName inManagedObjectContext: self.managedObjectContext];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"type == %@ and value == %@", type, value];
    [request setPredicate: predicateTemplate];
    NSError* err;
    NSArray* categories = [self.managedObjectContext executeFetchRequest: request error: &err];
    return categories.firstObject;
}

-(MDockCategory*)createCategory:(NSString*)type value:(NSString*)value
{
    NSEntityDescription* categoryEntity = [NSEntityDescription entityForName: kCategoryEntityName inManagedObjectContext: self.managedObjectContext];
    MDockCategory* category = [[MDockCategory alloc] initWithEntity: categoryEntity insertIntoManagedObjectContext: self.managedObjectContext];
    category.type = type;
    category.value = value;
    [self addCategoriesObject: category];
    return category;
}

@end
