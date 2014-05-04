#import <Cocoa/Cocoa.h>

@interface DockPaginatedTableView : NSTableView {
  NSMutableArray* _topBorderRows;
  NSMutableArray* _bottomBorderRows;
}
@end

