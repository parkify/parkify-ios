//
//  AccountSettingsTableViewController.h
//  Parkify
//
//  Created by Me on 10/25/12.
//
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "ELCTextfieldCell.h"

#import "ParkifyTableViewController.h"

@interface AccountSettingsTableViewController : ParkifyTableViewController<ELCTextFieldDelegate>

- (IBAction)backButtonTapped:(id)sender;
- (IBAction)saveButtonTapped:(id)sender;

@end
