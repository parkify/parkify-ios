//
//  mapDirectionsViewController.m
//  Parkify
//
//  Created by gnamit on 11/12/12.
//
//

#import "ParkifyAppDelegate.h"
#import "mapDirectionsViewController.h"
#import "MyWebView.h"
#import "WaitingMask.h"
#import "UIDevice+IdentifierAddition.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import "DirectionsScrollView.h"
#import "problemSpotViewController.h"
#import "troubleFindingSpotViewController.h"
#import "ExtraTypes.h"
#import "Api.h"
#import "extendReservationViewController.h"
#import "SBJson.h"
#import <AudioToolbox/AudioServices.h>

@interface mapDirectionsViewController ()
{
    
}
@property (nonatomic, strong) WaitingMask* waitingMask;

@property (weak, nonatomic) IBOutlet UIView *pageContainer;
@property (strong, nonatomic) DirectionsScrollView* directionsScrollView;

@property (nonatomic, strong) UIViewController *detailVC;

@property (weak, nonatomic) IBOutlet UIView *closeIndicator;

@property (weak, nonatomic) IBOutlet UIView *topBarView;
@property (weak, nonatomic) IBOutlet UILabel *topViewLabel;
@property (weak, nonatomic) IBOutlet UIButton *topViewButton;
@property CLLocationCoordinate2D location;
@property BOOL closeEnough;

- (IBAction)extendReservation:(id)sender;
- (IBAction)topBarButtonTapped:(id)sender;


@end

@implementation mapDirectionsViewController

@synthesize detailVC = _detailVC;
@synthesize location = _location; 
@synthesize directionsScrollView = _directionsScrollView;
@synthesize pageContainer = _pageContainer;
@synthesize waitingMask = _waitingMask;
@synthesize showTopBar = _showTopBar;
@synthesize closeEnough = _closeEnough;
CLLocationManager *_locationManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.showTopBar = false;
    }
    return self;
}
-(void)switchDirs{
    textDirs= !textDirs;

    if(textDirs){
        [currWebView stringByEvaluatingJavaScriptFromString:@"showText()"];
    }
    else{
        [currWebView stringByEvaluatingJavaScriptFromString:@"showMap()"];

    }
    NSString *buttontext = @"Map";
    if(!textDirs){
        buttontext=@"Text";
    }
   /* CGRect waitingMaskFrame = self.view.frame;
    waitingMaskFrame.origin.x = 0;
    waitingMaskFrame.origin.y = 0;
    
    self.waitingMask = [[WaitingMask alloc] initWithFrame:waitingMaskFrame];
    [self.view addSubview:self.waitingMask];
*/
    UIBarButtonItem *switchToText = [[UIBarButtonItem alloc] initWithTitle:buttontext style:UIBarButtonItemStyleBordered target:self action:@selector(switchDirs)];
    [self.navigationItem setRightBarButtonItem:switchToText];
    
    

}

/*
NSString* encodeToPercentEscapeString(NSString *string) {
    return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                         
                                                                         (__bridge CFStringRef) string,
                                                                         
                                                                         NULL,
                                                                         
                                                                         (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                                                         
                                                                         kCFStringEncodingUTF8) ;
}
 */

- (IBAction)backButtonTapped:(id)sender {
    [[Mixpanel sharedInstance] track:@"dismissDirectionsVC"];
    
    [self dismissViewControllerAnimated:true completion:^{}];
}
 
