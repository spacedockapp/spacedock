#import "DockCategory.h"

extern NSString* kDockCategoryEntityName;

@interface DockCategory (Addons)
+(DockCategory*)findOrCreateCategory:(NSString*)type value:(NSString*)value context:(NSManagedObjectContext*)context;
@end
