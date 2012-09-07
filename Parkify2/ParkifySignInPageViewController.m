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
    
    if (![Persistance retrieveAuthToken]) {
        //logged out
        self.emailField.alpha = 1;
        self.passwordField.alpha = 1;
        self.emailLabel.alpha = 1;
        self.passwordLabel.alpha = 1;
        self.signUpButton.alpha = 1;
        self.signUpLabel.alpha = 1;
        self.loginLabel.text = @"Log in";
    } else {
        //logged in
        self.emailField.alpha = 0;
        self.passwordField.alpha = 0;
        self.signUpButton.alpha = 0;
        self.signUpLabel.alpha = 0;
        self.emailLabel.alpha = 0;
        self.passwordLabel.alpha = 0;
        
        
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)handleLoginSuccess:(NSDictionary*)result {
    
    [Persistance saveAuthToken:[result objectForKey:@"auth_token"]];
    self.errorLabel.text = [NSString stringWithFormat:@"User logged in! Token is: %@", [Persistance retrieveAuthToken]];
    self.errorLabel.hidden = false;
    
    
    //Escape from modal
    NSDictionary* results = [NSDictionary dictionaryWithObjectsAndKeys:@"logged_in",@"exit", nil];
    [((ModalSettingsController*)self.tabBarController) exitWithResults:results];  
    
    
    //[self performSegueWithIdentifier:@"TempSegue" sender:self];  
}

- (void)handleLoginFailure:(NSError*)result {
    NSLog(@"Error: %@; %@", result.localizedDescription, [result.userInfo objectForKey:@"message"]);
    
    if (result.domain && [result.domain isEqualToString:@"UserLogin"]) {
        /* Handle user registratin error here */
        self.errorLabel.text = [result.userInfo objectForKey:@"message"];
        self.errorLabel.hidden = false;
    } else {
        /* Handle network error here */
        self.errorLabel.text = @"Error with your login or password";
        self.errorLabel.hidden = false;
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
    BOOL b1 = [email isEqualToString:@"dylan.r.jackson@gmail.com"];
    BOOL b2 = [password isEqualToString:@"4rrowhe4d"];
    return  b1 && b2;
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
    NSURL *url = [NSURL URLWithString:@"http://parkify-rails.herokuapp.com"];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)logoutButtonPressed:(UIButton *)sender {
    /** TODO: also tell server to logout if can **/
    [Persistance saveAuthToken:nil];
}
@end
