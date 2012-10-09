//
//  ParkifyFrontPageViewControllerViewController.m
//  Parkify2
//
//  Created by Me on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ParkifySignInPageViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Parkify2ViewController.h"
#import "ParkifySignupViewController.h"
#import "Api.h"
#import "Persistance.h"
#import "UITabBarController+Hide.h"
#import "ModalSettingsController.h"
#import "TextFormatter.h"
//#import "PlacedAgent.h"


@interface ParkifySignInPageViewController ()

- (BOOL) verifyLoginWithEmail:(NSString * )email withPassword:(NSString *)password;
@property UITextField* activeField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property BOOL exitOnLoad;
- (void)handleLoginSuccess:(NSDictionary*)result;
- (void)handleLoginFailure:(NSError*)result;

@end

@implementation ParkifySignInPageViewController
@synthesize LoginButton = _LoginButton;
@synthesize loginLabel = _loginLabel;
@synthesize greetingLabel = _greetingLabel;
@synthesize emailLabel = _emailLabel;
@synthesize passwordLabel = _passwordLabel;
@synthesize signUpButton = _signUpButton;
@synthesize signUpLabel = _signUpLabel;
@synthesize errorLabel = _errorLabel;
@synthesize emailField = _emailField;
@synthesize passwordField = _passwordField;
@synthesize activeField = _activeField;
@synthesize scrollView = _scrollView;
@synthesize exitOnLoad = _exitOnLoad;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.exitOnLoad = false;
    }
    return self;
}

- (void) updatePage {
    //[self registerForKeyboardNotifications];
	// Do any additional setup after loading the view.
    CGRect frame = self.LoginButton.titleLabel.frame;
    frame.size.width += 20;
    //self.LoginButton.titleLabel.frame = frame;
    
    
    self.greetingLabel.hidden = true;
    
    if (![Persistance retrieveAuthToken]) {
        //logged out
        self.emailField.alpha = 1;
        self.passwordField.alpha = 1;
        self.emailLabel.alpha = 1;
        self.passwordLabel.alpha = 1;
        self.signUpButton.alpha = 1;
        self.signUpLabel.alpha = 1;
        self.loginLabel.text = @"Log in";
        
        
        self.greetingLabel.hidden = true;
        
    } else {
        //logged in
        self.emailField.alpha = 0;
        self.passwordField.alpha = 0;
        self.signUpButton.alpha = 0;
        self.signUpLabel.alpha = 0;
        self.emailLabel.alpha = 0;
        self.passwordLabel.alpha = 0;
        
        self.greetingLabel.text = [NSString stringWithFormat:@"You are logged in with credit card xxxx-xxxx-xxxx-%@", [Persistance retrieveLastFourDigits]];
        self.greetingLabel.hidden = false;
        self.loginLabel.text = @"Log out";
    }
    
    //Setup delegates
    self.emailField.delegate = self;
    self.passwordField.delegate = self;
    
    [self setUpTextField:self.emailField];
    [self setUpTextField:self.passwordField];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.exitOnLoad) {
        [self dismissModalViewControllerAnimated:YES];
    }
    
    //[PlacedAgent logPageView:@"LoginView"];
    
    
    [self updatePage];
    
}

- (void)setUpTextField:(UITextField*) tf {
    tf.layer.cornerRadius=8.0f;
    tf.layer.masksToBounds=YES;
    tf.layer.borderColor=[TEXTFIELD_BORDER_COLOR CGColor];
    tf.layer.borderWidth=2.0f;
    
    /*
    CGRect rect = tf.frame;
    rect.size.height = TEXTFIELD_HEIGHT;
    tf.frame = rect;
    */
}

- (void)viewDidUnload
{
    [self setEmailField:nil];
    [self setPasswordField:nil];
    [self setErrorLabel:nil];
    [self setScrollView:nil];
    [self setLoginButton:nil];
    [self setSignUpButton:nil];
    [self setSignUpLabel:nil];
    [self setEmailLabel:nil];
    [self setPasswordLabel:nil];
    [self setLoginLabel:nil];
    [self setGreetingLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)handleLoginSuccess:(NSDictionary*)result {
    
    [Persistance saveAuthToken:[result objectForKey:@"auth_token"]];
    
    //self.errorLabel.text = [NSString stringWithFormat:@"User logged in! Token is: %@", [Persistance retrieveAuthToken]];
    //self.errorLabel.hidden = false;
    
    
    //Escape from modal
    NSDictionary* results = [NSDictionary dictionaryWithObjectsAndKeys:@"logged_in",@"exit", nil];
    [((ModalSettingsController*)self.tabBarController) exitWithResults:results];  
    
    
    //[self performSegueWithIdentifier:@"TempSegue" sender:self];  
}

- (void)handleLoginFailure:(NSError*)result {
    NSLog(@"Error: %@; %@", result.localizedDescription, [result.userInfo objectForKey:@"message"]);
    
    if (result.domain && [result.domain isEqualToString:@"UserLogin"]) {
        /* Handle user registratin error here */
        
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Error" message:[result.userInfo objectForKey:@"message"] delegate:self cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [error show];
        
        //self.errorLabel.text = [result.userInfo objectForKey:@"message"];
        //self.errorLabel.hidden = false;
    } else {
        /* Handle network error here */
        
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot connect to server." delegate:self cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [error show];
        //self.errorLabel.text = @"Error with your login or password";
        //self.errorLabel.hidden = false;
    }
}

- (IBAction)loginButtonPressed:(UIButton *)sender {
    
    if (![Persistance retrieveAuthToken]) {
        [Api loginWithEmail:self.emailField.text
               withPassword:self.passwordField.text
                withSuccess:^(NSDictionary * result) {
                    [self handleLoginSuccess:result];
                }
                withFailure:^(NSError * result) {
                    [self handleLoginFailure:result];
                }
         ];
    } else {
        [self logoutButtonPressed:nil];
        [self updatePage];
    }
    
    
        /*
    if([self verifyLoginWithEmail:self.emailField.text withPassword:self.passwordField.text]) {
        //Go to map view with correct user.
        [self performSegueWithIdentifier:@"ViewMapFromFront" sender:self];
    } else {
        self.errorLabel.text = @"Error: incorrect email/password combination";
        [self.errorLabel setHidden:false];
    }
     */
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    [self.tabBarController showTabBar:NO];
    //] setNavigationBarHidden:YES animated:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return true;
}

- (BOOL) verifyLoginWithEmail:(NSString * )email withPassword:(NSString *)password {
    return true;
}

- (IBAction)signUpButtonPressed:(UIButton *)sender {
    self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:1];   
}

- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender {
    //Escape from modal
    NSDictionary* results = [NSDictionary dictionaryWithObjectsAndKeys:@"cancel",@"exit", nil];
    [((ModalSettingsController*)self.tabBarController) exitWithResults:results]; 
}

- (IBAction)resetPasswordTapped:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://parkify-rails.herokuapp.com/my/users/password/new"];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)logoutButtonPressed:(UIButton *)sender {
    /** TODO: also tell server to logout if can **/
    [Persistance saveAuthToken:nil];
    [Persistance saveUserID:[NSNumber numberWithInt:-1]];
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
