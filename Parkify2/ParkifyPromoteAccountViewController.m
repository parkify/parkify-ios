//
//  ParkifySignupViewController.m
//  Parkify2
//
//  Created by Me on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ParkifyPromoteAccountViewController.h"
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
#import "AccountUpdatePage.h"
#import "User.h"

#import "UIViewController+AppData_User.h"
//#import "PlacedAgent.h"

@interface ParkifyPromoteAccountViewController ()
- (void)signUp;
//- (void)signUpCardSuccessWithCard:(NSString*)token;
@property (strong, nonatomic) StripeConnection *stripeConnection;
@property (nonatomic, strong) WaitingMask* waitingMask;

- (void)handleRegistrationSuccess:(NSDictionary*)result;
- (void)handleRegistrationFailure:(NSError*)result;


@property (nonatomic, strong) AccountUpdatePage* accountUpdatePage;
@property (weak, nonatomic) IBOutlet UIView *accountUpdatePageContainer;

@end

@implementation ParkifyPromoteAccountViewController
@synthesize keyboardAvoidingScrollView = _keyboardAvoidingScrollView;

@synthesize tosCheckbox = _tosCheckbox;

@synthesize waitingMask = _waitingMask;

@synthesize stripeConnection = _stripeConnection;

@synthesize accountUpdatePage = _accountUpdatePage;

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
    
    
    
    
	// Do any additional setup after loading
    
    [self.tosCheckbox setImage:nil forState:UIControlStateNormal];
    
    [self.tosCheckbox setImage:[UIImage imageNamed:@"glyphicons_193_circle_ok.png"] forState:UIControlStateSelected];
    
    
    CGRect frame =  self.accountUpdatePageContainer.frame;
    frame.origin = CGPointMake(0,0);
    
    
    self.accountUpdatePage = [[AccountUpdatePage alloc] initWithFrame:frame withUpdateType:@"PromoteAccount" withUser:[self getUser]];
    [self.accountUpdatePage addTarget:self action:@selector(signUp) forControlEvents:ShouldContinueActionEvent];
    
    [self.accountUpdatePageContainer addSubview:self.accountUpdatePage];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    [self.tabBarController showTabBar:NO];
    
}

- (void)viewDidUnload
{
    
    [self setKeyboardAvoidingScrollView:nil];
    [self setTosCheckbox:nil];
    [self setAccountUpdatePageContainer:nil];
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
    
    NSString* validate = [self.accountUpdatePage.user validate];
    if(validate) {
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Error" message:validate delegate:self cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [error show];
        return;
    }
    validate = [self.accountUpdatePage.card validate];
    if(validate) {
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Error" message:validate delegate:self cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [error show];
        return;
    }
    validate = [self.accountUpdatePage.car validate];
    if(validate) {
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Error" message:validate delegate:self cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [error show];
        return;
    }

    
    /*
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
    */
    
    CGRect waitingMaskFrame = self.view.frame;
    waitingMaskFrame.origin.x = 0;
    waitingMaskFrame.origin.y = 0;
    
    self.waitingMask = [[WaitingMask alloc] initWithFrame:waitingMaskFrame];
    [self.view addSubview:self.waitingMask];
    
    
    [Api signUpWithUser:self.accountUpdatePage.user withCard:self.accountUpdatePage.card  withCar:self.accountUpdatePage.car withSuccess:^(NSDictionary * result) {
        [self handleRegistrationSuccess:result];
    } withFailure:^(NSError * result) {
        [self handleRegistrationFailure:result];
    } ];
}

- (IBAction)signUpTapped:(UIButton*)sender {
    [self signUp];
}

- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
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
    /*
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
    */
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
