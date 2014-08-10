#import <Foundation/Foundation.h>

@class DockGameSystem;

@interface DockUniverse : NSObject
@property (readonly, nonatomic, strong) NSSet* gameSystems;
-(id)initWithDataStorePath:(NSString*)dataStore templatesPath:(NSString*)templatesPath;

-(DockGameSystem*)gameSystemWithIdentifier:(NSString*)identifier;
@end
