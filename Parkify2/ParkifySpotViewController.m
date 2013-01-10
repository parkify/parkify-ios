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
#import "RangeBubble.h"
#import "MultiImageViewer.h"
#import "UIViewController+AppData_ParkingSpotCollection.h"
#import "ErrorTransformer.h"
#import "ParkifyAppDelegate.h"
#import "Mixpanel.h"
//#import "PlacedAgent.h"

@interface ParkifySpotViewController ()

@property (strong, nonatomic) WaitingMask* waitingMask;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIScrollView *pictureScrollView;

@end

@implementation ParkifySpotViewController
@synthesize waitingMask = _waitingMask;
@synthesize pageControl = _pageControl;
@synthesize pictureScrollView = _pictureScrollView;
@synthesize taxLabel = _taxLabel;
//@synthesize pictureActivityView = _pictureActivityView;
//@synthesize imageView = _imageView;
@synthesize titleLable = _titleLable;

@synthesize flashingSign = _flashingSign;
@synthesize spot = _spot;
//@synthesize infoScrollView = _infoScrollView;
@synthesize infoWebView = _infoWebView;
@synthesize timeDurationLabel = _timeDurationLabel;
//@synthesize infoBox = _infoBox;
//@synthesize timeLabel = _timeLabel;
@synthesize priceLabel = _priceLabel;
@synthesize rangeBarContainer = _rangeBarContainer;

@synthesize currentLat = _currentLat;
@synthesize currentLong = _currentLong;

@synthesize distanceString = _distanceString;

//@synthesize startTime = _startTime;
//@synthesize endTime = _endTime;

//@synthesize errorLabel = _errorLabel;
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
    //[self addAllPictures];
    //[PlacedAgent logPageView:@"SpotInfoView"];
    
    NSMutableDictionary* demoDict = [Persistance retrieveDemoDict];
    if (![demoDict objectForKey:@"SpotViewControllerDemo"])
    {
        [demoDict setObject:[NSNumber numberWithBool:true] forKey:@"SpotViewControllerDemo"];
        [self.demoMask setAlpha:1.0];
        [Persistance saveDemoDict:demoDict];
    }
    
    [self.timeTypeSelectHourlyButton setSelected:true];
    
    NSDate* currentDate = [NSDate date];
    
    double currentTime = [currentDate timeIntervalSince1970];
    MultiImageViewer* miViewer = [[MultiImageViewer alloc] initWithFrame:self.multiImageViewFrame.frame withImageIds:self.spot.landscapeInfoImageIDs];
    
    CGRect frame = miViewer.frame;
    frame.origin = CGPointMake(0,0);
    miViewer.frame = frame;
    [self.multiImageViewFrame addSubview:miViewer];
    
    //currentTime = currentTime - fmod(currentTime,1800);
    
    double timeLeft = [self.spot endTime] - currentTime;
    
    double numHours = 9;
    
    timeLeft = timeLeft - fmod(timeLeft,1800);
    timeLeft = MIN(timeLeft, numHours*60*60);
    
    
    double prevHourMark = (floor(currentTime/3600))*3600;
    
    Formatter timeFormatter = ^(double val) {
        NSDate* time = [[NSDate alloc] initWithTimeIntervalSince1970:val];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"ha"];
        return [dateFormatter stringFromDate:time]; };
    

    double maxVal = self.spot.endTime;
    
    /* rangeBar */
    self.rangeBar = [[RangeBar alloc] initWithFrame:[self.rangeBarContainer bounds] minVal:prevHourMark minimumSelectableValue:prevHourMark maxVal:maxVal minRange:30*60 displayedRange:numHours*60*60 selectedMinVal:currentTime selectedMaxVal:currentTime+(30*60) withTimeFormatter:timeFormatter withPriceFormatter:^NSString *(double val) {
        if(fmod(val,1.0) >= 0.01) {
            return [NSString stringWithFormat:@"$%0.2f", val];
        } else {
            return [NSString stringWithFormat:@"$%0.0f", val];
        }
    } withPriceSource:self.spot];
    [self.rangeBar addTarget:self action:@selector(timeIntervalChanged) forControlEvents:UIControlEventValueChanged];
    [self.rangeBarContainer addSubview:self.rangeBar];
    
    /* flatRateBar */
    self.flatRateBar = [[FlatRateBar alloc] initWithFrame:[self.flatRateBarContainer bounds] withPrices:[self.spot flatRatePricesForStartTime:currentTime]];
    [self.flatRateBar addTarget:self action:@selector(timeIntervalChanged) forControlEvents:UIControlEventValueChanged];
    [self.flatRateBarContainer addSubview:self.flatRateBar];
    
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
        self.demoMask.alpha = 0;
    }];
    
    [self updateInfo];
}

