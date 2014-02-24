#import <Foundation/Foundation.h>

@interface DockWeaponRange : NSObject
@property (nonatomic, assign) NSRange range;
-(id)initWithString:(NSString*)range;
@end
