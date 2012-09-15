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
#import "TextFormatter.h"


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
@synthesize nameLabel = _nameLabel;
@synthesize emailLabel = _emailLabel;
@synthesize passwordLabel = _passwordLabel;
@synthesize cardNumberLabel = _cardNumberLabel;
@synthesize securityNumberLabel = _securityNumberLabel;
@synthesize zipLabel = _zipLabel;
@synthesize expirationMonthLabel = _expirationMonthLabel;
@synthesize expirationYearLabel = _expirationYearLabel;
@synthesize licensePlateLabel = _licensePlateLabel;
@synthesize scrollView = _scrollView;
@synthesize zipField = _zipField;
@synthesize emailField = _emailField;
@synthesize passwordField = _passwordField;
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
    
    self.stripeConnection = [StripeConnection connectionWithPublishableKey:@"pk_XeTF5KrqXMeSyyqApBF4q9qDzniMn"];

    self.emailField.delegate = self;
    self.passwordField.delegate = self;
    self.zipField.delegate = self;
    self.firstNameField.delegate = self;
    self.lastNameField.delegate = self;
    self.cardNumberField.delegate = self;
    self.securityNumberField.delegate = self;
    self.expirationMonthField.delegate = self;
    self.expirationYearField.delegate = self;
    self.licensePlateField.delegate = self;
    
	// Do any additional setup after loading the view.
    
    
    [self setUpTextField:self.emailField];
    [self setUpTextField:self.passwordField];
    [self setUpTextField:self.zipField];
    [self setUpTextField:self.firstNameField];
    [self setUpTextField:self.lastNameField];
    [self setUpTextField:self.cardNumberField];
    [self setUpTextField:self.securityNumberField];
    [self setUpTextField:self.expirationMonthField];
    [self setUpTextField:self.expirationYearField];
    [self setUpTextField:self.licensePlateField];
    
    [self setUpLabels:self.nameLabel];
    [self setUpLabels:self.emailLabel];
    [self setUpLabels:self.passwordLabel];
    [self setUpLabels:self.cardNumberLabel];
    [self setUpLabels:self.securityNumberLabel];
    [self setUpLabels:self.zipLabel];
    [self setUpLabels:self.expirationMonthLabel];
    [self setUpLabels:self.expirationYearLabel];
    [self setUpLabels:self.licensePlateLabel];
    
    
    CGRect frame = self.scrollView.frame;
    frame.size.height = frame.size.height + 50;
    self.scrollView.contentSize = frame.size;

    
    
}

- (void)setUpLabels:(UILabel*) label {
    
    CGAffineTransform squish = [TextFormatter transformForSignupViewText];
    
    label.transform = squish;
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
    [self setZipField:nil];
    [self setZipField:nil];
    [self setScrollView:nil];
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
        self.errorLabel.text = @"Could not reach server";
        self.errorLabel.hidden = false;
    }
}

- (void)signUp {
    self.signUpButton.enabled = false;
    [Api signUpWithEmail:self.emailField.text 
            withPassword:self.passwordField.text 
withPasswordConfirmation:self.passwordField.text 
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


- (IBAction)tosButtonTapped:(id)sender {
    [Api webWrapperModallyFrom:self withURL:@"http://www.parkify.me/tos?view=iphone"];
}
@end
