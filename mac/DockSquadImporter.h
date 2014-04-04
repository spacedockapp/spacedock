#import <Foundation/Foundation.h>

extern NSString* createAmountTermFormat(NSString* format1, NSString* format2, NSInteger count, NSString* actionVerb);
extern NSString* createAmountTerm(NSInteger count, NSString* actionVerb);

@interface DockSquadImporter : NSObject
@property (readonly, assign) int replaceCount;
@property (readonly, assign) int newCount;
@property (strong, nonatomic) NSString* path;
@property (strong, nonatomic) NSMutableArray* notExistingData; // ARC doesn't like the term "new" here
@property (strong, nonatomic) NSMutableArray* existingData;
@property (strong, nonatomic) NSDictionary* squadsByUUID;
@property (strong, nonatomic) NSManagedObjectContext* context;
@property (assign, nonatomic) BOOL importOK;
-(id)initWithPath:(NSString*)path context:(NSManagedObjectContext*)context;
-(void)performImport;
-(void)examineImport:(id)window;
@end
