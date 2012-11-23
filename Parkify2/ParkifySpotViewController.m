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
  /*  self.rangeBar = [[RangeBar alloc] initWithFrame:[self.rangeBarContainer bounds] minVal:prevHourMark maxVal:maxVal minRange:30*60 displayedRange:numHours*60*60 selectedMinVal:currentTime selectedMaxVal:currentTime + 1800 withTimeFormatter:timeFormatter withPriceFormatter:^NSString *(double val) {
        if(fmod(val,1.0) >= 0.01) {
            return [NSString stringWithFormat:@"$%0.2f", val];
        } else {
            return [NSString stringWithFormat:@"$%0.0f", val];
        }
    } withPriceSource:self.spot];
*/
    self.rangeBar = [[RangeBar alloc] initWithFrame:[self.rangeBarContainer bounds] minVal:prevHourMark minimumSelectableValue:prevHourMark maxVal:maxVal minRange:30*60 displayedRange:numHours*60*60 selectedMinVal:currentTime selectedMaxVal:currentTime + 1800 withTimeFormatter:timeFormatter withPriceFormatter:^NSString *(double val) {
        if(fmod(val,1.0) >= 0.01) {
            return [NSString stringWithFormat:@"$%0.2f", val];
        } else {
            return [NSString stringWithFormat:@"$%0.0f", val];
        }
    } withPriceSource:self.spot];
    
    
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
    /*
    NSString* styleString = @"<style type=\"text/css\">"
    //"body { background-color:transparent; font-family:Marker Felt; font-size:12; color:white}"
    ".top { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:14; color:black}"
    ".top-mid { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:10; color:#224455;}"
    ".mid { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:10; color:#556677;}"
    ".bottom { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:16; color:black; }"
    ".selected { color:#224455; } "
    ".faded { color:#99AABB; }"
    ".fake-space {font-size:5;}"
    "</style>";
     */
    NSString* styleString = @"<style type=\"text/css\">"
    //"body { background-color:transparent; font-family:Marker Felt; font-size:12; color:white}"
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

        
        /*[NSString stringWithFormat:@"<html>%@<body>"
         "<span class=l1>Distance away</span></br>"
         "<span class=l2>%@</span></br>"
         "<span class=l3>%@</span></br>"
         "<span class=fake-space></br></span>"
         "<span class=fake-space></br></span>"
         "<span class=l4>PARALLEL: %@</span></br>"
         "<span class=l4>COVERED: %@</span></br>"
         "<span class=fake-space></br></span>"
         "<span class=bottom>Current Rate: $%0.2f/hr</span><hr/>"
         "<span class=top>%@</span><hr/></p>"
         "</body></html>",
         styleString,
         self.distanceString,
         self.spot.mAddress,
         layoutString,
         coverageString,
         [self.spot currentPrice],
         self.spot.mDesc];*/
        
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
 //   self.infoScrollView.contentSize = frame.size;
        
}

