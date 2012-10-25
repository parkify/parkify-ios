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

@interface AccountSettingsTableViewController ()



@end

@implementation AccountSettingsTableViewController

@synthesize userModel = _userModel;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.userModel = ((AccountSettingsNavigationViewController*)(self.navigationController)).user;
    
    
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
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
    
	cell.indexPath = indexPath;
	cell.delegate = self;
    
    //Disables UITableViewCell from accidentally becoming selected.
    cell.selectionStyle = UITableViewCellEditingStyleNone;
    cell.rightTextField.placeholder = @"";
    
    // Configure the cell...
    switch (indexPath.row) {
        case 0:
            cell.leftLabel.text = @"First Name";
            cell.rightTextField.text = self.userModel.first_name;
            break;
        case 1:
            cell.leftLabel.text = @"Last Name";
            cell.rightTextField.text = self.userModel.last_name;
            break;
        case 2:
            cell.leftLabel.text = @"Email";
            cell.rightTextField.text = self.userModel.email;
            [cell.rightTextField setKeyboardType:UIKeyboardTypeEmailAddress];
            break;
        case 3:
            cell.leftLabel.text = @"Phone";
            cell.rightTextField.text = self.userModel.phone_number;
            [cell.rightTextField setKeyboardType:UIKeyboardTypeNumberPad];
            break;
        case 4:
            cell.leftLabel.text = @"Credits";
            cell.rightTextField.text = [NSString stringWithFormat:@"$%0.2f", self.userModel.credit/100.0];
            [cell.rightTextField setEnabled:false];
            break;
        default:
            break;
    }
}
- (void)configureSegueCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
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
    switch (indexPath.section) {
        case 1:
            
            switch (indexPath.row) {
                case 0: {
                    [self performSegueWithIdentifier:@"CreditCardCollection" sender:self];
                    
                    CreditCardCollectionTableViewController* detailViewController = [[CreditCardCollectionTableViewController alloc] initWithNibName:@"CreditCardCollectionVC" bundle:nil];
                    
                    detailViewController.creditCards = self.userModel.credit_cards;
                    
                    
                    [self.navigationController pushViewController:detailViewController animated:YES];
                    return;
                }
                case 1: {
                    CreditCardCollectionTableViewController* detailViewController = [[CreditCardCollectionTableViewController alloc] initWithNibName:@"CreditCardCollectionTableViewController" bundle:nil];
                    
                    detailViewController.creditCards = self.userModel.credit_cards;
                    
                    [self.navigationController pushViewController:detailViewController animated:YES];
                    return;
                }
                case 2: {
                    CreditCardCollectionTableViewController* detailViewController = [[CreditCardCollectionTableViewController alloc] initWithNibName:@"CreditCardCollectionTableViewController" bundle:nil];
                    
                    detailViewController.creditCards = self.userModel.credit_cards;
                    
                    [self.navigationController pushViewController:detailViewController animated:YES];
                    return;
                }
                default:
                    return;
            }
            break;
        case 2: {
            CreditCardCollectionTableViewController* detailViewController = [[CreditCardCollectionTableViewController alloc] initWithNibName:@"CreditCardCollectionTableViewController" bundle:nil];
            
            detailViewController.creditCards = self.userModel.credit_cards;
            
            [self.navigationController pushViewController:detailViewController animated:YES];
            return;
        }
        default:
            return;
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
    switch (indexPath.row) {
        case 0:
            self.userModel.first_name = string;
            break;
        case 1:
            self.userModel.last_name = string;
            break;
        case 2:
            self.userModel.email = string;
            break;
        case 3:
            self.userModel.phone_number = string;
            break;
        default:
            break;
    }
}


- (IBAction)backButtonTapped:(id)sender {
    self.navigationController.tabBarController.selectedViewController = [self.navigationController.tabBarController.viewControllers objectAtIndex:0];
}

- (IBAction)saveButtonTapped:(id)sender {
    [self.userModel pushChangesToServerWithSuccess:^(NSDictionary * d) {
        UIAlertView* success = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Account settings changed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [success show];
    } withFailure:^(NSError * e) {
        
        NSString* errorString = [e.userInfo objectForKey:@"message"];
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [error show];
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"CreditCardCollection"]) {
        
        ((CreditCardCollectionTableViewController*)segue.destinationViewController).creditCards = self.userModel.credit_cards;
    }
}
@end
