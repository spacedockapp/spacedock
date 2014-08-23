#import "MDockComponent.h"

@class MDockIntProperty;

@interface MDockComponent (Addons)
-(void)update:(NSDictionary*)componentData;

// properties
-(MDockProperty*)findPropertyWithName:(NSString*)name;
-(MDockIntProperty*)findIntPropertyWithName:(NSString*)name;
-(MDockIntProperty*)findOrCreateIntPropertyWithName:(NSString*)name;
@end
