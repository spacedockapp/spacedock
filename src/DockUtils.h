#import <Foundation/Foundation.h>

extern NSString* DockErrorDomain;

#if !TARGET_OS_IPHONE
NSAttributedString* coloredString(NSString* text, NSColor* color, NSColor* backColor);
#endif

NSSet* allAttributes(NSManagedObjectContext* context, NSString* entityName, NSString* attributeName);