-(void)showCloseView{
    if([self.flowTabBar selectedItem].tag == 0) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        self.closeIndicator.alpha = 1;
    }
    //[self flashCloseIndicator];
    
    /*
    UIAlertView *closeDirections = [[UIAlertView alloc] initWithTitle:@"Nearby" message:@"You are near your spot. Click back to look at the detailed instructions if you need" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [closeDirections show];
     */
}
- (CLRegion*)mapDictionaryToRegion:(NSDictionary*)dictionary {
    NSString *title = [dictionary valueForKey:@"title"];
    
    CLLocationDegrees latitude = [[dictionary valueForKey:@"latitude"] doubleValue];
    CLLocationDegrees longitude =[[dictionary valueForKey:@"longitude"] doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    CLLocationDistance regionRadius = [[dictionary valueForKey:@"radius"] doubleValue];
    
    return [[CLRegion alloc] initCircularRegionWithCenter:centerCoordinate
                                                   radius:regionRadius
                                               identifier:title];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"Entered Region - %@", region.identifier);
    [[Mixpanel sharedInstance] track:@"GeofencingFiredForRegion" properties:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:self.spot.mID] forKey:@"spotid"]];
    self.closeEnough = true;
    [self showCloseView];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"Exited Region - %@", region.identifier);
    self.closeEnough = false;
    self.closeIndicator.alpha = 0;
}


- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"Started monitoring %@ region", region.identifier);
}
-(void)viewWillAppear:(BOOL)animated    {
    [[ UIApplication sharedApplication ] setIdleTimerDisabled: YES ];
    ParkifyAppDelegate *delegate = (ParkifyAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    delegate.currentLat = 37.872679;
    delegate.currentLong = -122.266797;
    
    delegate.locationManager.delegate = self;
    delegate.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [delegate.locationManager startUpdatingLocation];
}
-(void)viewWillDisappear:(BOOL)animated{
    [[ UIApplication sharedApplication ] setIdleTimerDisabled: YES ];
    for (CLRegion *region in [_locationManager.monitoredRegions allObjects])
    {
        [_locationManager stopMonitoringForRegion:region];
    }
    [_locationManager stopMonitoringSignificantLocationChanges];
    _locationManager.delegate=nil;
    
    ParkifyAppDelegate *delegate = (ParkifyAppDelegate*)[[UIApplication sharedApplication] delegate];
    delegate.locationManager.delegate = nil;
    [delegate.locationManager stopUpdatingLocation];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect waitingMaskFrame = self.view.frame;
    waitingMaskFrame.origin.x = 0;
    waitingMaskFrame.origin.y = 0;
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    
    self.directionsScrollView = [[DirectionsScrollView alloc] initWithFrame:CGRectMake(0,0,self.pageContainer.frame.size.width,self.pageContainer.frame.size.height) withSpot:self.spot withReservation:self.reservation];
    
    [self.pageContainer addSubview:self.directionsScrollView];
    [self.directionsScrollView setPageGroup:0];
    [self.directionsScrollView addTarget:self action:@selector(extendReservation) forControlEvents: ExtendReservationRequestedActionEvent];

    
    UIBarButtonItem *closeDirections = [[UIBarButtonItem alloc] initWithTitle:@"Trouble?" style:UIBarButtonItemStyleBordered target:self action:@selector(launchTroubleAlert:)];
    [self.navigationItem setRightBarButtonItem:closeDirections];
    
    UIBarButtonItem *backToSpots = [[UIBarButtonItem alloc] initWithTitle:@"Parking Map" style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonTapped:)];
    [self.navigationItem setLeftBarButtonItem:backToSpots];

        
    [self.flowTabBar setDelegate:self];
    
    for (UITabBarItem* item in self.flowTabBar.items) {
        if(item.tag == 0) {
            [self.flowTabBar setSelectedItem:item];
        }
    }
    
    
    if (_locationManager == nil) {
        NSLog(@"Location Manager Not Initialized");
    }
    
    else if(![CLLocationManager regionMonitoringAvailable]) {
        NSLog(@"This app requires region monitoring features which are unavailable on this device.");
        
    }
    else{
    
        self.location = CLLocationCoordinate2DMake(self.spot.mLat, self.spot.mLong);
        [self parseDirections];
        
        
        NSString *title = [NSString stringWithFormat:@"Spot %i", self.spot.mID ];

    CLLocationCoordinate2D centerCoordinate = self.location;
    
    CLLocationDistance regionRadius = 100.0f;
    
    CLRegion *geofence= [[CLRegion alloc] initCircularRegionWithCenter:centerCoordinate
                                                   radius:regionRadius
                                               identifier:title];

        [_locationManager startMonitoringForRegion:geofence desiredAccuracy:kCLLocationAccuracyHundredMeters];
        
    }
    
    
    if(self.showTopBar) {
        [self prepTopBar];
    } else {
        [self.topBarView setHidden:true];
    }
    
	// Do any additional setup after loading the view.
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)req navigationType:(UIWebViewNavigationType)navigationType {
    
    
    
    NSMutableURLRequest *request = (NSMutableURLRequest *)req;
    
    if ([request respondsToSelector:@selector(setValue:forHTTPHeaderField:)]) {
        
        //update User-Agent according to ScoutForApps spec
        
        [request setValue:[NSString stringWithFormat:@"%@ TNS4A/1.0", [request valueForHTTPHeaderField:@"User-Agent"]] forHTTPHeaderField:@"User-Agent"];
        
        
        
        //if you have a user id or device id in your app
        
       // [request setValue:[[UIDevice currentDevice] uniqueGlobalDeviceIdentifier] forHTTPHeaderField:@"T-S4AID"];
        
    }
    
    return YES; 
    
}

