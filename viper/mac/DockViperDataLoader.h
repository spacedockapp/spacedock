#import <Foundation/Foundation.h>

@interface DockViperDataLoader : NSObject
-(id)initWithContext:(NSManagedObjectContext*)context pathToDataFiles:(NSString*)pathToDataFiles;
-(BOOL)loadData:(NSError**)error;
@end
