#import <Foundation/Foundation.h>

@class MDockGameSystem;

@interface DockUniverse : NSObject
-(id)initWithContext:(NSManagedObjectContext*)context templatesPath:(NSString*)templatesPath;
-(MDockGameSystem*)gameSystemWithIdentifier:(NSString*)identifier;
-(NSArray*)gameSystems;
@end