-(void)getCenterCoord:(NSNumber *)ider{
    NSString *boolVals = @"0";
    if (textDirs)
        boolVals=@"1";
}
-(void)finishedLoading{
    if(self.waitingMask) {
        [self.waitingMask removeFromSuperview];
        self.waitingMask = nil;
    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    [self.directionsScrollView setPageGroup:item.tag];
    
    switch (item.tag) {
        case 0:
            ;
            break;
        case 1:
            self.closeIndicator.alpha = 0;
            break;
        case 2:
            self.closeIndicator.alpha = 0;
            break;
        default:
            break;
    }
    
}

#pragma mark Gaurav code for trouble
-(void)launchProblemSpotVC:(BOOL)isLicensePlateView{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                             bundle: nil];
    
    problemSpotViewController *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"ProblemSpotVC"];
    self.detailVC=controller;
    controller.theSpot = self.spot;
    (( problemSpotViewController*)self.detailVC).transactionInfo = self.reservation;
    
    ((problemSpotViewController*)(self.detailVC)).isLicensePlateProblem=isLicensePlateView;
    [self.navigationController pushViewController:self.detailVC animated:YES];
    
}
-(void)launchtroubleFindingVC{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                             bundle: nil];
    
    self.detailVC = [mainStoryboard instantiateViewControllerWithIdentifier: @"troubleFindingVC"];
    ((troubleFindingSpotViewController*)self.detailVC).theSpot=self.spot;
    ((troubleFindingSpotViewController*)self.detailVC).transactionInfo=self.reservation;
    
    [self.navigationController pushViewController:self.detailVC animated:YES];
    
}
#pragma mark alert view delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kProblemAlertView && buttonIndex != alertView.cancelButtonIndex){
        if (buttonIndex == 1)
            [self launchProblemSpotVC:TRUE];
        else if(buttonIndex==2){
            [self launchProblemSpotVC:FALSE];
            
            NSLog(@"Launch without the license plate stuff");
        }
        else{
            [self launchtroubleFindingVC];
            NSLog(@"Launch directions");
        }
    }
}
- (IBAction)launchTroubleAlert:(id)sender {
    UIAlertView *problemWithSpot = [[UIAlertView alloc] initWithTitle:@"Uh-oh" message:@"Please let us know what problem you are having we'll be happy to give you a refund." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Somebody is in my spot",@"The spot is unusable", @"I cannot find my spot!", nil];
    [problemWithSpot show];
    problemWithSpot.tag = kProblemAlertView;
    
}

#pragma mark top bar

-(void) prepTopBar {
    if(self.reservation) {
        self.topViewLabel.text = self.reservation.lastPaymentInfo ;
    } else {
        self.topViewLabel.text = @"";
    }
    
    [self.topViewButton setUserInteractionEnabled:true];
   
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.topBarView setAlpha:0.77];
    } completion:^(BOOL finished) {
        [NSTimer scheduledTimerWithTimeInterval: 8
                                         target: self
                                       selector:@selector(hideTopBar)
                                       userInfo: nil repeats:NO];
    }];
}

