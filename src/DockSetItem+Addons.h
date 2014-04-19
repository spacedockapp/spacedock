#import "DockSetItem.h"

@interface DockSetItem (Addons)
-(NSString*)anySetExternalId;
-(NSString*)factionCode;
-(NSString*)setName;
-(NSComparisonResult)compareForSet:(id)object;
@end
