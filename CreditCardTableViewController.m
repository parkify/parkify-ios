//
//  CreditCardTableViewController.m
//  Parkify
//
//  Created by Me on 10/25/12.
//
//

#import "CreditCardTableViewController.h"
#import "ELCTextfieldCell.h"
#import "AccountSettingsNavigationViewController.h"
#import "User.h"
#import "UIViewController+AppData_User.h"
#import "CreditCardCollectionTableViewController.h"
#import "ErrorTransformer.h"

@interface CreditCardTableViewController ()

@end

@implementation CreditCardTableViewController

@synthesize creditCardModel = _creditCardModel;

-(CreditCard*) creditCardModel {
    if(!_creditCardModel) {
        _creditCardModel = [[CreditCard alloc]init];
    }
    return _creditCardModel;
}

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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *CellIdentifier = @"CardPropertyCell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    ELCTextfieldCell *cell = (ELCTextfieldCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
    if (!cell.delegate) {
        cell = [[ELCTextfieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
        
    return cell;
    
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
            cell.leftLabel.text = @"Card Number";
            cell.rightTextField.placeholder = @"xxxxxxxxxxxxxxxx";
            [cell.rightTextField setKeyboardType:UIKeyboardTypeNumberPad];
            break;
        case 1:
            cell.leftLabel.text = @"Exp Month";
            cell.rightTextField.placeholder = @"xx";
            [cell.rightTextField setKeyboardType:UIKeyboardTypeNumberPad];
            break;
        case 2:
            cell.leftLabel.text = @"Exp Year";
            cell.rightTextField.placeholder = @"xxxx";
            [cell.rightTextField setKeyboardType:UIKeyboardTypeNumberPad];
            break;
        case 3:
            cell.leftLabel.text = @"Zip";
            cell.rightTextField.placeholder = @"xxxxx";
            [cell.rightTextField setKeyboardType:UIKeyboardTypeNumberPad];
            break;
        case 4:
            cell.leftLabel.text = @"CVC";
            cell.rightTextField.placeholder = @"xxx";
            [cell.rightTextField setKeyboardType:UIKeyboardTypeNumberPad];
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
            self.creditCardModel.credit_card_number = string;
            break;
        case 1:
            self.creditCardModel.exp_month = string;
            break;
        case 2:
            self.creditCardModel.exp_year = string;
            break;
        case 3:
            self.creditCardModel.zip = string;
            break;
        case 4:
            self.creditCardModel.cvc = string;
            break;
        default:
            break;
    }
}

/*
- (IBAction)backButtonTapped:(id)sender {
    self.navigationController.tabBarController.selectedViewController = [self.navigationController.tabBarController.viewControllers objectAtIndex:0];
}
*/

- (IBAction)saveButtonTapped:(id)sender {
    [self.creditCardModel pushToServerWithSuccess:^(NSDictionary * d) {
        UIAlertView* success = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Card accepted." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [success show];
        
        //refresh parent
        [[self getUser] updateFromServerWithSuccess:^(NSDictionary * d) {
            [self.navigationController popViewControllerAnimated:true];
        } withFailure:^(NSError * e) {
            [ErrorTransformer errorToAlert:e withDelegate:self];
        }];
    } withFailure:^(NSError * e) {
        [ErrorTransformer errorToAlert:e withDelegate:self];
        
    }];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
