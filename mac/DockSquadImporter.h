#import <Foundation/Foundation.h>

@interface DockSquadImporter : NSObject
@property (readonly, assign) int replaceCount;
@property (readonly, assign) int newCount;
-(id)initWithPath:(NSString*)path context:(NSManagedObjectContext*)context;
-(void)examineImport:(NSWindow*)window;
@end
