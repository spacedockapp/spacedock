#import "DockSet.h"

@interface DockSet (Addons)
+(DockSet*)setForId:(NSString*)setId context:(NSManagedObjectContext*)context;
+(NSArray*)allSets:(NSManagedObjectContext*)context;
+(NSArray*)includedSets:(NSManagedObjectContext*)context;
@end
