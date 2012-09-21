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
@synthesize pictureActivityView = _pictureActivityView;
@synthesize imageView = _imageView;
@synthesize titleLable = _titleLable;

@synthesize flashingSign = _flashingSign;
@synthesize parkingSpots = _parkingSpots;
@synthesize spot = _spot;
@synthesize infoScrollView = _infoScrollView;
@synthesize infoWebView = _infoWebView;
@synthesize timeDurationLabel = _timeDurationLabel;
@synthesize infoBox = _infoBox;
@synthesize timeLabel = _timeLabel;
@synthesize priceLabel = _priceLabel;
@synthesize rangeBarContainer = _rangeBarContainer;

@synthesize currentLat = _currentLat;
@synthesize currentLong = _currentLong;

@synthesize distanceString = _distanceString;

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
    [self addPicture];
    
    
    NSDate* currentDate = [NSDate date];
    
    double currentTime = [currentDate timeIntervalSince1970];
    
    //currentTime = currentTime - fmod(currentTime,1800);
    
    double timeLeft = [self.spot endTime] - currentTime;
    
    timeLeft = timeLeft - fmod(timeLeft,1800);
    timeLeft = MIN(timeLeft, 18*60*60);
    
    Formatter formatter = ^(double val) {
        NSDate* time = [[NSDate alloc] initWithTimeIntervalSince1970:val];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"h:mm a"];
        return [dateFormatter stringFromDate:time]; };
    
    self.rangeBar = [[RangeBar alloc] initWithFrame:[self.rangeBarContainer bounds] minVal:currentTime maxVal:currentTime + 18*60*60 minRange:30*60 selectedMaxVal:currentTime + timeLeft withValueFormatter:formatter];
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
    [UIView animateWithDuration:0.8 animations:^{
        self.flashingSign.alpha = 0;
    }];
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
    [self setFlashingSign:nil];
    [self setPictureActivityView:nil];
    [self setImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)spotsWereUpdatedWithCount:(NSString *)count withLevelOfDetail:(NSString *)lod withSpot:(int)spotID {
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
    ".top { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:14; color:black; }"
    ".top-mid { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:10; color:#224455; }"
    ".mid { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:10; color:#556677; }"
    ".bottom { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:16; color:black; }"
    ".selected { color:#224455; } "
    ".faded { color:#99AABB; } "
    "</style>";
    if(self.spot == nil) {
        infoWebViewString = [NSString stringWithFormat:@"<html>%@<body>Spot Not Available.</body></html>", styleString];
    }
    else {
        
        NSString* layoutString = @"";
        if ([self.spot.mSpotLayout isEqualToString:@"parallel"]) {
            layoutString = @"<span class=faded>regular</span> / <span class=selected>parallel</span>";
        } else {
            layoutString = @"<span class=selected>regular</span> / <span class=faded>parallel</span>";
        }
        
        NSString* coverageString = @"";
        if ([self.spot.mSpotLayout isEqualToString:@"covered"]) {
            coverageString = @"<span class=faded>open air</span> / <span class=selected>covered";
        } else {
            coverageString = @"<span class=selected>open air</span> / <span class=faded>covered</span>";
        }

        
        //Info web view text
        infoWebViewString = [NSString stringWithFormat:@"<html>%@<body>"
                             "<span class=top>Distance Away: %@</span></br>"
                             "<span class=top-mid>%@</span></br>"
                             "<span class=mid>Difficulty: %@</span></br>"
                             "<span class=mid>Coverage: %@</span></br>"
                             "<span class=bottom>Current Rate: $%0.2f/hr</span><hr/>"
                             "<span class=top>%@</span><hr/></p>"
                             "</body></html>",
                             styleString,
                             self.distanceString,
                             self.spot.mAddress,
                             layoutString,
                             coverageString,
                             [self.spot currentPrice],
                             self.spot.mDesc];
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
        infoTitle = [NSString stringWithFormat:@"Parkify Spot"];
        infoBody = self.spot.mDesc; 
        
        //Time text
        Formatter formatter = ^(double val) {
            NSDate* time = [[NSDate alloc] initWithTimeIntervalSince1970:val];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"h:mm a"];
            return [dateFormatter stringFromDate:time]; };
        
        timeString = [NSString stringWithFormat:@"Time Booked: %@ - %@", formatter(self.rangeBar.selectedMinimumValue), formatter(self.rangeBar.selectedMaximumValue)];
        
        //Price text
        double durationInSeconds = (self.rangeBar.selectedMaximumValue - self.rangeBar.selectedMinimumValue);
        ParkingSpot* spot = self.spot;
        double totalPrice = [spot priceFromNowForDurationInSeconds:durationInSeconds];
        
        priceString = [NSString stringWithFormat:@"$%0.2f", totalPrice];
        
        //TimeDuration text
        timeDurationString = [NSString stringWithFormat:@"%0.1f", durationInSeconds/3600];
        
    }
    
    CGAffineTransform squish = [TextFormatter transformForSpotViewText];
    self.taxLabel.transform = squish;
    self.titleLable.text = infoTitle;
    [self setTitle:infoTitle];
    //[self.infoBox setText:infoBody];
    self.timeLabel.text = timeString;
    self.timeLabel.transform = squish;
    self.priceLabel.text = priceString;
    self.priceLabel.transform = squish;
    self.timeDurationLabel.text = timeDurationString;
}

