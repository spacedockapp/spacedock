#import <Foundation/Foundation.h>

extern NSString* kCurrentSearchTerm;

@interface DockSearchFieldController : NSObject
-(void)clear;
-(BOOL)hasSearchTerm;
@end
