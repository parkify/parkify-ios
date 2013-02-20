//
//  AccountSettingsTableViewController.m
//  Parkify
//
//  Created by Me on 10/25/12.
//
//

#import "AccountSettingsTableViewController.h"
#import "AccountSettingsNavigationViewController.h"
#import "CreditCardCollectionTableViewController.h"
#import "CarCollectionTableViewController.h"
#import "PromoCollectionTableViewController.h"
#import "UIViewController+AppData_User.h"
#import "ErrorTransformer.h"
#import "Api.h"
@interface AccountSettingsTableViewController ()



@end

@implementation AccountSettingsTableViewController



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    [[self getUser] updateFromServerWithSuccess:^(NSDictionary *d){
        [self.tableView reloadData];
    } withFailure:^(NSError *e){}];
  //  [[self getUser] updateFromServerWithSuccess:^(NSDictionary * d) {

}
- (void)viewDidLoad
{
    [super viewDidLoad];
        
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if([[self getUser].accountType isEqualToString: @"trial"]) {
        return 2;
    }
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if([[self getUser].accountType isEqualToString: @"trial"]) {
        switch (section) {
            case 0:
                return 2;
            case 1:
                return 1;
            default:
                return 0;
        }
    }
    switch (section) {
        case 0:
            return 5;
        case 1:
            return 3;
        case 2:
            return 1;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
    
        NSString *CellIdentifier = @"UserPropertyCell";
        //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        ELCTextfieldCell *cell = (ELCTextfieldCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
        if (!cell.delegate) {
            cell = [[ELCTextfieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [self configureCell:cell atIndexPath:indexPath];
    
        return cell;
    } else {
        NSString *CellIdentifier = @"SegueCell";
        //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell.textLabel) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [self configureSegueCell:cell atIndexPath:indexPath];
        
        return cell;
        
    }
}

- (void)configureCell:(ELCTextfieldCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if([[self getUser].accountType isEqualToString: @"trial"]) {
        cell.indexPath = indexPath;
        cell.delegate = self;
        
        //Disables UITableViewCell from accidentally becoming selected.
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        
        cell.rightTextField.placeholder = @"";
        
        // Configure the cell...
        switch (indexPath.row) {
            case 0:
                cell.leftLabel.text = @"Phone";
                cell.rightTextField.text = [self getUser].phone_number;
                [cell.rightTextField setKeyboardType:UIKeyboardTypeNumberPad];
                break;
            case 1:
                cell.leftLabel.text = @"Credits";
                cell.rightTextField.text = [NSString stringWithFormat:@"$%0.2f", [self getUser].credit/100.0];
                [cell.rightTextField setEnabled:false];
                break;
            default:
                break;
        }
    } else {
        cell.indexPath = indexPath;
        cell.delegate = self;
        
        //Disables UITableViewCell from accidentally becoming selected.
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        
        cell.rightTextField.placeholder = @"";
        
        // Configure the cell...
        switch (indexPath.row) {
            case 0:
                cell.leftLabel.text = @"First Name";
                cell.rightTextField.text = [self getUser].first_name;
                break;
            case 1:
                cell.leftLabel.text = @"Last Name";
                cell.rightTextField.text = [self getUser].last_name;
                break;
            case 2:
                cell.leftLabel.text = @"Email";
                cell.rightTextField.text = [self getUser].email;
                [cell.rightTextField setKeyboardType:UIKeyboardTypeEmailAddress];
                break;
            case 3:
                cell.leftLabel.text = @"Phone";
                cell.rightTextField.text = [self getUser].phone_number;
                [cell.rightTextField setKeyboardType:UIKeyboardTypeNumberPad];
                break;
            case 4:
                cell.leftLabel.text = @"Credits";
                cell.rightTextField.text = [NSString stringWithFormat:@"$%0.2f", [self getUser].credit/100.0];
                [cell.rightTextField setEnabled:false];
                break;
            default:
                break;
        }

        
    }
}
- (void)configureSegueCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    if([[self getUser].accountType isEqualToString: @"trial"]) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Upgrade to Standard Account";
                break;
            default:
                break;
        }
    } else {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = (indexPath.section == 1)? @"Credit Cards" : @"Change Password";
                break;
            case 1:
                cell.textLabel.text = @"Registered Vehicles";
                break;
            case 2:
                cell.textLabel.text = @"Promotions";
                break;
            default:
                break;
        }
        
    }
    
    
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([[self getUser].accountType isEqualToString: @"trial"]) {
        switch (indexPath.section) {
            case 1:
                switch (indexPath.row) {
                    case 0: {
                        [self performSegueWithIdentifier:@"XPromoteAccount" sender:self];
                        return;
                    }
                    default:
                        return;
                }
                break;
            default:
                return;
        }
        
    } else {
        switch (indexPath.section) {
            case 1:
                
                switch (indexPath.row) {
                    case 0: {
                        [self performSegueWithIdentifier:@"CreditCardCollection" sender:self];
                        return;
                    }
                    case 1: {
                        [self performSegueWithIdentifier:@"CarCollection" sender:self];
                        return;
                    }
                    case 2: {
                        [self performSegueWithIdentifier:@"PromoCollection" sender:self];
                        return;
                    }
                    default:
                        return;
                }
                break;
            case 2: {
                [self performSegueWithIdentifier:@"Password" sender:self];
                return;        }
            default:
                return;
        }
        
    }
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - ELCTextFieldDelegate