-(void) hideTopBar {
    [self.topViewButton setUserInteractionEnabled:false];
    if(self.showTopBar) {
        self.showTopBar = false;
        [self.topBarView.layer removeAllAnimations];
    
        [UIView animateWithDuration:0.2 delay:0 options: UIViewAnimationOptionCurveEaseOut animations:^{
            [self.topBarView setAlpha:self.topBarView.alpha+0.20];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1.0 delay:0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                [self.topBarView setAlpha:0.0];
            
            } completion:^(BOOL finished) {
                [self.topBarView setHidden:true];
            }];
        }];
    }
}

- (IBAction)topBarButtonTapped:(id)sender {
    [self hideTopBar];
}

#pragma mark extend reservation
- (void)extendReservation {
    
    [[Mixpanel sharedInstance] track:@"launchExtendReservationVC"];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                             bundle: nil];
    
    extendReservationViewController *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"extendResVC"];
    controller.transactioninfo= self.reservation;
    controller.spot = self.spot;
    [self.navigationController pushViewController:controller animated:YES];
    
}





- (void)viewDidUnload {
    [self setFlowTabBar:nil];
    [self setPageContainer:nil];
    [self setTopViewButton:nil];
    [self setCloseIndicator:nil];
    [super viewDidUnload];
}

- (BOOL)parseDirections {
    NSDictionary* directions = [self.spot.mDirections JSONValue];
    
    NSArray* sources = [directions objectForKey:@"sources"];
    if(!sources || [sources count] <= 0) {
        return false;
    }
    NSArray* source = [sources objectAtIndex:0];
    
    
    if(!source) {
        return false;
    }
    
    NSDictionary* dirNode = [source objectAtIndex:0];
    if(!dirNode) {
        return false;
    }
    
    
    NSDictionary* location = [dirNode objectForKey:@"location"];
    if(location) {
        NSNumber* latitude = [location objectForKey:@"lat"];
        NSNumber* longitude = [location objectForKey:@"long"];
        if (latitude != NULL && longitude != NULL) {
            self.location = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
        } else {
            return false;
        }
    } else {
        return false;
    }
    
    return true;
}

/*
-(CLLocation*) locFromCoord:(CLLocationCoordinate2D)coord {
    return [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
}
-(BOOL) closeEnough {
    ParkifyAppDelegate *delegate = (ParkifyAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
    return ( [[self locFromCoord:self.location] distanceFromLocation:[self locFromCoord:CLLocationCoordinate2DMake(delegate.currentLat, delegate.currentLong)]] < 100);
}
*/

- (void)flashCloseIndicator {
    /*
    if( self.closeEnough && [self.flowTabBar selectedItem].tag == 0) {
        self.closeIndicator.alpha = 1;
        [self.closeIndicator.layer setAnchorPoint:CGPointMake(0.5,0)];
        [UIView animateWithDuration:0.5 animations:^{
            self.closeIndicator.transform = CGAffineTransformMakeScale(1.5, 1.5);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:(0.5) animations:^{
                self.closeIndicator.transform = CGAffineTransformMakeScale(1/1.5, 1/1.5);
            } completion:^(BOOL finished) {
                [self flashCloseIndicator];
            }];
        }];
    } else {
        self.closeIndicator.alpha = 0;
    }
     */
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    //self.myLocationButton.enabled = true;
    ParkifyAppDelegate *delegate = (ParkifyAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    delegate.currentLat = newLocation.coordinate.latitude;
    delegate.currentLong = newLocation.coordinate.longitude;
    
    [self.directionsScrollView locationManager:manager didUpdateToLocation:newLocation fromLocation:oldLocation];
    
    //NSLog(@"New latitude: %f", newLocation.coordinate.latitude);
    //NSLog(@"New longitude: %f", newLocation.coordinate.longitude);
}

@end
