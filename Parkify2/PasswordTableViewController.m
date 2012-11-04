//
//  PasswordTableViewController.m
//  Parkify
//
//  Created by Me on 10/29/12.
//
//

#import "PasswordTableViewController.h"
#import "ELCTextfieldCell.h"
#import "Api.h"
#import "AccountSettingsNavigationViewController.h"
#import "UIViewController+AppData_User.h"
#import "ErrorTransformer.h"

@interface PasswordTableViewController ()

@end

@implementation PasswordTableViewController

@synthesize password = _password;
@synthesize passwordConf = _passwordConf;
@synthesize origPassword = _origPassword;

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

-(void) viewWillAppear:(BOOL)animated {
  self.origPassword = @"";
  self.password = @"";
  self.passwordConf = @"";
  [self.tableView reloadData];
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *CellIdentifier = @"PasswordCell";
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
  [cell.rightTextField setKeyboardType:UIKeyboardTypeDefault];
  [cell.rightTextField setSecureTextEntry:true];
  
  // Configure the cell...
  switch (indexPath.row) {
    case 0:
      cell.leftLabel.text = @"Current";
      cell.rightTextField.placeholder = @"xxxxxx";
      
      break;
    case 1:
      cell.leftLabel.text = @"New";
      cell.rightTextField.placeholder = @"xxxxxx";
      break;
    case 2:
      cell.leftLabel.text = @"Re-type new";
      cell.rightTextField.placeholder = @"xxxxxx";
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
      self.origPassword = string;
      break;
    case 1:
      self.password = string;
      break;
    case 2:
      self.passwordConf = string;
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
  [Api updatePassword:self.password passwordConfirmation:self.passwordConf origPassword:self.origPassword withSuccess:^(NSDictionary * d) {
    
    UIAlertView* success = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Password successfully changed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [success show];
    //Update Auth_token now that password has changed!
    
    
    //refresh parent
    [[self getUser] updateFromServerWithSuccess:^(NSDictionary * d) {
      [self.navigationController popViewControllerAnimated:true];
    } withFailure:^(NSError * e) {
      NSString* errorString = [e.userInfo objectForKey:@"message"];
      [ErrorTransformer errorToAlert:e withDelegate:self];
    }];
    
  } withFailure:^(NSError * e) {
    
    [ErrorTransformer errorToAlert:e withDelegate:self];
    
  }];
  
  
}



@end
