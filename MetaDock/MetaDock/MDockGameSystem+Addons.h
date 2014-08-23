#import "MDockGameSystem.h"

NSString* kTitleKey;
NSString* kTermsKey;
NSString* kZeroTermKey;
NSString* kOneTermKey;
NSString* kManyTermKey;
NSString* kPropertiesFileName;
NSString* kGameSystemEntityName;
NSString* kComponentEntityName;
NSString* kCategoryEntityName;

@interface MDockGameSystem (Addons)

// loading and updating
+(MDockGameSystem*)gameSystemWithId:(NSString*)id context:(NSManagedObjectContext*)context;
+(MDockGameSystem*)createGameSystemWithId:(NSString*)id context:(NSManagedObjectContext*)context;
+(NSArray*)gameSystems:(NSManagedObjectContext*)context;
-(void)updateFromPath:(NSString*)path;

// customization
-(NSString*)term:(NSString*)term count:(int)count;

// components
-(NSArray*)findComponentsWithTitle:(NSString*)title;

// categories
-(MDockCategory*)findCategory:(NSString*)type value:(NSString*)value;
-(MDockCategory*)createCategory:(NSString*)type value:(NSString*)value;
@end
