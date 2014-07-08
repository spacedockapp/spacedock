#import <Foundation/Foundation.h>

@interface DockDataFileLoader : NSObject<NSXMLParserDelegate>
@property (strong, nonatomic) NSMutableDictionary* parsedData;
@property (strong, nonatomic) NSMutableDictionary* currentElement;
@property (strong, nonatomic) NSDictionary* currentAttributes;
@property (strong, nonatomic) NSDictionary* allSets;
@property (strong, nonatomic) NSMutableArray* currentList;
@property (strong, nonatomic) NSMutableArray* elementNameStack;
@property (strong, nonatomic) NSMutableArray* listStack;
@property (strong, nonatomic) NSMutableArray* elementStack;
@property (strong, nonatomic) NSMutableString* currentText;
@property (strong, nonatomic) NSSet* listElementNames;
@property (strong, nonatomic) NSSet* itemElementNames;
@property (strong, nonatomic) NSString* currentVersion;
@property (strong, nonatomic) NSString* dataVersion;
@property (assign, nonatomic) BOOL versionMatched;
@property (readonly, weak, nonatomic) NSManagedObjectContext* managedObjectContext;
-(id)initWithContext:(NSManagedObjectContext*)context version:(NSString*)version;
-(BOOL)loadData:(NSString*)pathToDataFile force:(BOOL)force error:(NSError**)error;
-(NSString*)getVersion:(NSString*)pathToDataFile;
-(NSSet*)validateSpecials;
@end
