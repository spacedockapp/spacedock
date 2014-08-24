#import "DockCoreDataManager.h"

@interface DockCoreDataManager()
@property (atomic, strong) NSManagedObjectModel* managedObjectModel;
@property (atomic, strong) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (atomic, strong) NSURL* storeURL;
@property (atomic, strong) NSURL* modelURL;
@end

@implementation DockCoreDataManager

-(id)initWithStore:(NSURL*)storeURL model:(NSURL*)modelURL
{
    self = [super init];
    if (self != nil) {
        _storeURL = storeURL;
        _modelURL = modelURL;
    }
    return self;
}

-(NSManagedObjectContext*)createContext:(NSManagedObjectContextConcurrencyType)concurrencyType error:(NSError**)error;
{
    if (_managedObjectModel == nil) {
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: _modelURL];
    }

    if (_persistentStoreCoordinator == nil) {
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: _managedObjectModel];
        NSDictionary* options = @{
                                  NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES
                                  };
        NSPersistentStore* store = [_persistentStoreCoordinator addPersistentStoreWithType: NSInMemoryStoreType //NSBinaryStoreType
                                                         configuration: nil
                                                                   URL: _storeURL
                                                               options: options error: error];
        if (store == nil) {
            return nil;
        }
    }


    NSManagedObjectContext* managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: concurrencyType];
    [managedObjectContext setPersistentStoreCoordinator: _persistentStoreCoordinator];
    return managedObjectContext;
}

@end
