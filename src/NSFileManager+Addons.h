#import <Foundation/Foundation.h>

@interface NSFileManager (Addons)
- (NSArray *)sortedContentsOfDirectoryAtPath:(NSString *)path error:(NSError **)error;
@end