- (void)viewDidUnload
{
    [self setPriceLabel:nil];
    [self setRangeBarContainer:nil];
    [self setTitleLable:nil];
    [self setTaxLabel:nil];
    [self setTimeDurationLabel:nil];
    [self setInfoWebView:nil];
    [self setFlashingSign:nil];
    [self setStartTimeLabel:nil];
    [self setEndTimeALabel:nil];
    [self setEndTimeLabel:nil];
    [self setPageControl:nil];
    [self setPictureScrollView:nil];
    [self setMultiImageViewFrame:nil];
    [self setTimeCenterReference:nil];
    [self setDurationCenterReference:nil];
    [self setPriceCenterReference:nil];
    [self setStartTimeALabel:nil];
    [self setPriceCurrencyLabel:nil];
    [self setTimeDurationHourStaticLabel:nil];
    [self setTimeDurationMinutesLabel:nil];
    [self setTimeDurationMinutesStaticLabel:nil];
    [self setTimeTypeSelectHourlyButton:nil];
    [self setTimeTypeSelectFlatRateButton:nil];
    [self setFlatRateBarContainer:nil];
    [self setDemoMask:nil];
    [self setWarningLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)spotsWereUpdatedWithCount:(NSString *)count withLevelOfDetail:(NSString *)lod withSpot:(int)spotID {
    self.spot = [[self getParkingSpots] parkingSpotForID:self.spot.mID];
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
    ".l1 { background-color:transparent; font-family:\"HelveticaNeue-Bold\"; font-size:12; color:white}"
    ".l2 { background-color:transparent; font-family:\"HelveticaNeue-Bold\"; font-size:30; color:white;}"
    ".l3 { background-color:transparent; font-family:\"HelveticaNeue-Bold\"; font-size:12; color:white;}"
    ".l4 { background-color:transparent; font-family:\"HelveticaNeue-Bold\"; font-size:12; color:white; }"
    ".selected { color:white; } "
    ".faded { color:white; }"
    ".fake-space {font-size:5;}"
    "</style>";
    if(self.spot == nil) {
        infoWebViewString = [NSString stringWithFormat:@"<html>%@<body>Spot Not Available.</body></html>", styleString];
    }
    else {
        
        NSString* layoutString = @"";
        if ([self.spot.mSpotLayout isEqualToString:@"parallel"]) {
            layoutString = @"<span class=faded>YES</span>";
        } else {
            layoutString = @"<span class=selected>NO</span>";
        }
        
        NSString* coverageString = @"";
        if ([self.spot.mSpotLayout isEqualToString:@"covered"]) {
            coverageString = @"<span class=faded>YES</span>"    ;
        } else {
            coverageString = @"<span class=selected>NO</span>";
        }

        
        //Info web view text
        infoWebViewString = [NSString stringWithFormat:@"<html>%@<body>"
                             "<span class=l1>Distance away</span></br>"
                             "<span class=l2>%@</span></br>"
                             "<span class=l3>%@</span></br>"
                             "<span class=fake-space></br></span>"
                             "<span class=fake-space></br></span>"
                             "<span class=l4>PARALLEL: %@</span></br>"
                             "<span class=l4>COVERED: %@</span>"
                             "</body></html>",
                             styleString,
                             self.distanceString,
                             [TextFormatter formatSecuredAddressString:self.spot.mAddress],
                             layoutString,
                             coverageString];
    }
    [self.infoWebView loadHTMLString:infoWebViewString baseURL:nil];
    
    CGRect frame = self.infoWebView.frame;
    frame.size.height = 1;
    self.infoWebView.frame = frame;
    CGSize fittingSize = [self.infoWebView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    self.infoWebView.frame = frame;
        
}

-(void)updateInfo {
    //Info box
    NSString* infoTitle;
    NSString* infoBody;
    NSString* timeString;
    NSString* priceString;
    NSString* timeDurationHoursString;
    NSString* timeDurationMinutesString;
    NSString* startTime;
    NSString* endTime;
    NSString* startTimeA;
    NSString* endTimeA;
    self.warningLabel.alpha = 0;
    
    if(self.spot == nil) {
        infoTitle = @"Spot not found";
        infoBody = @"";
        timeString = @"";
        priceString = @"";
        timeDurationHoursString = @"";
        timeDurationMinutesString = @"";
        startTime = @"";
        endTime = @"";
    }
    else {
        //infoTitle = [NSString stringWithFormat:@"Parkify Spot"];
        infoBody = self.spot.mDesc; 
        
        //Time text
        Formatter formatterMain = ^(double val) {
            NSDate* time = [[NSDate alloc] initWithTimeIntervalSince1970:val];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"h:mm"];
            return [dateFormatter stringFromDate:time]; };
        
        Formatter formatterA = ^(double val) {
            NSDate* time = [[NSDate alloc] initWithTimeIntervalSince1970:val];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"a"];
            return [dateFormatter stringFromDate:time]; };

        double dStartTime = self.rangeBar.selectedMinimumValue;
        double dEndTime = self.rangeBar.selectedMaximumValue;
        if(self.timeTypeSelectFlatRateButton.selected) {
            dEndTime = dStartTime + [self.flatRateBar selectedDuration];
            if (dEndTime > [self.spot endTime]) {
                self.warningLabel.text = @"This spot is unavailable for some of the selected duration.";
                self.warningLabel.alpha = 1;
            }
            dEndTime = MIN(dEndTime, [self.spot endTime]);
        }
        
        startTime = formatterMain(dStartTime);
        startTimeA = formatterA(dStartTime);
        
        endTime = formatterMain(dEndTime);
        endTimeA = formatterA(dEndTime);
        
        //Price text
        double durationInSeconds = (dEndTime - dStartTime);
        ParkingSpot* spot = self.spot;
        double totalPrice = [spot priceFromNowForDurationInSeconds:durationInSeconds];
        
        if(self.timeTypeSelectFlatRateButton.selected) {
            totalPrice = [self.flatRateBar selectedPrice];
        }
        
        priceString = [NSString stringWithFormat:@"%0.2f", totalPrice];
        
        //TimeDuration text
        double hoursAndMinutes = round(durationInSeconds/60)/60;
        int hours = floor(hoursAndMinutes);
        int minutes = floor((hoursAndMinutes-hours)*60);

        
        timeDurationHoursString = [NSString stringWithFormat:@"%d", hours];
        timeDurationMinutesString = [NSString stringWithFormat:@"%@%d", (minutes<=9) ? @"0" : @"", minutes ];
        
    }
    
    CGAffineTransform squish = [TextFormatter transformForSpotViewText];
    //self.taxLabel.transform = squish;
    //self.titleLable.text = infoTitle;
    //[self setTitle:infoTitle];
   // self.timeLabel.text = timeString;
    //self.timeLabel.transform = squish;
    self.priceLabel.text = priceString;
    //self.priceLabel.transform = squish;
    
    self.timeDurationLabel.text = timeDurationHoursString;
    self.timeDurationMinutesLabel.text = timeDurationMinutesString;
    
    self.startTimeLabel.text = startTime;
    self.startTimeALabel.text = startTimeA;
    self.endTimeALabel.text = endTimeA;
    self.endTimeLabel.text = endTime;
    
    
    [self positionLabels:[NSArray arrayWithObjects:self.startTimeLabel, self.startTimeALabel, nil] aroundVertical:self.timeCenterReference.center.x];
    [self positionLabels:[NSArray arrayWithObjects:self.endTimeLabel, self.endTimeALabel, nil] aroundVertical:self.timeCenterReference.center.x];
    [self positionLabels:[NSArray arrayWithObjects:self.timeDurationLabel, self.timeDurationHourStaticLabel, self.timeDurationMinutesLabel, self.timeDurationMinutesStaticLabel, nil] aroundVertical:self.durationCenterReference.center.x];
    [self positionLabels:[NSArray arrayWithObjects:self.priceCurrencyLabel, self.priceLabel, nil] aroundVertical:self.priceCenterReference.center.x];
    
    
    [self.rangeBarContainer setHidden:!self.timeTypeSelectHourlyButton.selected];
    [self.flatRateBarContainer setHidden:!self.timeTypeSelectFlatRateButton.selected];
    
    //CGRect frame = self.endTimeALabel.frame;
    //CGSize size = [endTime sizeWithFont:self.endTimeLabel.font];
    //frame.origin.x = self.endTimeLabel.frame.origin.x + size.width + 1;
    //self.endTimeALabel.frame = frame;
}

