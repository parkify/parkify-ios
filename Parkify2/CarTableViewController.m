//
//  CarTableViewController.m
//  Parkify
//
//  Created by Me on 10/26/12.
//
//

#import "CarTableViewController.h"
#import "ELCTextfieldCell.h"
#import "AccountSettingsNavigationViewController.h"
#import "UIViewController+AppData_User.h"
#import "ErrorTransformer.h"

@interface CarTableViewController ()

@end

@implementation CarTableViewController
@synthesize car = _car;

-(Car*)car {
    if(!_car)
        _car = [[Car alloc] init];
    return _car;
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

- (void)viewWillAppear:(BOOL)animated {
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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CarCell";
    ELCTextfieldCell *cell = (ELCTextfieldCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell.delegate) {
        cell = [[ELCTextfieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
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

- (void)configureCell:(ELCTextfieldCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
	cell.indexPath = indexPath;
	cell.delegate = self;
    
    //Disables UITableViewCell from accidentally becoming selected.
    cell.selectionStyle = UITableViewCellEditingStyleNone;
    cell.rightTextField.placeholder = @"";
    
    cell.leftLabel.text = @"License Plate";
    cell.rightTextField.text = self.car.license_plate_number;
}

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
    self.car.license_plate_number = string;
}

- (IBAction)saveButtonTapped:(id)sender {
    [self.car pushToServerWithSuccess:^(NSDictionary * d) {
        UIAlertView* success = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Vehicle registered." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
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

@end