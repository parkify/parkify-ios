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
#import "WaitingMask.h"
#import "ErrorTransformer.h"
//#import "PlacedAgent.h"

@interface ParkifySignupViewController ()
- (void)signUp;
//- (void)signUpCardSuccessWithCard:(NSString*)token;
@property (strong, nonatomic) StripeConnection *stripeConnection;
@property (nonatomic, strong) WaitingMask* waitingMask;

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
@synthesize tosCheckbox = _tosCheckbox;
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

@synthesize waitingMask = _waitingMask;

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
    
    //[PlacedAgent logPageView:@"RegisterView"];
    
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
    self.phoneField.delegate = self;
    
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
    [self setUpTextField:self.phoneField];
    
    [self setUpLabels:self.nameLabel];
    [self setUpLabels:self.emailLabel];
    [self setUpLabels:self.passwordLabel];
    [self setUpLabels:self.cardNumberLabel];
    [self setUpLabels:self.securityNumberLabel];
    [self setUpLabels:self.zipLabel];
    [self setUpLabels:self.expirationMonthLabel];
    [self setUpLabels:self.expirationYearLabel];
    [self setUpLabels:self.licensePlateLabel];
    [self setUpLabels:self.phoneLabel];
    
    
    CGRect frame = self.scrollView.frame;
    //frame.size.height = frame.size.height + 50;
    frame.size.height = frame.size.height;
    self.scrollView.contentSize = frame.size;

    [self.tosCheckbox setImage:nil forState:UIControlStateNormal];
    
    [self.tosCheckbox setImage:[UIImage imageNamed:@"glyphicons_193_circle_ok.png"] forState:UIControlStateSelected];
    
    
}

- (void)setUpLabels:(UILabel*) label {
    
    /*
    CGAffineTransform squish = [TextFormatter transformForSignupViewText];
    
    label.transform = squish;
     */
}

- (void)setUpTextField:(UITextField*) tf {
    tf.layer.cornerRadius=8.0f;
    tf.layer.masksToBounds=YES;
    tf.layer.borderColor=[TEXTFIELD_BORDER_COLOR CGColor];
    tf.layer.borderWidth=2.0f;
    
    tf.layer.backgroundColor=[[UIColor colorWithWhite:0.5 alpha:1] CGColor];
}

//Does not work as expected.
- (void)setUpTextField:(UITextField*)tf topBoundary:(BOOL)tBound
bottomBoundary:(BOOL)bBound leftBoundary:(BOOL)lBound rightBoundary:(BOOL)rBound {

    UIRectCorner corner = 0;
    
    if(tBound && lBound) {
        corner = corner | UIRectCornerTopLeft;
    }
    if(tBound && rBound) {
        corner = corner | UIRectCornerTopRight;
    }
    if(bBound && lBound) {
        corner = corner | UIRectCornerBottomLeft;
    }
    if(bBound && rBound) {
        corner = corner | UIRectCornerBottomRight;
    }
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:tf.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(2.0, 2.0)];
    
    CAShapeLayer* maskLayer = [CAShapeLayer layer];
    maskLayer.frame = tf.bounds;
    maskLayer.path = maskPath.CGPath;
    
    tf.layer.mask = maskLayer;
    
    /*
    tf.layer.cornerRadius=8.0f;
    */
    tf.layer.masksToBounds=YES;
    tf.layer.borderColor=[TEXTFIELD_BORDER_COLOR CGColor];
    tf.layer.borderWidth=2.0f;
    
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
    [self setTosCheckbox:nil];
    [self setPhoneLabel:nil];
    [self setPhoneField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)handleRegistrationSuccess:(NSDictionary *)result {
    if(self.waitingMask) {
        [self.waitingMask removeFromSuperview];
        self.waitingMask = nil;
    }
    self.signUpButton.enabled = true;
    
    //self.errorLabel.text = [NSString stringWithFormat:@"User created! Token is: %@", [Persistance retrieveAuthToken]];
    
    //Escape from modal
    NSDictionary* results = [NSDictionary dictionaryWithObjectsAndKeys:@"logged_in",@"exit", nil];
    [((ModalSettingsController*)self.tabBarController) exitWithResults:results];  
}

