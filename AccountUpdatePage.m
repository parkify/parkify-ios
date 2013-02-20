//
//  AccountUpdatePage.m
//  Parkify
//
//  Created by Me on 2/7/13.
//
//

#import "AccountUpdatePage.h"
#import "UIViewController+AppData_User.h"
#import "ErrorTransformer.h"
#import "UIView+FindFirstResponder.h"



@interface AccountUpdatePage()
@property (weak, nonatomic) IBOutlet UITableView *tableView;



//83 2h res
//user 86 5 extra credit


@property (strong, nonatomic) UIPickerView *locationsPicker;
@property (strong, nonatomic) UIToolbar    *accessoryView;
@property (strong, nonatomic) NSMutableDictionary      *locations;
@property (strong, nonatomic) NSMutableArray      *locationOrder;

@property BOOL generalInfo;
@property BOOL cardInfo;
@property BOOL carInfo;
@property (strong, nonatomic) NSString* updateType;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
- (IBAction)finishButtonTapped:(id)sender;

@property (strong, nonatomic) NSIndexPath* toBeNextResponder;
@property (strong, nonatomic) NSMutableArray* responderChain;

@end

@implementation AccountUpdatePage
@synthesize tableView = _tableView;
@synthesize locationsPicker = _locationsPicker;
@synthesize accessoryView = _accessoryView;
@synthesize user = _user;
@synthesize car = _car;
@synthesize card = _card;


- (User*)user {
    if(!_user) {
        _user = [[User alloc] init];
    }
    return _user;
}

- (Car*)car {
    if(!_car) {
        if([self.user.cars count] !=0) {
            _car = [self.user.cars objectAtIndex:0];
        } else {
            _car = [[Car alloc] init];
        }
    }
    return _car;
}

- (CreditCard*)card {
    if(!_card) {
        if([self.user.credit_cards count] !=0) {
            _card = [self.user.credit_cards objectAtIndex:0];
        } else {
            _card = [[CreditCard alloc] init];
        }
    }
    return _card;
}

- (UIPickerView *)locationsPicker {
    if ( _locationsPicker == nil ) {
        _locationsPicker = [[UIPickerView alloc] init];
        _locationsPicker.delegate = self;
        _locationsPicker.dataSource = self;
        _locationsPicker.showsSelectionIndicator = YES;
    }
    
    return _locationsPicker;
}

- (UIToolbar *)accessoryView {
    if ( _accessoryView == nil ) {
        _accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        
        UIBarButtonItem *prevButton = [[UIBarButtonItem alloc] initWithTitle:@"Prev" style:UIBarButtonItemStyleBordered target:self action:@selector(onPrev)];
        
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(onNext)];
        [nextButton setTintColor:[UIColor greenColor]];
        [prevButton setTintColor:[UIColor redColor]];
        
        
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonItemStylePlain
                                                                                    target:self
                                                                                    action:@selector(onDone)];
        
        
        [_accessoryView setTintColor:[UIColor blackColor]];
        [_accessoryView setItems:[NSArray arrayWithObjects:flexSpace, doneButton, nil]];
    }
    
    return _accessoryView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return false;
}


