//
//  ParkifySignupViewController.h
//  Parkify2
//
//  Created by Me on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParkifySignupViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *cardNumberField;
@property (weak, nonatomic) IBOutlet UITextField *expirationDateField;
@property (weak, nonatomic) IBOutlet UITextField *securityNumberField;
@property (weak, nonatomic) IBOutlet UITextField *licensePlateField;
- (IBAction)signUpTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@end
