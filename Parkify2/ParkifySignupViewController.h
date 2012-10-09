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
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *cardNumberField;
@property (weak, nonatomic) IBOutlet UITextField *securityNumberField;
@property (weak, nonatomic) IBOutlet UITextField *zipField;
@property (weak, nonatomic) IBOutlet UITextField *expirationMonthField;
@property (weak, nonatomic) IBOutlet UITextField *expirationYearField;
@property (weak, nonatomic) IBOutlet UITextField *licensePlateField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;



- (IBAction)signUpTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *securityNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *zipLabel;
@property (weak, nonatomic) IBOutlet UILabel *expirationMonthLabel;
@property (weak, nonatomic) IBOutlet UILabel *expirationYearLabel;
- (IBAction)tosButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *licensePlateLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;


@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIButton *tosCheckbox;
- (IBAction)tosCheckboxTapped:(id)sender;


@property (weak, nonatomic) id<CollapsingSegueProtocol> segueParent;
- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *keyboardAvoidingScrollView;

- (IBAction)callParkify:(UIButton *)sender;

@end
