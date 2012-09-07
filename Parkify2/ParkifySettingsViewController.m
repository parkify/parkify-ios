//
//  ParkifySettingsViewController.m
//  Parkify
//
//  Created by Me on 8/24/12.
//
//

#import "ParkifySettingsViewController.h"
#import "ModalSettingsController.h"
#import "UITabBarController+Hide.h"
#import "Api.h"

@interface ParkifySettingsViewController ()

@end

@implementation ParkifySettingsViewController

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tabBarController showTabBar:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)cancelButtonTapped:(UIBarButtonItem *)sender {
    //Escape from modal
    NSDictionary* results = [NSDictionary dictionaryWithObjectsAndKeys:@"cancel",@"exit", nil];
    [((ModalSettingsController*)self.tabBarController) exitWithResults:results];

}

- (IBAction)aboutButtonTapped:(id)sender {
    self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:1];
}

- (IBAction)authButtonTapped:(UIButton *)sender {
    [Api authenticateModallyFrom:self withSuccess:^(NSDictionary *foo) {}];
}


@end
