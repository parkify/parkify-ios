//
//  ParkifyFrontPageViewControllerViewController.m
//  Parkify2
//
//  Created by Me on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ParkifyFrontPageViewControllerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Parkify2ViewController.h"
#import "ParkifySignupViewController.h"

@interface ParkifyFrontPageViewControllerViewController ()
- (BOOL) verifyLoginWithEmail:(NSString * )email withPassword:(NSString *)password;
@property UITextField* activeField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation ParkifyFrontPageViewControllerViewController
@synthesize errorLabel = _errorLabel;
@synthesize emailField = _emailField;
@synthesize passwordField = _passwordField;
@synthesize activeField = _activeField;
@synthesize scrollView = _scrollView;

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
    //[self registerForKeyboardNotifications];
	// Do any additional setup after loading the view.
    
    //UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0 alpha:0.8] CGColor], (id)[[UIColor colorWithWhite:1 alpha:0.8] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    //Setup delegates
    
    self.emailField.delegate = self;
    self.passwordField.delegate = self;
}

- (void)viewDidUnload
{
    [self setEmailField:nil];
    [self setPasswordField:nil];
    [self setErrorLabel:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)loginButtonPressed:(UIButton *)sender {
    if([self verifyLoginWithEmail:self.emailField.text withPassword:self.passwordField.text]) {
        //Go to map view with correct user.
        [self performSegueWithIdentifier:@"ViewMapFromFront" sender:self];
    } else {
        self.errorLabel.text = @"Error: incorrect email/password combination";
        [self.errorLabel setHidden:false];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ViewMapFromFront"]) {
        Parkify2ViewController *newController = segue.destinationViewController;
        //Setup stuff here before going into map
    } else if ([segue.identifier isEqualToString:@"ViewSignup"]) {
        ParkifySignupViewController *newController = segue.destinationViewController;
        //Setup stuff here before going onto signup page
    }
}




/*

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
}




// Called when the UIKeyboardDidShowNotification is sent.

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    CGPoint origin = self.activeField.frame.origin;
    origin.y -= self.scrollView.contentOffset.y;
    if (!CGRectContainsPoint(aRect, origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self.activeField.frame.origin.y-(aRect.size.height)); 
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

*/
@end
