//
//  ParkifySignupViewController.h
//  Parkify2
//
//  Created by Me on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"

@protocol CollapsingSegueProtocol <NSObject>
- (void) SetToCollapse:(BOOL)toCollapse;
@end

@interface ParkifySignupViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *cardNumberField;
@property (weak, nonatomic) IBOutlet UITextField *securityNumberField;
@property (weak, nonatomic) IBOutlet UITextField *expirationMonthField;
@property (weak, nonatomic) IBOutlet UITextField *expirationYearField;
@property (weak, nonatomic) IBOutlet UITextField *licensePlateField;
- (IBAction)signUpTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

@property (weak, nonatomic) id<CollapsingSegueProtocol> segueParent;
- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *keyboardAvoidingScrollView;

@end
