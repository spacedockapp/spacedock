#import <Foundation/Foundation.h>

@interface DockExplanation : NSObject
@property (assign, readonly, nonatomic) BOOL canAdd;
@property (strong, readonly, nonatomic) NSString* result;
@property (strong, readonly, nonatomic) NSString* explanation;

+(DockExplanation*)success;
-(id)initWithResult:(NSString*)result explanation:(NSString*)explanation;
-(id)init;
@end
