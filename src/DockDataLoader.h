#import <Foundation/Foundation.h>

@interface DockDataLoader : NSObject
@property (readonly, weak, nonatomic) NSManagedObjectContext* managedObjectContext;
-(id)initWithContext:(NSManagedObjectContext*)context;
-(BOOL)loadData:(NSError**)error;
-(NSSet*)validateSpecials;
@end
