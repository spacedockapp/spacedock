#import <Foundation/Foundation.h>

@interface DockDataModelExporter : NSObject
-(BOOL)doExport:(NSString*)targetFolder error:(NSError**)error;
@end