//TODO: Generalize to include other formatting options
- (void) positionLabels:(NSArray*)labels aroundVertical:(double)centerX{
    if ([labels count] == 0) {
        return;
    }
    
    double totalWidth = 0;
    for (UILabel* label in labels) {
        totalWidth += [label.text sizeWithFont:label.font].width;
        totalWidth += (label != [labels lastObject]) ? 1 : 0;
    }
    double iterX = centerX - (totalWidth/2.0);
    for (UILabel* label in labels) {
        CGRect frame = label.frame;
        frame.origin.x = iterX;
        frame.size.width = [label.text sizeWithFont:label.font].width;
        label.frame = frame;
        iterX+= 1 + [label.text sizeWithFont:label.font].width;
    }
}


- (IBAction)parkButtonTapped:(UIButton *)sender {
    if (NOTRANSACTIONDEBUG) {
        [self switchToConfirmation:nil];
        return;
    }
    ParkifyAppDelegate *delegate = (ParkifyAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if ([Persistance retrieveAuthToken] == nil && ![delegate reservationUsed]) {
        
        [Api authenticateModallyFrom:self withSuccess:^(NSDictionary * result)
        {
            NSString *status = [[result objectForKey:@"exit"] copy];
            NSLog(@"result status is %@", status);
            if ( [status isEqualToString:@"logged_in"]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Logged in");
                    [self previewTransaction];
                        });

            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Not Logged in");
                });

            }
        }
        
         ];
        return;
    } else {
        
        //[Api previewTransaction:self.spot withStartTime:self.rangeBar.selectedMinimumValue andEndTime:self.rangeBar.selectedMaximumValue withASIdelegate:self];
        [self previewTransaction];
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

- (void) switchToConfirmation:(NSDictionary*)paymentDetails {
    [self stopPolling];    
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    UIViewController* parent = [self presentingViewController];
    [self dismissViewControllerAnimated:true completion:^{
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                                 bundle: nil];
        
        ParkifyConfirmationViewController* controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"ConfirmationVC"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [navController.navigationBar setTintColor:[UIColor blackColor]];
        controller.spot = self.spot;
        if(paymentDetails != nil) {
            NSMutableDictionary *thetransaction = [Persistance addNewTransaction:self.spot withStartTime:self.rangeBar. selectedMinimumValue andEndTime:self.rangeBar.selectedMaximumValue andLastPaymentDetails:[paymentDetails objectForKey:@"details"] withTransactionID:[paymentDetails objectForKey:@"id"]];
            [[Mixpanel sharedInstance] track:@"launchConfirmationVC" properties:thetransaction];
            controller.transactionInfo = thetransaction;
            controller.topBarText = [paymentDetails objectForKey:@"details"];
            [Persistance saveCurrentSpot:self.spot];
        } else {
             controller.topBarText = @"";
        }
     
        controller.currentLat = self.currentLat;
        controller.currentLong = self.currentLong;
        
        
        
        
        parent.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [parent presentViewController:navController animated:true completion:^{}];
    }
     ];
}

