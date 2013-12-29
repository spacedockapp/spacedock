#import "DockDataLoader.h"

#import "DockConstants.h"
#import "DockDataFileLoader.h"

@interface DockDataLoader () {
    DockDataFileLoader* _loader;
    NSManagedObjectContext* _managedObjectContext;
}
@end

@implementation DockDataLoader

-(id)initWithContext:(NSManagedObjectContext*)context
{
    self = [super init];
    if (self) {
        _managedObjectContext = context;
    }
    return self;
}

-(NSString*)currentDataVersion
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey: kSpaceDockCurrentDataVersionKey];
}

-(NSString*)loadDataForVersion:(NSString*)currentVersion filePath:(NSString*)filePath error:(NSError**)error
{
    _loader = [[DockDataFileLoader alloc] initWithContext: _managedObjectContext
                                                             version: currentVersion];
    if ([_loader loadData: filePath force: NO error: error]) {
        return _loader.dataVersion;
    }
    
    return nil;
}

-(BOOL)loadDataFromPath:(NSString*)filePath error:(NSError**)error
{
    NSString* currentVersion = [self currentDataVersion];

    NSString* dataVersion = [self loadDataForVersion: currentVersion filePath: filePath error: error];
    if (dataVersion != nil) {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject: dataVersion forKey: kSpaceDockCurrentDataVersionKey];
    }
    
    return YES;
}

-(NSSet*)validateSpecials
{
    return [_loader validateSpecials];
}

-(NSString*)internalDataFile
{
    return [[NSBundle mainBundle] pathForResource: @"Data" ofType: @"xml"];
}

-(NSURL*)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory inDomains: NSUserDomainMask] lastObject];
}

-(NSString*)externalDataFile
{
    NSString* appData = [[self applicationDocumentsDirectory] path];
    NSString* xmlFile = [appData stringByAppendingPathComponent: @"Data.xml"];
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL isDirectory;
    if ([fm fileExistsAtPath: xmlFile isDirectory: &isDirectory]) {
        return xmlFile;
    }
    
    return nil;
}

-(NSString*)selectNewestDataFile
{
    NSString* externalFile = [self externalDataFile];
    NSString* internalFile = [self internalDataFile];
    if (externalFile == nil) {
        return internalFile;
    }
    DockDataFileLoader* internalLoader = [[DockDataFileLoader alloc] init];
    NSString* internalVersion = [internalLoader getVersion: internalFile];
    float internalVersionValue = [internalVersion floatValue];
    DockDataFileLoader* externalLoader = [[DockDataFileLoader alloc] init];
    NSString* externalVersion = [externalLoader getVersion: internalFile];
    float externalVersionValue = [externalVersion floatValue];
    if (internalVersionValue >= externalVersionValue) {
        NSFileManager* fm = [NSFileManager defaultManager];
        [fm removeItemAtPath: externalFile error: nil];
    }
    return externalFile;
}

-(BOOL)loadData:(NSError**)error
{
    NSString* targetPath = [self selectNewestDataFile];
    return [self loadDataFromPath: targetPath error: error];
}

@end
