#import <Foundation/Foundation.h>

@interface NSString (Addons)
-(NSComparisonResult)compareDegrees:(NSString *)string;
-(NSArray*)strippedComponentsSeparatedByString:(NSString *)separator;
@end
