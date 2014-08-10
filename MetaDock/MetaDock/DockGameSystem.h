#import <Foundation/Foundation.h>

@interface DockGameSystem : NSObject
@property (strong, nonatomic, readonly) NSString* title;
@property (strong, nonatomic, readonly) NSString* identifier;
@property (strong, nonatomic, readonly) NSSet* components;
-(id)initWithPath:(NSString*)path;
@end
