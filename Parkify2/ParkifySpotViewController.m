//
//  ParkifySpotViewController.m
//  Parkify2
//
//  Created by Me on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ParkifySpotViewController.h"
#import <QuartzCore/QuartzCore.h> 
#import "Authentication.h"
#import "Persistance.h"
#import "ASIFormDataRequest.h"
#import "SBJson.h"
#import "Api.h"

@interface ParkifySpotViewController ()

@end

@implementation ParkifySpotViewController

@synthesize parkingSpots = _parkingSpots;
@synthesize spot = _spot;
@synthesize infoBox = _infoBox;
@synthesize timeLabel = _timeLabel;
@synthesize priceLabel = _priceLabel;
@synthesize rangeBarContainer = _rangeBarContainer;

//@synthesize startTime = _startTime;
//@synthesize endTime = _endTime;

@synthesize errorLabel = _errorLabel;
@synthesize timerPolling = _timerPolling;
@synthesize timerDuration = _timerDuration;

@synthesize rangeBar = _rangeBar;

/*
- (void)startTime:(double)time {
    _startTime = time;
    [self updateInfo];
}
- (void)endTime:(double)time {
    _endTime = time;
    [self updateInfo];
}
*/

- (ParkingSpotCollection*)parkingSpots {
    if(!_parkingSpots) {
        _parkingSpots = [[ParkingSpotCollection alloc] init];
        _parkingSpots.observerDelegate = self;
    }
    return _parkingSpots;
}

- (void)setSpot:(ParkingSpot*)parkingSpot {
    _spot = parkingSpot;
    [self updateInfo];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*
        CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0 alpha:0.8] CGColor], (id)[[UIColor colorWithWhite:1 alpha:0.8] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
	*/
     // Do any additional setup after loading the view.
    /*
    RangeSlider *slider = [[RangeSlider alloc] initWithFrame:CGRectMake(0,0,100,20)];
    slider.minimumValue = 1;
    slider.selectedMinimumValue = 2;
    slider.maximumValue = 10;
    slider.selectedMaximumValue = 8;
    slider.minimumRange = 2;
    [slider addTarget:self action:@selector(updateRangeLabel:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:slider];
     */
    
    //It's time to duel!
    NSDate* currentDate = [NSDate date];
    
    double currentTime = [currentDate timeIntervalSince1970];
    
    currentTime = currentTime - fmod(currentTime,1800); 
    
    Formatter formatter = ^(double val) {
        NSDate* time = [[NSDate alloc] initWithTimeIntervalSince1970:val];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"h:mm a"];
        return [dateFormatter stringFromDate:time]; };
    
    self.rangeBar = [[RangeBar alloc] initWithFrame:[self.rangeBarContainer bounds] minVal:currentTime maxVal:currentTime + 6*30*60 minRange:30*60 withValueFormatter:formatter];    
    //^(double val){return [@"Foo";}
    
    [self.rangeBar addTarget:self action:@selector(timeIntervalChanged) forControlEvents:UIControlEventValueChanged];
    [self.rangeBarContainer addSubview:self.rangeBar];
    
    [self updateInfo];
    
    self.timerDuration = 20;
    [self startPolling];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopPolling];
}

- (void)timeIntervalChanged{
    [self updateInfo];
}

- (void)viewDidUnload
{
    [self setInfoBox:nil];
    [self setTimeLabel:nil];
    [self setPriceLabel:nil];
    [self setRangeBarContainer:nil];
    [self setErrorLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)spotsWereUpdated {
    self.spot = [self.parkingSpots parkingSpotForID:self.spot.mID];
}

/*
 - (NSString *)title {
 return [NSString stringWithFormat:@"%@ %d | %0.2f/hr", 
 self.spot.mCompanyName, self.spot.mLocalID, self.spot.mPrice];
 }
 - (NSString *)subtitle {
 return [NSString stringWithFormat:@"%@ to Book", self.spot.mPhoneNumber];
 }
 */

-(void)updateInfo {
    //Info box
    NSString* infoHeader;
    if(self.spot == nil) {
        infoHeader = @"Spot not found";
    }
    infoHeader = [NSString stringWithFormat:@"%@ Spot #%d | Price: %0.2f/hr\nCALL %@ to Book Now!", 
                            self.spot.mCompanyName, self.spot.mLocalID, self.spot.mPrice, self.spot.mPhoneNumber];
    [self.infoBox setText:infoHeader];
    
    //Time text
    Formatter formatter = ^(double val) {
        NSDate* time = [[NSDate alloc] initWithTimeIntervalSince1970:val];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"h:mm a"];
        return [dateFormatter stringFromDate:time]; };
    
    [self.timeLabel setText:[NSString stringWithFormat:@"%@ - %@", formatter(self.rangeBar.selectedMinimumValue), formatter(self.rangeBar.selectedMaximumValue)]];
    
    //Price text
    double durationInHours = (self.rangeBar.selectedMaximumValue - self.rangeBar.selectedMinimumValue)/3600;
    double totalPrice = self.spot.mPrice * durationInHours;
    [self.priceLabel setText:[NSString stringWithFormat:@"Total Price: $%0.2f", totalPrice]];
}

