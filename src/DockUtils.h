#import <Foundation/Foundation.h>

#import "DockFactioned.h"
#import "DockUnique.h"

@class DockEquippedUpgrade;
@class DockSquad;

NSString* intToString(int v);
NSSet* allAttributes(NSManagedObjectContext* context, NSString* entityName, NSString* attributeName);

NSAttributedString* makeCentered(NSAttributedString* s);
NSString* factionCode(id target);
NSString* resourceCost(DockSquad* targetSquad);
NSString* otherCost(DockSquad* targetSquad);
NSString* costString(DockEquippedUpgrade* equippedUpgrade);
NSArray* actionStrings(id target);
BOOL targetHasFaction(NSString* faction, id<DockFactioned> target);
BOOL factionsMatch(id<DockFactioned> a, id<DockFactioned> b);
NSString* combinedFactionString(id<DockFactioned> a);
NSString* uniqueAsString(id<DockUnique> a);

NSURL* applicationFilesDirectory(void);