- (IBAction)parkButtonTapped:(UIButton *)sender {
    BOOL notransactiondebug = false;
    if (notransactiondebug) {
        [self switchToConfirmation];
        return;
    }
    
    if ([Persistance retrieveAuthToken] == nil) {
        [Api authenticateModallyFrom:self withSuccess:^(NSDictionary * result){}];
        return;
    } else {
        double durationInSeconds = (self.rangeBar.selectedMaximumValue - self.rangeBar.selectedMinimumValue);
        double totalPrice = [self.spot priceFromNowForDurationInSeconds:durationInSeconds];
        NSString* lastfourdigits = [Persistance retrieveLastFourDigits];
        UIAlertView* areYouSure = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
                                                          message:[NSString stringWithFormat:@"Amount of %0.2f will be charged to credit card ending in %@ for this purchase.", totalPrice,lastfourdigits]
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
        [Persistance saveCurrentSpotId:self.spot.mID];
        controller.startTime = self.rangeBar. selectedMinimumValue;
        [Persistance saveCurrentStartTime:controller.startTime];
        controller.endTime = self.rangeBar.selectedMaximumValue;
        [Persistance saveCurrentEndTime:controller.endTime];
        
        controller.currentLat = self.currentLat;
        controller.currentLong = self.currentLong;
        
        [Persistance saveCurrentSpot:self.spot];
        
        parent.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [parent presentViewController:controller animated:true completion:^{}];
    }
     ];
}

- (void) attemptMakeTransaction {
    
    NSMutableArray* offerIds = [[NSMutableArray alloc] init];
    for (Offer* offer in self.spot.offers) {
        if ([offer overlapsWithStartTime:self.rangeBar.selectedMinimumValue endTime:self.rangeBar.selectedMaximumValue])
        [offerIds addObject:[NSNumber numberWithInt:offer.mId]];
    }
    
    id transactionRequest = [Authentication makeTransactionRequestWithUserToken:[Persistance retrieveAuthToken] withSpotId:self.spot.mID withStartTime:self.rangeBar.selectedMinimumValue withEndTime:self.rangeBar.selectedMaximumValue withOfferIds:offerIds withLicensePlate:[Persistance retrieveLicensePlateNumber]];
    
    NSString* urlString = [[NSString alloc] initWithFormat:@"https://parkify-rails.herokuapp.com/api/v1/acceptances.json?auth_token=%@", [Persistance retrieveAuthToken]];
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
            
            UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Error" message:[root objectForKey:@"error"] delegate:self cancelButtonTitle:@"Ok"
                                                  otherButtonTitles: nil];
            [error show];
            
            //self.errorLabel.text = [root objectForKey:@"error"];
            //self.errorLabel.hidden = false;
            [self.waitingMask removeFromSuperview];
            self.waitingMask = nil;
        }
        
        NSLog(@"Response: %@", responseString);
         
        
    }];
    [request setFailedBlock:^{
        [self.waitingMask removeFromSuperview];
        self.waitingMask = nil;
        //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSError *error = [request error];
        NSLog(@"Error: %@", error.localizedDescription);
        if(request.responseStatusCode == 401) {
            [Api authenticateModallyFrom:self withSuccess:^(NSDictionary * result){}];
        }
        else {
            UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not contact server" delegate:self cancelButtonTitle:@"Ok"
                                                  otherButtonTitles: nil];
            [error show];
            //self.errorLabel.text = @"Could not contact server";
            //self.errorLabel.hidden = false;
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
    [self.parkingSpots updateWithRequest:[NSDictionary dictionaryWithObject:@"all" forKey:@"level_of_detail"]];
}


- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:true completion:^{}];
}


-  (void)addPicture {
    if (self.spot.imageIDs != NULL && [self.spot.imageIDs count] != 0) {
        int imageID = [[self.spot.imageIDs objectAtIndex:0] intValue];
        [self.pictureActivityView startAnimating];
        [Api downloadImageDataAsynchronouslyWithId:imageID withStyle:@"original" withSuccess:^(NSDictionary * result) {
            self.imageView.image = [UIImage imageWithData:[result objectForKey:@"image"]];
            [self.pictureActivityView stopAnimating];
            [self.pictureActivityView setHidden:true];
        } withFailure:^(NSError * err) {
            self.imageView.image = [UIImage imageNamed:@"NoPic.png"];
            [self.pictureActivityView stopAnimating];
            [self.pictureActivityView setHidden:true];
        }];
    }
}

@end