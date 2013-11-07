#import "DockUpgradeDetailViewController.h"

#import "DockCaptain+Addons.h"
#import "DockUpgrade+Addons.h"
#import "DockWeapon+Addons.h"

@interface DockUpgradeDetailViewController ()

@end

@implementation DockUpgradeDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    DockUpgrade* upgrade = self.upgrade;

    self.abilityField.text = upgrade.ability;
    self.titleField.text = upgrade.title;
    self.costField.text = [upgrade.cost stringValue];
    self.upTypeField.text = upgrade.upType;
    BOOL isWeapon = [upgrade isWeapon];
    BOOL isCaptain = [upgrade isCaptain];
    self.attackField.hidden = !isWeapon;
    self.rangeField.hidden = !isWeapon;
    self.captainSkill.hidden = !isCaptain;
    self.upTypeField.hidden = isCaptain;
    if (isWeapon) {
        DockWeapon* weapon = (DockWeapon*)upgrade;
        self.attackField.text = [weapon.attack stringValue];
        self.rangeField.text = weapon.range;
    } else if (isCaptain) {
        DockCaptain* captain = (DockCaptain*)upgrade;
        self.captainSkill.text = [captain.skill stringValue];
    }
    [self.abilityField sizeToFit];
}

@end
