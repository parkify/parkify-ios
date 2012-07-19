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


@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
- (IBAction)signUpButtonPressed:(UIButton *)sender;
- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender;

@end
