#import "DockShip.h"

extern NSAttributedString* styledAttack(id ship);
extern NSAttributedString* styledAgility(id ship);
extern NSAttributedString* styledHull(id ship);
extern NSAttributedString* styledShield(id ship);

@interface DockShip (MacAddons)
-(NSAttributedString*)styledAttack;
@end
