#import <Foundation/Foundation.h>

typedef void (^ContextCreatedBlock)(NSPersistentStoreCoordinator* persistentStoreCoordinator, NSManagedObjectContext* newContext, NSError* error);

@interface DockCoreDataManager : NSObject
-(id)initWithStore:(NSURL*)storeURL model:(NSURL*)modelURL;
-(NSManagedObjectContext*)createContext:(NSManagedObjectContextConcurrencyType)concurrencyType error:(NSError**)error;
@end