- (id)initWithFrame:(CGRect)frame withUpdateType:(NSString*)updateType withUser:(User*)user
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.responderChain = [[NSMutableArray alloc] init];
        self.updateType = updateType;
        self.user = user;
        
        UINib* nib;
        nib = [UINib nibWithNibName:@"AccountUpdatePage" bundle:[NSBundle mainBundle]];
        
        UIView* mainView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
        
        mainView.frame = frame;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;

        
        self.generalInfo = false;
        self.cardInfo = false;
        self.carInfo = false;
        if ([updateType isEqualToString:@"PromoteAccount"]) { //pass udid with call
            self.generalInfo = true;
            self.cardInfo = ([user.credit_cards count] == 0);
            self.carInfo = ([user.cars count] == 0);
            [self.finishButton setTitle:@"Register" forState:UIControlStateNormal];
            self.topLabel.text = @"Register for full account!";
        } else if ([updateType isEqualToString:@"AddLicensePlate"]) {
            self.generalInfo = false;
            self.cardInfo = false;
            self.carInfo = true;
            [self.finishButton setTitle:@"Add License Plate" forState:UIControlStateNormal];
            self.topLabel.text = @"Register your car so you don't get towed!";
        } else if ([updateType isEqualToString:@"Pay"]) { //pass udid with call
            self.generalInfo = true;
            self.cardInfo = ([user.credit_cards count] == 0);
            self.carInfo = ([user.cars count] == 0);
            [self.finishButton setTitle:@"Register and Pay" forState:UIControlStateNormal];
            self.topLabel.text = @"Register and pay for this spot!";
        }
                                
        [self addSubview: mainView];
        self.tableView.scrollEnabled = true;
        [self.tableView setUserInteractionEnabled:true];
        [self.tableView reloadData];
        
        self.locations = [Car licensePlateLocationDictionary];
        self.locationOrder = [Car licensePlateLocationOrder];
        
        
        self.toBeNextResponder = nil;
        [self buildResponderChain];
        
        UIEdgeInsets inset = self.tableView.contentInset;
        inset.bottom = self.tableView.frame.size.height - 90;
        self.tableView.contentInset = inset;
        
    }
    
    return self;
}

- (void)moreToLeft:(BOOL)isMore {
    
}
- (void)moreToRight:(BOOL)isMore {
    
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
}


- (NSInteger)sectionForInput: (NSString*)input{
    if([input isEqualToString:@"General"]) {
        if(!self.generalInfo) {
            return -1;
        }
        return 0;
    } else if([input isEqualToString:@"Card"]) {
        if(!self.cardInfo) {
            return -2;
        }
        return self.generalInfo;
    } else if([input isEqualToString:@"Car"]) {
        if(!self.carInfo) {
            return -3;
        }
        return self.cardInfo + self.generalInfo;
    } else {
        return -9;
    }
}

