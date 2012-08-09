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
#import "TextFormatter.h"
#import "ParkifyConfirmationViewController.h"
#import "WaitingMask.h"

@interface ParkifySpotViewController ()

@property (strong, nonatomic) WaitingMask* waitingMask;

@end

@implementation ParkifySpotViewController
@synthesize waitingMask = _waitingMask;

@synthesize taxLabel = _taxLabel;
@synthesize titleLable = _titleLable;

@synthesize parkingSpots = _parkingSpots;
@synthesize spot = _spot;
@synthesize infoScrollView = _infoScrollView;
@synthesize infoWebView = _infoWebView;
@synthesize timeDurationLabel = _timeDurationLabel;
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
    
    
    NSDate* currentDate = [NSDate date];
    
    double currentTime = [currentDate timeIntervalSince1970];
    
    //currentTime = currentTime - fmod(currentTime,1800); 
    
    Formatter formatter = ^(double val) {
        NSDate* time = [[NSDate alloc] initWithTimeIntervalSince1970:val];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"h:mm a"];
        return [dateFormatter stringFromDate:time]; };
    
    self.rangeBar = [[RangeBar alloc] initWithFrame:[self.rangeBarContainer bounds] minVal:currentTime maxVal:currentTime + 9*60*60 minRange:30*60 selectedMaxVal:currentTime + 6.25*60*60 withValueFormatter:formatter];    
    //^(double val){return [@"Foo";}
    
    [self.rangeBar addTarget:self action:@selector(timeIntervalChanged) forControlEvents:UIControlEventValueChanged];
    [self.rangeBarContainer addSubview:self.rangeBar];
    
    [self updateInfo];
    
    [self fillInfoWebView];
    
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
    [self setTitleLable:nil];
    [self setTaxLabel:nil];
    [self setTimeDurationLabel:nil];
    [self setInfoWebView:nil];
    [self setInfoScrollView:nil];
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

/** TODO: Make this javascript-enabled to update it **/
-(void)fillInfoWebView {
    NSString* infoWebViewString;
    NSString* styleString = @"<style type=\"text/css\">"
    //"body { background-color:transparent; font-family:Marker Felt; font-size:12; color:white}"
    "body { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:12; color:white}"
    "</style>";
    if(self.spot == nil) {
        infoWebViewString = [NSString stringWithFormat:@"<html>%@<body>Spot Not Available.</body></html>", styleString];
    }
    else {
        //Info web view text
        infoWebViewString = [NSString stringWithFormat:@"<html>%@<body>"
                             "<p>SpotID: %@<br/>"
                             "Distance Away: %0.2f miles</br>"
                             "Difficulty: %@</br>"
                             "Covered: %@</br>"
                             "Current Rate: $%0.2f/hr</p>"
                             "</body></html>",
                             styleString,
                             @"blah",
                             0.25,
                             @"HARD",
                             @"Yes",
                             self.spot.mPrice];
    }
    [self.infoWebView loadHTMLString:infoWebViewString baseURL:nil];
    
    CGRect frame = self.infoWebView.frame;
    frame.size.height = 1;
    self.infoWebView.frame = frame;
    CGSize fittingSize = [self.infoWebView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    self.infoWebView.frame = frame;
    self.infoScrollView.contentSize = frame.size;
        
}

-(void)updateInfo {
    //Info box
    NSString* infoTitle;
    NSString* infoBody;
    NSString* timeString;
    NSString* priceString;
    NSString* timeDurationString;
    
    
    if(self.spot == nil) {
        infoTitle = @"Spot not found";
        infoBody = @"";
        timeString = @"";
        priceString = @"";
        timeDurationString = @"";
    }
    else {
        infoTitle = [NSString stringWithFormat:@"%@ Spot #%d", 
                     self.spot.mCompanyName, self.spot.mLocalID];
        infoBody = self.spot.mDesc; 
        
        //Time text
        Formatter formatter = ^(double val) {
            NSDate* time = [[NSDate alloc] initWithTimeIntervalSince1970:val];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"h:mm a"];
            return [dateFormatter stringFromDate:time]; };
        
        timeString = [NSString stringWithFormat:@"Time Booked: %@ - %@", formatter(self.rangeBar.selectedMinimumValue), formatter(self.rangeBar.selectedMaximumValue)];
        
        //Price text
        double durationInHours = (self.rangeBar.selectedMaximumValue - self.rangeBar.selectedMinimumValue)/3600;
        double totalPrice = self.spot.mPrice * durationInHours;
        priceString = [NSString stringWithFormat:@"Total Price: $%0.2f", totalPrice];
        
        //TimeDuration text
        timeDurationString = [NSString stringWithFormat:@"%0.1f hr", durationInHours];
        
    }
    
    CGAffineTransform squish = [TextFormatter transformForSpotViewText];
    self.taxLabel.transform = squish;
    self.titleLable.text = infoTitle;  
    [self.infoBox setText:infoBody];
    self.timeLabel.text = timeString;
    self.timeLabel.transform = squish;
    self.priceLabel.text = priceString;
    self.priceLabel.transform = squish;
    self.timeDurationLabel.text = timeDurationString;
}

- (IBAction)parkButtonTapped:(UIButton *)sender {
    if (NO_SERVICE_DEBUG) {
        [self switchToConfirmation];
        return;
    }
    
    if ([Persistance retrieveAuthToken] == nil) {
        [Api authenticateModallyFrom:self withSuccess:^(NSDictionary * result){}];
        return;
    } else {
        UIAlertView* areYouSure = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
                                                          message:@"Amount of ** will be charged to credit card ending in *** for this purchase."
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Yes", nil];
        [areYouSure show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Cancel"])
    {
        //NSLog(@"Button 1 was selected.");
    }
    else if([title isEqualToString:@"Yes"])
    {
        //NSLog(@"Button 2 was selected.");
        [self attemptMakeTransaction];
    }
}

- (void) switchToConfirmation {
    [self stopPolling];    
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    UIViewController* parent = [self presentingViewController];
    [self dismissViewControllerAnimated:true completion:^{
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                                 bundle: nil];
        
        ParkifyConfirmationViewController* controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"ConfirmationVC"];
        
        controller.spot = self.spot;
        controller.startTime = self.rangeBar.selectedMinimumValue;
        controller.endTime = self.rangeBar.selectedMaximumValue;
        
        parent.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [parent presentViewController:controller animated:true completion:^{}];
    }
     ];
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
            [self switchToConfirmation];
            
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
        else {
            self.errorLabel.text = @"Could not contact server";
            self.errorLabel.hidden = false;
        }
        
    }];
    
    CGRect waitingMaskFrame = self.view.frame;
    waitingMaskFrame.origin.x = 0;
    waitingMaskFrame.origin.y = 0;
    
    self.waitingMask = [[WaitingMask alloc] initWithFrame:waitingMaskFrame];
    [self.view addSubview:self.waitingMask];
    
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

- (IBAction)closeButtonTapped:(UIButton *)sender {
    [self dismissViewControllerAnimated:true completion:^{}];
}
@end