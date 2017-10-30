#import <Foundation/Foundation.h>

BOOL saveItem(id targetItem, NSError** error);
BOOL isOS7OrGreater(void);
void presentUnsuppportedFeatureDialog(void);
void presentError(NSError* error);
