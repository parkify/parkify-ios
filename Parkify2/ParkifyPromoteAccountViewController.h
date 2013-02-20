//
//  ParkifySignupViewController.h
//  Parkify2
//
//  Created by Me on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"

@interface ParkifyPromoteAccountViewController : UIViewController <UITextFieldDelegate>



- (IBAction)signUpTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *tosCheckbox;
- (IBAction)tosCheckboxTapped:(id)sender;


- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *keyboardAvoidingScrollView;

- (IBAction)callParkify:(UIButton *)sender;

@end
