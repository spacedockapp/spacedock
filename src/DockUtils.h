#import <Foundation/Foundation.h>

@class DockSquad;

extern NSString* DockErrorDomain;

#if !TARGET_OS_IPHONE
NSAttributedString* coloredString(NSString* text, NSColor* color, NSColor* backColor);

#endif

NSSet* allAttributes(NSManagedObjectContext* context, NSString* entityName, NSString* attributeName);

NSAttributedString* makeCentered(NSAttributedString* s);
NSString* factionCode(id target);
NSString* resourceCost(DockSquad* targetSquad);
NSString* otherCost(DockSquad* targetSquad);
