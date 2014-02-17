#import <Foundation/Foundation.h>

BOOL saveItem(id targetItem, NSError** error);
BOOL isOS7OrGreater();
void presentUnsuppportedFeatureDialog();
void presentError(NSError* error);
