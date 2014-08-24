#import "DockComponent.h"

extern NSString* kDockFactionCategoryType;

@interface DockComponent (Addons)
-(NSSet*)factions;
-(NSString*)highestFaction;
-(NSArray*)factionsSortedByInitiative;
-(BOOL)hasFaction:(NSString*)faction;
-(NSString*)combinedFactions;
-(NSString*)anySetExternalId;
-(NSString*)factionCode;
-(NSString*)setName;
-(NSComparisonResult)compareForSet:(id)object;
-(NSString*)itemDescription;
-(NSString*)setCode;
@end