- (NSInteger)rowForInput: (NSString*)input {
    
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.generalInfo + self.cardInfo + self.carInfo;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section == [self sectionForInput:@"General"]) {
        return 5;
    } else if (section == [self sectionForInput:@"Card"]) {
        return 6;
    } else if (section == [self sectionForInput:@"Car"]) {
        return 2;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section <= 2) {
        NSString *CellIdentifier = @"UserPropertyCell";
        if(indexPath.section == [self sectionForInput:@"Card"] && indexPath.row == 0) {
            CellIdentifier = @"CreditCardImageCell";
        }
        if(indexPath.section == [self sectionForInput:@"Car"] && indexPath.row == 1) {
            CellIdentifier = @"LicensePlateStateCell";
        }
        
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
    UIImageView* cards = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - 208)/2.0,2,208,31)];
    [cards setContentMode:UIViewContentModeScaleAspectFit];
    cards.image = [UIImage imageNamed:@"credit_card_logos_26.gif"];
    [cell.rightTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [cell.rightTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [cell.rightTextField setKeyboardType:UIKeyboardTypeAlphabet];
    
    cell.rightTextField.delegate = self;
    cell.rightTextField.tag = [self tagForIndexPath:indexPath];
    cell.rightTextField.inputAccessoryView = self.accessoryView;
    // Configure the cell...
    if(indexPath.section == [self sectionForInput:@"General"]) {
        switch (indexPath.row) {
            case 0:
                cell.leftLabel.text = @"First Name";
                cell.rightTextField.text = self.user.first_name;
                break;
            case 1:
                cell.leftLabel.text = @"Last Name";
                cell.rightTextField.text = self.user.last_name;
                break;
            case 2:
                cell.leftLabel.text = @"Email";
                cell.rightTextField.text = self.user.email;
                [cell.rightTextField setKeyboardType:UIKeyboardTypeEmailAddress];
                break;
            case 3:
                cell.leftLabel.text = @"Password";
                cell.rightTextField.text = self.user.password;
                break;
            case 4:
                cell.leftLabel.text = @"Phone Number";
                cell.rightTextField.text = self.user.phone_number;
                [cell.rightTextField setKeyboardType:UIKeyboardTypeNumberPad];
                break;
            default:
                cell.rightTextField.tag = 0;
                break;
        }

    } else if (indexPath.section == [self sectionForInput:@"Card"]) {
        switch (indexPath.row) {
            case 0:
                cell.leftLabel.text = @"";
                cell.rightTextField.text = @"";
                cell.rightTextField.userInteractionEnabled = false;
                cell.rightTextField.tag = 0;
                [cell addSubview:cards];
                break;
            case 1:
                cell.leftLabel.text = @"Card Number";
                cell.rightTextField.text = self.card.credit_card_number;
                [cell.rightTextField setKeyboardType:UIKeyboardTypeNumberPad];
                break;
            case 2:
                cell.leftLabel.text = @"Exp Month";
                cell.rightTextField.placeholder = @"MM";
                cell.rightTextField.text = self.card.exp_month;
                [cell.rightTextField setKeyboardType:UIKeyboardTypeNumberPad];
                break;
            case 3:
                cell.leftLabel.text = @"Exp Year";
                cell.rightTextField.placeholder = @"YYYY";
                cell.rightTextField.text = self.card.exp_year;
                [cell.rightTextField setKeyboardType:UIKeyboardTypeNumberPad];
                break;
            case 4:
                cell.leftLabel.text = @"CVC";
                cell.rightTextField.text = self.card.cvc;
                [cell.rightTextField setKeyboardType:UIKeyboardTypeNumberPad];
                break;
            case 5:
                cell.leftLabel.text = @"Zip Code";
                cell.rightTextField.text = self.card.zip;
                [cell.rightTextField setKeyboardType:UIKeyboardTypeNumberPad];
                break;
            default:
                cell.rightTextField.tag = 0;
                break;
        }
    } else if (indexPath.section == [self sectionForInput:@"Car"]) {
        switch (indexPath.row) {
            case 0:
                cell.leftLabel.text = @"License Plate";
                cell.rightTextField.text = self.car.license_plate_number;
                break;
            case 1:
                cell.leftLabel.text = @"State";
                cell.rightTextField.text = self.car.state;
                cell.rightTextField.inputView = self.locationsPicker;
                break;
            default:
                cell.rightTextField.tag = 0;
                break;
        }
    } else {
        cell.rightTextField.tag = 0;
        return;
    }
        
}
- (void)configureSegueCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    /*
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
     */
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 1:
            /*
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
             */
            break;
        case 2: {
            /*
            [self performSegueWithIdentifier:@"Password" sender:self];
             */
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
    
    if(indexPath.section == [self sectionForInput:@"General"]) {
        switch (indexPath.row) {
            case 0:
                self.user.first_name = string;
                break;
            case 1:
                self.user.last_name = string;
                break;
            case 2:
                self.user.email = string;
                break;
            case 3:
                self.user.password = string;
                break;
            case 4:
                self.user.phone_number = string;
                break;
            default:
                break;
        }
    } else if (indexPath.section == [self sectionForInput:@"Card"]) {
        switch (indexPath.row) {
            case 1:
                self.card.credit_card_number = string;
                break;
            case 2:
                self.card.exp_month = string;
                break;
            case 3:
                self.card.exp_year = string;
                break;
            case 4:
                self.card.cvc = string;
                break;
            case 5:
                self.card.zip = string;
                break;
            default:
                break;
        }
    } else if (indexPath.section == [self sectionForInput:@"Car"]) {
        switch (indexPath.row) {
            case 0:
                self.car.license_plate_number = string;
                break;
            case 1:
                self.car.state = string;
                break;
            default:
                break;
        }
    } else {
        return;
    }
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 35;
}


#pragma mark - picker view delegate/datasource

- (void)onPrev {
    [self updatePickerFields];
    UIView* view = [self findFirstResponder];
    if(view) {
        [self previous:view.tag];
    }
}

- (void)onNext {
    [self updatePickerFields];
    UIView* view = [self findFirstResponder];
    if(view) {
        [self next:view.tag];
    }
}

- (void)onDone {
    [self updatePickerFields];
    [self done];
}

- (void)updatePickerFields {
    UIView* view = [self findFirstResponder];
    
    if(view && view.tag == [self tagForIndexPath:[NSIndexPath indexPathForRow:1 inSection:[self sectionForInput:@"Car"]]]) {
        NSInteger row = [self.locationsPicker selectedRowInComponent:0];
        NSString* stateAbbr = [self.locations objectForKey:[self.locationOrder objectAtIndex:row]];
        self.car.state = stateAbbr;
        [self.tableView reloadData];
    }
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.locationOrder objectAtIndex:row];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.locationOrder count];
}


