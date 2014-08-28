#import "DockComponent.h"

extern NSString* kDockFactionCategoryType;
extern NSString* kDockTypeCategoryType;

@interface DockComponent (Addons)

// factions
-(NSSet*)factions;
-(NSString*)highestFaction;
-(NSArray*)factionsSortedByInitiative;
-(BOOL)hasFaction:(NSString*)faction;
-(NSString*)combinedFactions;
-(NSString*)factionCode;

// types
-(NSSet*)types;
-(BOOL)hasType:(NSString*)type;
-(NSString*)combinedTypes;

// sets
-(NSString*)anySetExternalId;
-(NSString*)setName;
-(NSComparisonResult)compareForSet:(id)object;
-(NSString*)itemDescription;
-(NSString*)setCode;
@end
