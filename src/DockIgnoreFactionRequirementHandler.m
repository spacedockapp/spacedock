#import "DockIgnoreFactionRequirementHandler.h"

#import "DockComponent+Addons.h"
#import "DockUpgrade+Addons.h"

@interface DockIgnoreFactionRequirementHandler ()
@property (strong,nonatomic) NSSet* types;
@end

@implementation DockIgnoreFactionRequirementHandler

-(id)initWithTypes:(NSSet*)types
{
    self = [super init];
    if (self != nil) {
        self.types = types;
    }
    return self;
}

#pragma mark - Tag attributes

-(BOOL)ignoresFactionRestrictions:(DockUpgrade*)upgrade
{
    return [self.types intersectsSet: upgrade.types];
}

@end