- (void)handleRegistrationFailure:(NSError *)result {
    if(self.waitingMask) {
        [self.waitingMask removeFromSuperview];
        self.waitingMask = nil;
    }
    NSLog(@"Error: %@; %@", result.localizedDescription, [result.userInfo objectForKey:@"message"]);
    
    self.signUpButton.enabled = true;
    
    if (result.domain && [result.domain isEqualToString:API_ERROR_DOMAIN]) {
        /* Handle user registratin error here */
        
        [ErrorTransformer errorToAlert:result withDelegate:self];
        
    }
    else if (result.domain && [result.domain isEqualToString:@"Stripe"]) {
        /* Handle stipe error here */
        
        [ErrorTransformer errorToAlert:result withDelegate:self];
        
        
    } else {
        /* Handle network error here */
        
        //TODO: standard Network-error-maker in ErrorTransformer.h
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not reach server" delegate:self cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [error show];
    }
}

- (void)signUp {
    
    if(!self.tosCheckbox.selected) {
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please view our Terms of Service." delegate:self cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [error show];
        return;
    }
    
    if(self.phoneField.text.length != 14) {
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please give a valid phone number." delegate:self cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [error show];
        return;
    }
    
    if(self.firstNameField.text.length == 0) {
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please give a valid name." delegate:self cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [error show];
        return;
    }
    
    if(self.lastNameField.text.length == 0) {
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please give a valid name." delegate:self cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [error show];
        return;
    }
    
    if(self.zipField.text.length == 0) {
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please give a valid zip code." delegate:self cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [error show];
        return;
    }
    
    if(self.licensePlateField.text.length == 0) {
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please give a valid license plate." delegate:self cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [error show];
        return;
    }
    
    CGRect waitingMaskFrame = self.view.frame;
    waitingMaskFrame.origin.x = 0;
    waitingMaskFrame.origin.y = 0;
    
    self.waitingMask = [[WaitingMask alloc] initWithFrame:waitingMaskFrame];
    [self.view addSubview:self.waitingMask];
    
    
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
             withZipCode:self.zipField.text
               withPhone:self.phoneField.text
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
    [Api webWrapperModallyFrom:self withURL:@"http://parkify.me/tos"];
}
- (IBAction)tosCheckboxTapped:(UIButton*)sender {
    
    sender.selected = !sender.selected;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if(textField != self.phoneField) {
        return YES;
    }
     
    
    int length = [self getLength:textField.text];
    //NSLog(@"Length  =  %d ",length);
    
    if(length == 10)
    {
        if(range.length == 0)
            return NO;
    }
    
    if(length == 3)
    {
        NSString *num = [self formatNumber:textField.text];
        textField.text = [NSString stringWithFormat:@"(%@) ",num];
        if(range.length > 0)
            textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
    }
    else if(length == 6)
    {
        NSString *num = [self formatNumber:textField.text];
        //NSLog(@"%@",[num  substringToIndex:3]);
        //NSLog(@"%@",[num substringFromIndex:3]);
        textField.text = [NSString stringWithFormat:@"(%@) %@-",[num  substringToIndex:3],[num substringFromIndex:3]];
        if(range.length > 0)
            textField.text = [NSString stringWithFormat:@"(%@) %@",[num substringToIndex:3],[num substringFromIndex:3]];
    }
    
    return YES;
    
}

-(NSString*)formatNumber:(NSString*)mobileNumber
{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    NSLog(@"%@", mobileNumber);
    
    int length = [mobileNumber length];
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
        NSLog(@"%@", mobileNumber);
        
    }
    
    
    return mobileNumber;
}


-(int)getLength:(NSString*)mobileNumber
{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = [mobileNumber length];
    
    return length;
    
    
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
