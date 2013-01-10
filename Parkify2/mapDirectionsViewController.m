//
//  mapDirectionsViewController.m
//  Parkify
//
//  Created by gnamit on 11/12/12.
//
//

#import "mapDirectionsViewController.h"
#import "MyWebView.h"
#import "WaitingMask.h"
#import "UIDevice+IdentifierAddition.h"
#import <CoreLocation/CoreLocation.h>

@interface mapDirectionsViewController ()
{
    
}
@property (nonatomic, strong) WaitingMask* waitingMask;

@end

@implementation mapDirectionsViewController
@synthesize currLat;
@synthesize currLong;
@synthesize spotLat;
@synthesize spotLong;
@synthesize spotId=_spotId;

@synthesize waitingMask = _waitingMask;
CLLocationManager *_locationManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
NSString* encodeToPercentEscapeString(NSString *string) {
    return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                         
                                                                         (__bridge CFStringRef) string,
                                                                         
                                                                         NULL,
                                                                         
                                                                         (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                                                         
                                                                         kCFStringEncodingUTF8) ;
}
-(void)showCloseView{
    UIAlertView *closeDirections = [[UIAlertView alloc] initWithTitle:@"Nearby" message:@"You are near your spot. Click back to look at the detailed instructions if you need" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [closeDirections show];
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
    [[Mixpanel sharedInstance] track:@"GeofencingFiredForRegion" properties:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:self.spotId] forKey:@"spotid"]];

    [self showCloseView];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"Exited Region - %@", region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"Started monitoring %@ region", region.identifier);
}
-(void)viewWillAppear:(BOOL)animated    {
    [[ UIApplication sharedApplication ] setIdleTimerDisabled: YES ];
}
-(void)viewWillDisappear:(BOOL)animated{
    [[ UIApplication sharedApplication ] setIdleTimerDisabled: YES ];
    for (CLRegion *region in [_locationManager.monitoredRegions allObjects])
    {
        [_locationManager stopMonitoringForRegion:region];
    }
    [_locationManager stopMonitoringSignificantLocationChanges];
    _locationManager.delegate=nil;
    
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

    /*
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    [titleView setFont:[UIFont fontWithName:@"Helvetica Light" size:36.0f]];
    [titleView setTextColor:[UIColor colorWithRed:197.0f/255.0f green:211.0f/255.0f blue:247.0f/255.0f alpha:1.0f]];
    [titleView setText:@"Directions"];
    [titleView sizeToFit];
    [titleView setBackgroundColor:[UIColor clearColor]];
    [self.navigationItem setTitleView:titleView];
     */
   /* currWebView = [[MyWebView alloc] initWithFrame:self.view.frame];
    currWebView.customdelegate=self;
    [self.view addSubview:currWebView];
    self.waitingMask = [[WaitingMask alloc] initWithFrame:waitingMaskFrame];
    [self.view addSubview:self.waitingMask];

    textDirs=FALSE;
    UIBarButtonItem *switchToText = [[UIBarButtonItem alloc] initWithTitle:@"Text" style:UIBarButtonItemStyleBordered target:self action:@selector(switchDirs)];
    [self.navigationItem setRightBarButtonItem:switchToText];
    */
    UIBarButtonItem *closeDirections = [[UIBarButtonItem alloc] initWithTitle:@"Nearby" style:UIBarButtonItemStyleBordered target:self action:@selector(showCloseView)];
    [self.navigationItem setRightBarButtonItem:closeDirections];

    NSString *destination =[NSString stringWithFormat:@"%f, %f", self.spotLat, self.spotLong];//@"950 De Guigne Dr, Sunnyvale, CA 94085@37.386888,-122.004564";
    
    //address without latlon
    
    

    NSString *title = @"Telenav HQ";
    
    NSString *token = @"fFWUlXmSdqNcCE2MBsexfEpB3hBl3Tv8n9ZmFpDWev1etAqujpLgIYfyhm5HK_ijJDQ2Qq2Z6F8V50HM_d1axaaMCIw6mm012fhCME9i5S0QJ64t_MF4Vq1itm6vVR7O5cV9FyvahgzF8EZc_2pA8qOGkBuf0K4GKZHQwR8UZm0";
    
    
    
    //make sure all parameters are URL encoded
    
    NSString *escapedUrlDestination = encodeToPercentEscapeString(destination);
    
    NSString *escapedUrlTitle = encodeToPercentEscapeString(title);
    
    NSString *escapedUrlToken = encodeToPercentEscapeString(token);
    
    
    
    NSString *endpoint = [NSString stringWithFormat: @"http://apps.scout.me/v1/driveto?dt=%@&title=%@&token=%@&name=Parkify", escapedUrlDestination, escapedUrlTitle, escapedUrlToken];
    [[Mixpanel sharedInstance] track:@"loadingDirections" properties:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:destination,endpoint,[NSNumber numberWithInt:self.spotId], nil] forKeys:[NSArray arrayWithObjects:@"destination",@"url",@"spotid", nil]]];

    currWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-40)];
    currWebView.delegate = self;
    currWebView.scalesPageToFit = YES;

    [self.view addSubview:currWebView];
//    NSLog(@"The url is %@", endpoint);
    
    [currWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:endpoint]]];
    if (_locationManager == nil) {
        NSLog(@"Location Manager Not Initialized");
    }
    
    else if(![CLLocationManager regionMonitoringAvailable]) {
        NSLog(@"This app requires region monitoring features which are unavailable on this device.");
        
    }
    else{
    
        CLLocationDegrees curlatitude =spotLat;
        CLLocationDegrees curlongitude =spotLong;
        NSString *title = [NSString stringWithFormat:@"Spot %i", self.spotId ];

    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(curlatitude, curlongitude);
    
    CLLocationDistance regionRadius = 100.0f;
    
    CLRegion *geofence= [[CLRegion alloc] initCircularRegionWithCenter:centerCoordinate
                                                   radius:regionRadius
                                               identifier:title];

        [_locationManager startMonitoringForRegion:geofence desiredAccuracy:kCLLocationAccuracyHundredMeters];
        
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
  //  [currWebView returnResult:[ider intValue] args:[NSNumber numberWithDouble:currLat], [NSNumber numberWithDouble:currLong], [NSNumber numberWithDouble:spotLat], [NSNumber numberWithDouble:spotLong], boolVals, nil];
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

@end
