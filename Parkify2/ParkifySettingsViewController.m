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
#import "Persistance.h"
#import "User.h"
#import "AccountSettingsTableViewController.h"
#import "AccountSettingsNavigationViewController.h"
#import "UIViewController+AppData_User.h"
#import "ErrorTransformer.h"
#import "IntroViewController.h"

//#import "PlacedAgent.h"

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
    
    
    
    //[PlacedAgent logPageView:@"SettingsView"];
    
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tabBarController showTabBar:NO];
    
    NSString* loginLogoutString = @"Login/Register";
    NSString* loginLogoutIconString = @"glyphicons_204_unlock.png";
    
    if([Persistance retrieveAuthToken]) {
        //Logged in
        loginLogoutString = @"Logout";
        loginLogoutIconString = @"glyphicons_203_lock.png";
    }
    
    /*
    self.tableData = [NSArray arrayWithObjects:loginLogoutString, @"Account Settings", @"Share", @"About", nil ];
    
    self.tableImages = [NSArray arrayWithObjects:loginLogoutIconString, @"glyphicons_003_user.png", @"glyphicons_003_user.png", @"glyphicons_195_circle_info.png", nil];
     */
    self.tableData = [NSArray arrayWithObjects:loginLogoutString, @"Account Settings", @"About", nil ];
    
    self.tableImages = [NSArray arrayWithObjects:loginLogoutIconString, @"glyphicons_003_user.png", @"glyphicons_195_circle_info.png", nil];
    
    [self.tableView reloadData];
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
    ((IntroViewController*)self.tabBarController.selectedViewController).openedFromSettings = true;
}


- (IBAction)shareButtonTapped:(UIButton*)sender {
    NSString* authToken = [Persistance retrieveAuthToken];
    if(!authToken) {
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please log in first" delegate:self cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [error show];
    } else {
        [[self getUser] clear];
        [[self getUser] updateFromServerWithSuccess:^(NSDictionary * d) {
            self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:3];
            
        } withFailure:^(NSError * e) {
            [ErrorTransformer errorToAlert:e withDelegate:self];
        }];
    }

    
}


- (IBAction)authButtonTapped:(UIButton *)sender {
    [Api authenticateModallyFrom:self withSuccess:^(NSDictionary *foo) {}];
}

- (IBAction)accountSettingsButtonTapped:(UIButton*)sender {
    NSString* authToken = [Persistance retrieveAuthToken];
    if(!authToken) {
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please log in first" delegate:self cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [error show];
    } else {
        [[self getUser] clear];
        [[self getUser] updateFromServerWithSuccess:^(NSDictionary * d) {
            
            AccountSettingsNavigationViewController* accountSettings = [self.tabBarController.viewControllers objectAtIndex:2];
                        
            self.tabBarController.selectedViewController = accountSettings;
            
        } withFailure:^(NSError * e) {
            [ErrorTransformer errorToAlert:e withDelegate:self];
        }];
    }
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
            [self accountSettingsButtonTapped:nil];
        }, ^{
            [self aboutButtonTapped:nil];
        }, ^{
            [self shareButtonTapped:nil];
        }, nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //int a = indexPath.row;
    ((CompletionBlock)[self.tableOnTap objectAtIndex:indexPath.row])();
    
    
}

- (IBAction)callParkify:(UIButton *)sender {
    UIDevice *device = [UIDevice currentDevice];
    if ([[device model] isEqualToString:@"iPhone"] ) {
        UIAlertView *Permitted=[[UIAlertView alloc] initWithTitle:@"Need Help?" message:@"Would you like to call Parkify?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [Permitted show];
    } else {
        UIAlertView *Notpermitted=[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Your device doesn't support this feature." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [Notpermitted show];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"No"])
    {
        //NSLog(@"Button 1 was selected.");
    }
    else if([title isEqualToString:@"Yes"])
    {
        //NSLog(@"Button 2 was selected.");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:1-855-727-5439"]]];
    }
}
@end
