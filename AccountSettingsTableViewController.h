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

@interface AccountSettingsTableViewController : UITableViewController <ELCTextFieldDelegate>

@property (strong, nonatomic) User* userModel;
- (IBAction)backButtonTapped:(id)sender;
- (IBAction)saveButtonTapped:(id)sender;

@end