//Called to the delegate whenever return is hit when a user is typing into the rightTextField of an ELCTextFieldCell
-(void)textFieldDidReturnWithIndexPath:(NSIndexPath*)indexPath {
    [[(ELCTextfieldCell*)[self.tableView cellForRowAtIndexPath:indexPath] rightTextField] resignFirstResponder];
    /*
    if(indexPath.row < 5-1) {
		NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
		[[(ELCTextfieldCell*)[self.tableView cellForRowAtIndexPath:path] rightTextField] becomeFirstResponder];
		[self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
	}
    
	else {
        
		[[(ELCTextfieldCell*)[self.tableView cellForRowAtIndexPath:indexPath] rightTextField] resignFirstResponder];
	}
     */
}

//Called to the delegate whenever the text in the rightTextField is changed
- (void)updateTextLabelAtIndexPath:(NSIndexPath*)indexPath string:(NSString*)string {
    // Configure the cell...
    if([[self getUser].accountType isEqualToString: @"trial"]) {
        switch (indexPath.row) {
            case 0:
                [self getUser].phone_number = string;
                break;
            default:
                break;
        }
    } else {
        switch (indexPath.row) {
            case 0:
                [self getUser].first_name = string;
                break;
            case 1:
                [self getUser].last_name = string;
                break;
            case 2:
                [self getUser].email = string;
                break;
            case 3:
                [self getUser].phone_number = string;
                break;
            default:
                break;
        }
    }
    
}


- (IBAction)backButtonTapped:(id)sender {
    self.navigationController.tabBarController.selectedViewController = [self.navigationController.tabBarController.viewControllers objectAtIndex:0];
}

- (IBAction)saveButtonTapped:(id)sender {
    [[self getUser] pushChangesToServerWithSuccess:^(NSDictionary * d) {
        UIAlertView* success = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Account settings changed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [success show];
        [self.tableView reloadData];
    } withFailure:^(NSError * e) {
        
        [ErrorTransformer errorToAlert:e withDelegate:self];
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"CreditCardCollection"]) {
      ;
    }
    if([segue.identifier isEqualToString:@"CarCollection"]) {
      ;
    }
    if([segue.identifier isEqualToString:@"PromoCollection"]) {
      ;
    }
    if([segue.identifier isEqualToString:@"XPromoteAccount"]) {
        ;
    }
}


@end
