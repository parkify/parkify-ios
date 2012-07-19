//
//  ParkifySignupViewController.m
//  Parkify2
//
//  Created by Me on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ParkifySignupViewController.h"
#import "ASIFormDataRequest.h"
#import <QuartzCore/QuartzCore.h> 
#import "SBJson.h"
#import "Api.h"
#import "Persistance.h"
#import "UITabBarController+Hide.h"
#import "Stripe.h"
#import "ModalSettingsController.h"



@interface ParkifySignupViewController ()
- (void)signUp;
//- (void)signUpCardSuccessWithCard:(NSString*)token;
@property (strong, nonatomic) StripeConnection *stripeConnection;

- (void)handleRegistrationSuccess:(NSDictionary*)result;
- (void)handleRegistrationFailure:(NSError*)result;



@end

@implementation ParkifySignupViewController
@synthesize keyboardAvoidingScrollView = _keyboardAvoidingScrollView;
@synthesize errorLabel = _errorLabel;
@synthesize signUpButton = _signUpButton;
@synthesize emailField = _emailField;
@synthesize passwordField = _passwordField;
@synthesize passwordConfField = _passwordConfField;
@synthesize firstNameField = _firstNameField;
@synthesize lastNameField = _lastNameField;
@synthesize cardNumberField = _cardNumberField;
@synthesize securityNumberField = _securityNumberField;
@synthesize expirationMonthField = _expirationMonthField;
@synthesize expirationYearField = _expirationYearField;
@synthesize licensePlateField = _licensePlateField;
@synthesize segueParent = _segueParent;

@synthesize stripeConnection = _stripeConnection;

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
    //UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0 alpha:0.8] CGColor], (id)[[UIColor colorWithWhite:1 alpha:0.8] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];

    self.stripeConnection = [StripeConnection connectionWithPublishableKey:@"pk_GP95lUPyExWOy8e81qL5vIbwMH7G8"];

    self.emailField.delegate = self;
    self.passwordField.delegate = self;
    self.passwordConfField.delegate = self;
    self.firstNameField.delegate = self;
    self.lastNameField.delegate = self;
    self.cardNumberField.delegate = self;
    self.securityNumberField.delegate = self;
    self.expirationMonthField.delegate = self;
    self.expirationYearField.delegate = self;
    self.licensePlateField.delegate = self;
    
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    [self.tabBarController showTabBar:NO];
}

- (void)viewDidUnload
{
    [self setEmailField:nil];
    [self setPasswordField:nil];
    [self setCardNumberField:nil];
    [self setSecurityNumberField:nil];
    [self setLicensePlateField:nil];
    [self setErrorLabel:nil];
    [self setSignUpButton:nil];
    [self setKeyboardAvoidingScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)handleRegistrationSuccess:(NSDictionary *)result {
    self.signUpButton.enabled = true;
    [Persistance saveAuthToken:[result objectForKey:@"auth_token"]];
    self.errorLabel.text = [NSString stringWithFormat:@"User created! Token is: %@", [Persistance retrieveAuthToken]];
    
    //Escape from modal
    NSDictionary* results = [NSDictionary dictionaryWithObjectsAndKeys:@"logged_in",@"exit", nil];
    [((ModalSettingsController*)self.tabBarController) exitWithResults:results];  
}

- (void)handleRegistrationFailure:(NSError *)result { 
    NSLog(@"Error: %@; %@", result.localizedDescription, [result.userInfo objectForKey:@"message"]);
    
    self.signUpButton.enabled = true;
    
    if (result.domain && [result.domain isEqualToString:@"UserRegistration"]) {
        /* Handle user registratin error here */
        self.errorLabel.text = [result.userInfo objectForKey:@"message"];
        self.errorLabel.hidden = false;
    }
    else if (result.domain && [result.domain isEqualToString:@"Stripe"]) {
        /* Handle stipe error here */
        self.errorLabel.text = [result.userInfo objectForKey:@"message"];  
        self.errorLabel.hidden = false;
    } else {
        /* Handle network error here */
    }
}

- (void)signUp {
    self.signUpButton.enabled = false;
    [Api signUpWithEmail:self.emailField.text 
            withPassword:self.passwordField.text 
withPasswordConfirmation:self.passwordConfField.text 
           withFirstName:self.firstNameField.text 
            withLastName:self.lastNameField.text 
    withCreditCardNumber:self.cardNumberField.text 
                 withCVC:self.securityNumberField.text 
     withExpirationMonth:[NSNumber numberWithInteger:[self.expirationMonthField.text integerValue] ] 
      withExpirationYear:[NSNumber numberWithInteger:[self.expirationYearField.text integerValue] ] 
        withLicensePlate:self.licensePlateField.text 
             withSuccess:^(NSDictionary * result) {
                 [self handleRegistrationSuccess:result];
             } 
             withFailure:^(NSError * result) {
                 [self handleRegistrationFailure:result];
             }    
     ];
}

- (IBAction)signUpTapped:(UIButton*)sender {
    [self signUp];
}
- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender {
    self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.keyboardAvoidingScrollView adjustOffsetToIdealIfNeeded];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    [textField resignFirstResponder];
    return NO; // We do not want UITextField to insert line-breaks.
}

@end
