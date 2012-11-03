//
//  CreditCardCollectionTableViewController.m
//  Parkify
//
//  Created by Me on 10/25/12.
//
//

#import "CreditCardCollectionTableViewController.h"
#import "AccountSettingsNavigationViewController.h"

@interface CreditCardCollectionTableViewController ()
@property BOOL updating;
@end

@implementation CreditCardCollectionTableViewController
@synthesize creditCards = _creditCards;
@synthesize updating = _updating;
@synthesize creditCardsSource = _creditCardsSource;

-(void) setCreditCards:(NSArray *)creditCards {
    _creditCards = [creditCards sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber* mID1 = [NSNumber numberWithInt:((CreditCard*)obj1).mId];
        NSNumber* mID2 = [NSNumber numberWithInt:((CreditCard*)obj2).mId];
        return (NSComparisonResult)[mID1 compare:mID2];
    }];
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
    
    self.updating = false;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    self.creditCards = [self.creditCardsSource.credit_cards copy];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.creditCards.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    
    
    NSString *CellIdentifier = @"Cell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell.textLabel) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    CreditCard* card = [self.creditCards objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"****-****-****-%@", (card.last4)];
    cell.detailTextLabel.text = card.active? @"active" : @""; 
    
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.updating) {
        return;
    }
    
    CreditCard* card = [self.creditCards objectAtIndex:indexPath.row];
    
    if(!card.active) {
        card.active = true;
        self.updating = true;
        [card pushChangesToServerWithSuccess:^(NSDictionary * d) {
            //clean out the other card
            /*
            for(CreditCard* otherCard in self.creditCards) {
                if(otherCard != card && otherCard.active) {
                    otherCard.active = false;
                }
            }*/
            [((AccountSettingsNavigationViewController*)self.navigationController).user updateFromServerWithSuccess:^(NSDictionary * d){
              
              self.creditCards = [self.creditCardsSource.credit_cards copy];
                self.updating = false;
                [self.tableView reloadData];
            }
            withFailure:^(NSError * e) {
                NSString* errorString = [e.userInfo objectForKey:@"message"];
                UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [error show];
                self.updating = false;
            }];
            
        } withFailure:^(NSError * e) {
            NSString* errorString = [e.userInfo objectForKey:@"message"];
            UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [error show];
            self.updating = false;
        }];
        
    }
    
}

@end
