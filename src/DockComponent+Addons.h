#import "DockComponent.h"

@interface DockComponent (Addons)
-(NSString*)anySetExternalId;
-(NSString*)factionCode;
-(NSString*)setName;
-(NSComparisonResult)compareForSet:(id)object;
-(NSString*)itemDescription;
-(NSString*)setCode;
@end
