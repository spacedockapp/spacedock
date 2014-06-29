#import <Foundation/Foundation.h>

@interface DockCompilationExporter : NSObject
-(id)initWithPath:(NSString*)path;
-(BOOL)export:(NSManagedObjectContext*)context error:(NSError**)error;
@end