- (IBAction)parkButtonTapped:(UIButton *)sender {
    [self attemptMakeTransaction];
}

- (void) attemptMakeTransaction {
    id transactionRequest = [Authentication makeTransactionRequestWithUserToken:[Persistance retrieveAuthToken] withSpotId:self.spot.mID withStartTime:self.rangeBar.selectedMinimumValue withEndTime:self.rangeBar.selectedMaximumValue];
    
    
    NSString* urlString = [[NSString alloc] initWithFormat:@"http://swooplot.herokuapp.com/api/transactions.json?auth_token=%@", [Persistance retrieveAuthToken]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    
    
    NSLog(@"%@", [transactionRequest JSONRepresentation]);
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addPostValue:[transactionRequest JSONRepresentation] forKey:@"transaction"];
    
    [request addRequestHeader:@"User-Agent" value:@"ASIFormDataRequest"]; 
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request  setRequestMethod:@"POST"];
    [request setCompletionBlock:^{
        
        
        //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSString *responseString = [request responseString];
        NSDictionary * root = [responseString JSONValue];
        if([root objectForKey:@"success"]) {
            //Needs to happen on success
            [self stopPolling];    
            self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
            
            UIViewController* parent = [self presentingViewController];
            [self dismissViewControllerAnimated:true completion:^{
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                                         bundle: nil];
                
                UIViewController* controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"ConfirmationVC"];

                [parent presentViewController:controller animated:true completion:^{}];
                }
             ];
            
            //[self performSegueWithIdentifier:@"ViewConfirmation" sender:self];
            //NSLog(@"TEST");
        } else {
            self.errorLabel.text = [root objectForKey:@"error"];
            self.errorLabel.hidden = false;
        }
        
        NSLog(@"Response: %@", responseString);
         
        
    }];
    [request setFailedBlock:^{
        
        //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSError *error = [request error];
        NSLog(@"Error: %@", error.localizedDescription);
        if(request.responseStatusCode == 401) {
            [Api authenticateModallyFrom:self withSuccess:^(NSDictionary * result){}];
        }
        
    }];
    
    [request startAsynchronous];

}


//Starts polling if not already. Otherwise continues polling.
-(void)startPolling {
    if (self.timerPolling != nil)
    {
        return;
    } else {
        self.timerPolling = [NSTimer scheduledTimerWithTimeInterval: self.timerDuration
                                                         target: self
                                                       selector:@selector(onTick:)
                                                       userInfo: nil repeats:NO];
    }
}

-(void)stopPolling {
    if (self.timerPolling == nil)
    {
        return;
    } else {
        [self.timerPolling invalidate];
        self.timerPolling = nil;
    }
}

-(void)onTick:(NSTimer *)timer {
//do smth

    [self refreshSpots];

    self.timerPolling = [NSTimer scheduledTimerWithTimeInterval: self.timerDuration
                                                     target: self
                                                   selector:@selector(onTick:)
                                                   userInfo: nil repeats:NO];
}

- (void)refreshSpots
{
    [self.parkingSpots updateWithRequest:nil];
}


- (void)buySpot {
    //http://swooplot.herokuapp.com/api/transactions
    
    
}
/*
- (void)signUp {
    //UserRegistrationRequest* user = [[UserRegistrationRequest alloc] initWithEmail:self.emailField.text withPassword:self.passwordField.text withPasswordConfirmation:self.passwordField.text];
    id user = [Authentication makeUserRegistrationRequest:self.emailField.text
                                             withPassword:self.passwordField.text
                                 withPasswordConfirmation:self.passwordConfField.text
                                            withFirstName:self.firstNameField.text
                                             withLastName:self.lastNameField.text
                                                  withCCN:self.cardNumberField.text
                                                  withCVC:self.securityNumberField.text
                                              withCCMonth:self.expirationMonthField.text
                                               withCCYear:self.expirationYearField.text 
                                         withLicensePlate:self.licensePlateField.text];    
    
    NSURL *url = [NSURL URLWithString:@"http://swooplot.herokuapp.com/api/users"];
    NSLog(@"%@", [user JSONRepresentation]);
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addPostValue:[user JSONRepresentation] forKey:@"user"];
    [request addRequestHeader:@"User-Agent" value:@"ASIFormDataRequest"]; 
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request  setRequestMethod:@"POST"];
    [request setCompletionBlock:^{
        NSString *responseString = [request responseString];
        NSDictionary * root = [responseString JSONValue];
        if([root objectForKey:@"success"]) {
            self.errorLabel.text = [NSString stringWithFormat:@"User created! Awesomesauce! Token is: %@", [root objectForKey:@"auth_token"]];
            [Persistance saveAuthToken:[root objectForKey:@"auth_token"]];
            
        } else {
            self.errorLabel.text = [root objectForKey:@"error"];
        }
        self.errorLabel.hidden = false;
        NSLog(@"Response: %@", responseString);
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"Error: %@", error.localizedDescription);
    }];
    
    [request startAsynchronous];
}
*/
- (IBAction)closeButtonTapped:(UIButton *)sender {
    [self dismissViewControllerAnimated:true completion:^{}];
}
@end