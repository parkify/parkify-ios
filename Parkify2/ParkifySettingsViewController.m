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
#import "ParkifyAboutControllerViewController.h"
#import "Api.h"

@interface ParkifySettingsViewController ()

@end

@implementation ParkifySettingsViewController


@synthesize tableData = _tableData;
@synthesize tableImages = _tableImages;
@synthesize tableOnTap = _tableOnTap;


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
    
    self.tableData = [NSArray arrayWithObjects:@"Login/Logout", @"Account Settings", @"About", nil ];
    
    self.tableImages = [NSArray arrayWithObjects:@"glyphicons_204_unlock.png", @"glyphicons_003_user.png", @"glyphicons_195_circle_info.png", nil];
    
    
    
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

- (IBAction)aboutButtonTapped:(UIButton*)sender {
    self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:1];
}

- (IBAction)authButtonTapped:(UIButton *)sender {
    [Api authenticateModallyFrom:self withSuccess:^(NSDictionary *foo) {}];
}

- (IBAction)accountSettingsButtonTapped:(UIButton*)sender {
    ParkifyAboutViewController* accountSettings = [self.tabBarController.viewControllers objectAtIndex:2];
    
    accountSettings.url = @"https://api.parkify.me/my/account";

    self.tabBarController.selectedViewController =     accountSettings;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableData count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"simple_menu_item"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"simple_menu_item"];
    }
    
    cell.textLabel.text = [self.tableData objectAtIndex:indexPath.row];
    
    cell.imageView.image = [UIImage imageNamed:[self.tableImages objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    

    self.tableOnTap = [NSArray arrayWithObjects:^{
            [self authButtonTapped:nil];
        }, ^{
            ;
        }, ^{
            [self aboutButtonTapped:nil];
        }, nil];
    
    //int a = indexPath.row;
    ((CompletionBlock)[self.tableOnTap objectAtIndex:indexPath.row])();
}

@end
