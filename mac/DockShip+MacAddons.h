#import "DockShip.h"

extern NSAttributedString* styledAttack(NSString* v);
extern NSAttributedString* styledAgility(NSString* v);
extern NSAttributedString* styledHull(NSString* v);
extern NSAttributedString* styledShield(NSString* v);

extern NSString* toString(int);

@interface DockShip (MacAddons)
-(NSAttributedString*)styledDescription;
@end
