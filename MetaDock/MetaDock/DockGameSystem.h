#import <Foundation/Foundation.h>

@interface DockGameSystem : NSObject
@property (strong, nonatomic, readonly) NSString* title;
-(id)initWithPath:(NSString*)path;
@end
