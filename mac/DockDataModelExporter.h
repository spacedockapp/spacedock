#import <Foundation/Foundation.h>

@interface DockDataModelExporter : NSObject
-(id)initWithContext:(NSManagedObjectContext*)context;
-(BOOL)doExport:(NSString*)targetFolder error:(NSError**)error;
@end
