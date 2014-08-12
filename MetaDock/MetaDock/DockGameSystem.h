#import <Foundation/Foundation.h>

@interface DockGameSystem : NSObject
@property (strong, nonatomic, readonly) NSString* title;
@property (strong, nonatomic, readonly) NSString* identifier;
-(id)initWithPath:(NSString*)path;
-(NSString*)term:(NSString*)term count:(int)count;
@end
