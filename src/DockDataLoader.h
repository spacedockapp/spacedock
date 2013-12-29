#import <Foundation/Foundation.h>

@interface DockDataLoader : NSObject
-(id)initWithContext:(NSManagedObjectContext*)context;
-(NSSet*)validateSpecials;
-(BOOL)loadData:(NSError**)error;
@end
