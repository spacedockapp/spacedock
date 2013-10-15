#import <Foundation/Foundation.h>

#if MAC
NSAttributedString* coloredString(NSString* text, NSColor* color, NSColor* backColor);
#endif

NSSet* allAttributes(NSManagedObjectContext* context, NSString* entityName, NSString* attributeName);
