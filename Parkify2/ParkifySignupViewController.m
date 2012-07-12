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
#import "Authentication.h"

@interface ParkifySignupViewController ()
- (void)signUp;
@end

@implementation ParkifySignupViewController
@synthesize errorLabel = _errorLabel;
@synthesize emailField = _emailField;
@synthesize passwordField = _passwordField;
@synthesize cardNumberField = _cardNumberField;
@synthesize expirationDateField = _expirationDateField;
@synthesize securityNumberField = _securityNumberField;
@synthesize licensePlateField = _licensePlateField;

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

	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setEmailField:nil];
    [self setPasswordField:nil];
    [self setCardNumberField:nil];
    [self setExpirationDateField:nil];
    [self setSecurityNumberField:nil];
    [self setLicensePlateField:nil];
    [self setErrorLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)signUp {
    //UserRegistrationRequest* user = [[UserRegistrationRequest alloc] initWithEmail:self.emailField.text withPassword:self.passwordField.text withPasswordConfirmation:self.passwordField.text];
    NSDictionary *user = [NSDictionary dictionaryWithObjectsAndKeys:
                                    self.emailField.text, @"email", self.passwordField.text, @"password", self.passwordField.text, @"password_confirmation", nil];
    
    
    NSURL *url = [NSURL URLWithString:@"http://swooplot.herokuapp.com/api/users"];
    NSLog(@"%@", [user JSONRepresentation]);
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addPostValue:[user JSONRepresentation] forKey:@"user"];
    [request addRequestHeader:@"User-Agent" value:@"ASIFormDataRequest"]; 
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request  setRequestMethod:@"POST"];
    [request setCompletionBlock:^{
        NSString *responseString = [request responseString];
        NSDictionary * root = [responseString JSONValue];
        if([root objectForKey:@"success"]) {
            self.errorLabel.text = [NSString stringWithFormat:@"User created! Awesomesauce! Token is: %@", [root objectForKey:@"auth_token"]];
        } else {
            self.errorLabel.text = [root objectForKey:@"error"];
        }
        self.errorLabel.hidden = false;
        NSLog(@"Response: %@", responseString);
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"Error: %@", error.localizedDescription);
    }];
    
    [request startAsynchronous];
}

- (IBAction)signUpTapped:(id)sender {
    [self signUp];
}
@end
