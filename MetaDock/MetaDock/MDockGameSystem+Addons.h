#import "MDockGameSystem.h"

@interface MDockGameSystem (Addons)
+(MDockGameSystem*)gameSystemWithId:(NSString*)id context:(NSManagedObjectContext*)context;
+(MDockGameSystem*)createGameSystemWithId:(NSString*)id context:(NSManagedObjectContext*)context;
+(NSArray*)gameSystems:(NSManagedObjectContext*)context;
-(void)updateFromPath:(NSString*)path;
-(NSString*)term:(NSString*)term count:(int)count;
@end
