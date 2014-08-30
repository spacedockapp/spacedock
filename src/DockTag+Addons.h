#import "DockTag.h"

extern NSString* kDockTagEntityName;

@interface DockTag (Addons)
+(NSString*)categoryTag:(NSString*)type value:(NSString*)value;
+(NSString*)categoryValue:(NSString*)categoryTag;
+(DockTag*)findOrCreateCategoryTag:(NSString*)type value:(NSString*)value context:(NSManagedObjectContext*)context;
@end