- (void) attemptMakeTransaction {
    [[Mixpanel sharedInstance] track:@"transactionattempt"];
    
    CGRect waitingMaskFrame = self.view.frame;
    waitingMaskFrame.origin.x = 0;
    waitingMaskFrame.origin.y = 0;
    
    self.waitingMask = [[WaitingMask alloc] initWithFrame:waitingMaskFrame];
    [self.view addSubview:self.waitingMask];
    
    double dStartTime = self.rangeBar.selectedMinimumValue;
    double dEndTime = self.rangeBar.selectedMaximumValue;
    NSString* priceType = @"hourly";
    NSString* flatRateName = @"";
    if(self.timeTypeSelectFlatRateButton.selected) {
        dEndTime = dStartTime + [self.flatRateBar selectedDuration];
        dEndTime = MIN(dEndTime, [self.spot endTime]);
        priceType = @"flat_rate";
        flatRateName = [self.flatRateBar selectedFlatRateName];
    }
    
    [Api tryTransacation:self.spot withStartTime:dStartTime andEndTime:dEndTime withASIdelegate:self isPreview:FALSE withPriceType:priceType withFlatRateName:flatRateName withExtraParameter:@""];
    
    return;

}



- (void) previewTransaction {
    [[Mixpanel sharedInstance] track:@"transactionpreview"];
    
    CGRect waitingMaskFrame = self.view.frame;
    waitingMaskFrame.origin.x = 0;
    waitingMaskFrame.origin.y = 0;
    
    self.waitingMask = [[WaitingMask alloc] initWithFrame:waitingMaskFrame];
    [self.view addSubview:self.waitingMask];
    
    double dStartTime = self.rangeBar.selectedMinimumValue;
    double dEndTime = self.rangeBar.selectedMaximumValue;
    NSString* priceType = @"hourly";
    NSString* flatRateName = @"";
    if(self.timeTypeSelectFlatRateButton.selected) {
        dEndTime = dStartTime + [self.flatRateBar selectedDuration];
        dEndTime = MIN(dEndTime, [self.spot endTime]);
        priceType = @"flat_rate";
        flatRateName = [self.flatRateBar selectedFlatRateName];

    }

    [Api tryTransacation:self.spot withStartTime:dStartTime andEndTime:dEndTime withASIdelegate:self isPreview:TRUE withPriceType:priceType withFlatRateName:flatRateName withExtraParameter:@""];
    return;
   
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
    [self.spot updateAsynchronouslyWithLevelOfDetail:@"all"];
    //[[self getParkingSpots] updateWithRequest:[NSDictionary dictionaryWithObject:@"all" forKey:@"level_of_detail"]];
}


