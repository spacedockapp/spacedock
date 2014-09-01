#import "DockTagHandler.h"

#import "DockShipClassContainsTagHandler.h"

@interface DockShipClassContainsRestriction : DockShipClassContainsTagHandler<DockRestrictionTag>
-(id)initWithShipClassSubstrings:(NSArray*)shipClassSubstrings explanationFragment:(NSString*)explanationFragment;
@end