#pragma mark - textedit delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.tableView scrollToRowAtIndexPath:[self pathForTag:textField.tag]
                          atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if(textField.tag == [self tagForIndexPath:[NSIndexPath indexPathForRow:1 inSection:[self sectionForInput:@"Car"]]]) {
        return YES;
    }
    [self updateTextLabelAtIndexPath:[self pathForTag:textField.tag] string:textField.text ];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if(textField.tag == 0) {
        return YES;
    }
    
    if(textField.tag == [self tagForIndexPath:[NSIndexPath indexPathForRow:4 inSection:[self sectionForInput:@"General"]]]) {
        int length = [self getLength:textField.text];
        //NSLog(@"Length  =  %d ",length);
        
        if(length == 10)
        {
            if(range.length == 0)
                return NO;
        }
        
        if(length == 3)
        {
            NSString *num = [self formatNumber:textField.text];
            textField.text = [NSString stringWithFormat:@"(%@) ",num];
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
        }
        else if(length == 6)
        {
            NSString *num = [self formatNumber:textField.text];
            //NSLog(@"%@",[num  substringToIndex:3]);
            //NSLog(@"%@",[num substringFromIndex:3]);
            textField.text = [NSString stringWithFormat:@"(%@) %@-",[num  substringToIndex:3],[num substringFromIndex:3]];
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"(%@) %@",[num substringToIndex:3],[num substringFromIndex:3]];
        }
    }
    
    return YES;
    
}

-(NSString*)formatNumber:(NSString*)mobileNumber
{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    NSLog(@"%@", mobileNumber);
    
    int length = [mobileNumber length];
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
        NSLog(@"%@", mobileNumber);
        
    }
    
    
    return mobileNumber;
}


-(int)getLength:(NSString*)mobileNumber
{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = [mobileNumber length];
    
    return length;
    
    
}