-(void)updateInfo {
    //Info box
    NSString* infoTitle;
    NSString* infoBody;
    NSString* timeString;
    NSString* priceString;
    NSString* timeDurationString;
    NSString* startTime;
    NSString* endTime;
    NSString* startTimeA;
    NSString* endTimeA;
    
    
    if(self.spot == nil) {
        infoTitle = @"Spot not found";
        infoBody = @"";
        timeString = @"";
        priceString = @"";
        timeDurationString = @"";
        startTime = @"";
        endTime = @"";
    }
    else {
        infoTitle = [NSString stringWithFormat:@"Parkify Spot"];
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

    
        
        startTime = formatterMain(self.rangeBar.selectedMinimumValue);
        startTimeA = formatterA(self.rangeBar.selectedMinimumValue);
        endTime = formatterMain(self.rangeBar.selectedMaximumValue);
        endTimeA = formatterA(self.rangeBar.selectedMaximumValue);
        
        //Price text
        double durationInSeconds = (self.rangeBar.selectedMaximumValue - self.rangeBar.selectedMinimumValue);
        ParkingSpot* spot = self.spot;
        double totalPrice = [spot priceFromNowForDurationInSeconds:durationInSeconds];
        
        priceString = [NSString stringWithFormat:@"$%0.2f", totalPrice];
        
        //TimeDuration text
        double hoursAndMinutes = round(durationInSeconds/60)/60;
        int hours = floor(hoursAndMinutes);
        int minutes = floor((hoursAndMinutes-hours)*60);

        
        timeDurationString = [NSString stringWithFormat:@"%dh%@%d", hours, (minutes<=9) ? @"0" : @"", minutes ];
        
    }
    
    CGAffineTransform squish = [TextFormatter transformForSpotViewText];
    //self.taxLabel.transform = squish;
    self.titleLable.text = infoTitle;
    [self setTitle:infoTitle];
   // self.timeLabel.text = timeString;
    //self.timeLabel.transform = squish;
    self.priceLabel.text = priceString;
    //self.priceLabel.transform = squish;
    self.timeDurationLabel.text = timeDurationString;
    self.startTimeLabel.text = [NSString stringWithFormat:@"%@%@",startTime,startTimeA];
    self.endTimeALabel.text = endTimeA;
    self.endTimeLabel.text = endTime;
    
    CGRect frame = self.endTimeALabel.frame;
    CGSize size = [endTime sizeWithFont:self.endTimeLabel.font];
    frame.origin.x = self.endTimeLabel.frame.origin.x + size.width + 1;
    self.endTimeALabel.frame = frame;
}
- (IBAction)parkButtonTapped:(UIButton *)sender {
    BOOL notransactiondebug = false;
    if (notransactiondebug) {
        [self switchToConfirmation:@"DYLAN WHAT?"];
        return;
    }
    if ([Persistance retrieveAuthToken] == nil) {
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

- (void) switchToConfirmation:(NSString*)paymentDetails {
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
        NSMutableDictionary *thetransaction = [Persistance addNewTransaction:self.spot withStartTime:self.rangeBar. selectedMinimumValue andEndTime:self.rangeBar.selectedMaximumValue andLastPaymentDetails:paymentDetails];
        NSDictionary *tester = [Persistance retrieveTransactions];
        NSLog(@"Are they stored? \n%@", tester);
       /* [Persistance saveCurrentSpotId:self.spot.mID];
        controller.startTime = self.rangeBar. selectedMinimumValue;
        [Persistance saveCurrentStartTime:controller.startTime];
        controller.endTime = self.rangeBar.selectedMaximumValue;
        [Persistance saveCurrentEndTime:controller.endTime];
        */
        controller.currentLat = self.currentLat;
        controller.currentLong = self.currentLong;
        controller.transactionInfo = thetransaction;
        controller.topBarText = paymentDetails;
        
        [Persistance saveCurrentSpot:self.spot];
        
        parent.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [parent presentViewController:navController animated:true completion:^{}];
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
#ifdef DEBUGVER
    NSString *sslorno = @"http";
    
#else
    NSString *sslorno = @"https";
    
#endif

    NSString* urlString = [[NSString alloc] initWithFormat:@"%@://%@/api/v1/acceptances.json?auth_token=%@",sslorno, TARGET_SERVER, [Persistance retrieveAuthToken]];
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
        if([[root objectForKey:@"success"] boolValue]) {
            //Needs to happen on success
            NSString* paymentInfoDetails = [[root objectForKey:@"acceptance"] objectForKey:@"details"];
            [Persistance saveLastPaymentInfoDetails:paymentInfoDetails];
            
            [self switchToConfirmation:paymentInfoDetails];
            
            //[self performSegueWithIdentifier:@"ViewConfirmation" sender:self];
            //NSLog(@"TEST");
        } else {
            NSError* error = [ErrorTransformer apiErrorToNSError:[root objectForKey:@"error"]];
            [ErrorTransformer errorToAlert:error withDelegate:self];
            
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



- (void) previewTransaction {
    
    NSMutableArray* offerIds = [[NSMutableArray alloc] init];
    for (Offer* offer in self.spot.offers) {
        if ([offer overlapsWithStartTime:self.rangeBar.selectedMinimumValue endTime:self.rangeBar.selectedMaximumValue])
            [offerIds addObject:[NSNumber numberWithInt:offer.mId]];
    }
    
    id transactionRequest = [Authentication makeTransactionRequestWithUserToken:[Persistance retrieveAuthToken] withSpotId:self.spot.mID withStartTime:self.rangeBar.selectedMinimumValue withEndTime:self.rangeBar.selectedMaximumValue withOfferIds:offerIds withLicensePlate:[Persistance retrieveLicensePlateNumber]];
    
#ifdef DEBUGVER
    NSString *sslorno = @"http";

#else
    NSString *sslorno = @"https";

#endif
    NSString* urlString = [[NSString alloc] initWithFormat:@"%@://%@/api/v1/acceptances/preview.json?auth_token=%@", sslorno, TARGET_SERVER, [Persistance retrieveAuthToken]];
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
            
            [self.waitingMask removeFromSuperview];
            self.waitingMask = nil;
            
            UIAlertView* areYouSure = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
                                                                 message:[[root objectForKey:@"message"] objectForKey:@"price_string"]
                                                                delegate:self
                                                       cancelButtonTitle:@"Cancel"
                                                       otherButtonTitles:@"Yes", nil];
            [areYouSure show];
            
            //[self performSegueWithIdentifier:@"ViewConfirmation" sender:self];
            //NSLog(@"TEST");
        } else {
            
            NSError* error = [ErrorTransformer apiErrorToNSError:[root objectForKey:@"error"]];
            [ErrorTransformer errorToAlert:error withDelegate:self];
            
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
    [self.spot updateAsynchronouslyWithLevelOfDetail:@"all"];
    //[[self getParkingSpots] updateWithRequest:[NSDictionary dictionaryWithObject:@"all" forKey:@"level_of_detail"]];
}


- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:true completion:^{}];
}




@end