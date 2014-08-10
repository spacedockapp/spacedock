#import <Foundation/Foundation.h>

@interface DockUniverse : NSObject
@property (readonly, nonatomic, strong) NSSet* gameSystems;
-(id)initWithDataStorePath:(NSString*)dataStore templatesPath:(NSString*)templatesPath;
@end
