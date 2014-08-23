#import "MDockGameSystem.h"

extern NSString* kTitleKey;
extern NSString* kTermsKey;
extern NSString* kZeroTermKey;
extern NSString* kOneTermKey;
extern NSString* kManyTermKey;
extern NSString* kPropertiesFileName;
extern NSString* kGameSystemEntityName;
extern NSString* kComponentEntityName;
extern NSString* kCategoryEntityName;
extern NSString* kPropertyEntityName;
extern NSString* kIntPropertyEntityName;

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
