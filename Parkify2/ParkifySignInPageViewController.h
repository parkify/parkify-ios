//
//  ParkifyFrontPageViewControllerViewController.h
//  Parkify2
//
//  Created by Me on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParkifySignInPageViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

- (IBAction)loginButtonPressed:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;

@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UILabel *signUpLabel;

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
- (IBAction)signUpButtonPressed:(UIButton *)sender;
- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)resetPasswordTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *LoginButton;
@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
@property (weak, nonatomic) IBOutlet UILabel *greetingLabel;

- (IBAction)logoutButtonPressed:(UIButton *)sender;

- (IBAction)callParkify:(UIButton *)sender;
@end