- (IBAction)closeButtonTapped:(id)sender {
    [[Mixpanel sharedInstance] track:@"dismissSpotVC"];
    [self dismissViewControllerAnimated:true completion:^{}];
}


#pragma  mark ASIHttp delegate

-(void)requestFailed:(ASIHTTPRequest *)request{
    if ( request.tag == kPreviewTransaction || request.tag == kAttempTransaction){
            
        
        [self.waitingMask removeFromSuperview];
        self.waitingMask = nil;
        //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSError *error = [request error];
        NSLog(@"Error: %@ Status code: %i Status Message: %@", error.localizedDescription, request.responseStatusCode, request.responseStatusMessage);
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
    }
}
-(void) requestFinished:(ASIHTTPRequest *)request{
    if ( request.tag == kPreviewTransaction){
        //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSString *responseString = [request responseString];
        NSDictionary * root = [responseString JSONValue];
        if([root objectForKey:@"success"]) {
            //Needs to happen on success
            
            [self.waitingMask removeFromSuperview];
            self.waitingMask = nil;
            [[Mixpanel sharedInstance] track:@"transactionpreviewsuccess" properties:root];
            
            UIAlertView* areYouSure = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
                                                                 message:[[root objectForKey:@"message"] objectForKey:@"price_string"]
                                                                delegate:self
                                                       cancelButtonTitle:@"Cancel"
                                                       otherButtonTitles:@"Yes", nil];
            [areYouSure show];
            
            //[self performSegueWithIdentifier:@"ViewConfirmation" sender:self];
            //NSLog(@"TEST");
        } else {
            [[Mixpanel sharedInstance] track:@"transactionpreviewfailure" properties:root];
            
            NSError* error = [ErrorTransformer apiErrorToNSError:[root objectForKey:@"error"]];
            [ErrorTransformer errorToAlert:error withDelegate:self];
            
            //self.errorLabel.text = [root objectForKey:@"error"];
            //self.errorLabel.hidden = false;
            [self.waitingMask removeFromSuperview];
            self.waitingMask = nil;
        }
        
        NSLog(@"Response: %@", responseString);
    }
    else if(request.tag == kAttempTransaction){
        //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSString *responseString = [request responseString];
        NSDictionary * root = [responseString JSONValue];
        if([[root objectForKey:@"success"] boolValue]) {
            [[Mixpanel sharedInstance] track:@"RealTransactionSuccess" properties:root];
            
            //Needs to happen on success
            NSString* paymentInfoDetails = [[root objectForKey:@"acceptance"] objectForKey:@"details"];
            [Persistance saveLastPaymentInfoDetails:paymentInfoDetails];
            
            [self switchToConfirmation:[root objectForKey:@"acceptance"]];
            
            //[self performSegueWithIdentifier:@"ViewConfirmation" sender:self];
            //NSLog(@"TEST");
        } else {
            [[Mixpanel sharedInstance] track:@"RealTransactionFailure" properties:root];
            NSError* error = [ErrorTransformer apiErrorToNSError:[root objectForKey:@"error"]];
            [ErrorTransformer errorToAlert:error withDelegate:self];
            
            [self.waitingMask removeFromSuperview];
            self.waitingMask = nil;
        }
        
        NSLog(@"Response: %@", responseString);

    }
}
- (IBAction)timeTypeSelectButtonTapped:(UIButton *)sender {
    
    if(sender.tag == 1) {
        [self.timeTypeSelectHourlyButton setSelected:true];
        [self.timeTypeSelectFlatRateButton setSelected:false];
        [self timeIntervalChanged];
    } else if (sender.tag == 2) {
        [self.timeTypeSelectHourlyButton setSelected:false];
        [self.timeTypeSelectFlatRateButton setSelected:true];
        [self timeIntervalChanged];
    } else {
        return;
    }
    
}
@end