//
//  ParkifyAbioutControllerViewController.m
//  Parkify
//
//  Created by Me on 8/24/12.
//
//

#import "ParkifyAboutControllerViewController.h"
#import "ModalSettingsController.h"
#import "UITabBarController+Hide.h"

@interface ParkifyAboutViewController ()

@end

@implementation ParkifyAboutViewController
@synthesize viewWeb;

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
    NSString *fullURL = @"http://www.parkify.me/about?view=iphone";
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [viewWeb loadRequest:requestObj];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tabBarController showTabBar:NO];
}

- (void)viewDidUnload
{
    [self setViewWeb:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)closeButtonTapped:(UIBarButtonItem *)sender {
    self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
}
@end