#pragma mark - ScrollView Delegate
-(void)next: (int) from {
    int i = 0;
    for (NSIndexPath* pathIter in self.responderChain) {
        if ([self tagForIndexPath:pathIter] == from) {
            break;
        }
        i++;
    }
    if(i == [self.responderChain count]) {
        [self done];
        return;
    }
    if(i == [self.responderChain count]-1) {
        [self done];
        return;
    }
    NSLog(@"Next: %d -> %d", from, [self tagForIndexPath:[self.responderChain objectAtIndex:i+1]]);
    NSIndexPath* next = [self.responderChain objectAtIndex:i+1];
    
    BOOL visible = false;
    for (UITableViewCell* cell in self.tableView.visibleCells) {
        if([cell respondsToSelector:@selector(rightTextField)]) {
            if(((ELCTextfieldCell*)cell).rightTextField.tag == [self tagForIndexPath:[self.responderChain objectAtIndex:i+1]]) {
                visible = true;
                break;
            }
        }
    }
    if(visible) {
        UITableViewCell* cell =  [self.tableView cellForRowAtIndexPath:next];
        if(!cell || ![cell respondsToSelector:@selector(rightTextField)]) {
            UIView* view = [self findFirstResponder];
            if(view) {
                [view resignFirstResponder];
            }
        } else {
            [((ELCTextfieldCell*) cell).rightTextField becomeFirstResponder];
        }
    } else {
        self.toBeNextResponder = next;
        [self.tableView scrollToRowAtIndexPath:self.toBeNextResponder
                              atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    
    
}
-(void)previous: (int) from {
    int i = 0;
    for (NSIndexPath* pathIter in self.responderChain) {
        if ([self tagForIndexPath:pathIter] == from) {
            break;
        }
        i++;
    }
    if(i == [self.responderChain count]) {
        [self done];
        return;
    }
    if(i == 0) {
        [self done];
        return;
    }
    NSLog(@"Prev: %d -> %d", from, [self tagForIndexPath:[self.responderChain objectAtIndex:i-1]]);
    NSIndexPath* prev = [self.responderChain objectAtIndex:i-1];
    self.toBeNextResponder = prev;
    
    [self.tableView scrollToRowAtIndexPath:self.toBeNextResponder
                     atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
}
-(void)done {
    self.toBeNextResponder = nil;
    UIView* view = [self findFirstResponder];
    if(view) {
        [view resignFirstResponder];
    }
    
}



-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.toBeNextResponder) {
        UITableViewCell* cell =  [self.tableView cellForRowAtIndexPath:self.toBeNextResponder];
        if(!cell || ![cell respondsToSelector:@selector(rightTextField)]) {
            UIView* view = [self findFirstResponder];
            if(view) {
                [view resignFirstResponder];
            }
        } else {
            [((ELCTextfieldCell*) cell).rightTextField becomeFirstResponder];
        }
        self.toBeNextResponder = nil;
    }
    
}





/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(void) buildResponderChain {
    if(self.generalInfo) {
        [self.responderChain addObject:[NSIndexPath indexPathForRow:0 inSection:[self sectionForInput:@"General"]]];
        [self.responderChain addObject:[NSIndexPath indexPathForRow:1 inSection:[self sectionForInput:@"General"]]];
        [self.responderChain addObject:[NSIndexPath indexPathForRow:2 inSection:[self sectionForInput:@"General"]]];
        [self.responderChain addObject:[NSIndexPath indexPathForRow:3 inSection:[self sectionForInput:@"General"]]];
        [self.responderChain addObject:[NSIndexPath indexPathForRow:4 inSection:[self sectionForInput:@"General"]]];
    }
    if(self.cardInfo) {
        [self.responderChain addObject:[NSIndexPath indexPathForRow:1 inSection:[self sectionForInput:@"Card"]]];
        [self.responderChain addObject:[NSIndexPath indexPathForRow:2 inSection:[self sectionForInput:@"Card"]]];
        [self.responderChain addObject:[NSIndexPath indexPathForRow:3 inSection:[self sectionForInput:@"Card"]]];
        [self.responderChain addObject:[NSIndexPath indexPathForRow:4 inSection:[self sectionForInput:@"Card"]]];
        [self.responderChain addObject:[NSIndexPath indexPathForRow:5 inSection:[self sectionForInput:@"Card"]]];
    }
    if(self.carInfo) {
        [self.responderChain addObject:[NSIndexPath indexPathForRow:0 inSection:[self sectionForInput:@"Car"]]];
        [self.responderChain addObject:[NSIndexPath indexPathForRow:1 inSection:[self sectionForInput:@"Car"]]];
    }
}

-(int) tagForIndexPath:(NSIndexPath*)path {
    return (path.section * 100) + path.row+1;
}
-(NSIndexPath*)pathForTag:(int)tag {
    return [NSIndexPath indexPathForRow:(tag%100)-1 inSection:tag/100];
}

- (IBAction)finishButtonTapped:(id)sender {
    [self sendActionsForControlEvents:ShouldContinueActionEvent];
}
@end