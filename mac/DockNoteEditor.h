#import <Foundation/Foundation.h>

@class DockSquad;

@interface DockNoteEditor : NSObject
@property (strong, nonatomic) NSString* notes;
@property (strong, nonatomic) NSString* additionalPoints;
-(void)show:(DockSquad*)targetSquad;
@end
