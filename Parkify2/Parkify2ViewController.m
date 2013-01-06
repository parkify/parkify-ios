//
//  Parkify2ViewController.m
//  Parkify2
//
//  Created by Me on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Parkify2ViewController.h"
#import "ASIHTTPRequest.h"
#import "SBJSON.h"
#import "ParkingSpot.h"
#import "BSForwardGeocoder.h"
#import "ParkifySpotViewController.h"
#import <QuartzCore/QuartzCore.h> 
#import "Api.h"
#import "iToast.h"
#import "WaitingMask.h"
#import "TextFormatter.h"
#import "ParkingSpotCollection.h"
#import "ParkifyConfirmationViewController.h"
#import "Persistance.h"
#import "ParkifyAppDelegate.h"
#import "extendReservationViewController.h"

#define ORIG_ANNOTATION_WIDTH 54
#define ORIG_ANNOTATION_HEIGHT 89
#define ANNOTATION_WIDTH (ORIG_ANNOTATION_WIDTH*0.5)
#define ANNOTATION_HEIGHT (ORIG_ANNOTATION_HEIGHT*0.5)
#define INIT_VIEW_WIDTH_IN_MILES 1.0
#define ZOOM_LEVEL_STREET 13
#define ZOOM_MARGIN_FACTOR 1.8

typedef enum targetLocationType {
    TARGET_NONE = -1,
    TARGET_CURRENT_LOCATION = 0,
    TARGET_SEARCHED_LOCATION = 1,
}targetLocationType;

typedef struct STargetLocation {
    targetLocationType type;
    CLLocationCoordinate2D location;
} STargetLocation;



@interface Parkify2ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationButton;
@property (weak, nonatomic) IBOutlet UIView *bottomBarView;
@property (weak, nonatomic) IBOutlet UILabel *bottomBarLabel;

@property (nonatomic, strong) BSForwardGeocoder* forwardGeocoder;
@property targetLocationType targetType;
@property BOOL bAlreadyInit;
@property (nonatomic, strong) LocationAnnotation*  targetLocationAnnotation;
@property (nonatomic, strong) WaitingMask* waitingMask;
@property STargetLocation targetLocation;
@property CGRect addressBarOrigFrame;


@end

@implementation Parkify2ViewController

@synthesize settingsButton = _settingsButton;
@synthesize currentLocationButton = _currentLocationButton;
@synthesize bottomBarView = _bottomBarView;
@synthesize bottomBarLabel = _bottomBarLabel;

@synthesize confirmationButton = _confirmationButton;
@synthesize mapView = _mapView;
@synthesize timerPolling = _timerPolling;
@synthesize timerDuration = _timerDuration;
@synthesize locationManager = _locationManager;
@synthesize addressBar = _addressBar;
@synthesize myLocationButton = _myLocationButton;
@synthesize targetSpot = _targetSpot;
@synthesize lastSearchedLocation = _lastSearchedLocation;
@synthesize targetType = _targetType;
@synthesize bAlreadyInit = _bAlreadyInit;

@synthesize annotations = _annotations;

@synthesize forwardGeocoder = _forwardGeocoder;

@synthesize targetLocationAnnotation = _targetLocationAnnotation;

@synthesize targetLocation = _targetLocation;

@synthesize waitingMask = _waitingMask;

@synthesize addressBarOrigFrame = _addressBarOrigFrame;


/*
- (ParkingSpotCollection*)parkingSpots {
    if(!_parkingSpots) {
        _parkingSpots = [[ParkingSpotCollection alloc] init];
    }
    _parkingSpots.observerDelegate = self;
    return _parkingSpots;
}
*/

- (BSForwardGeocoder*)forwardGeocoder {
    if(_forwardGeocoder == nil) {
        _forwardGeocoder = [[BSForwardGeocoder alloc] initWithDelegate:self];
    }
    return _forwardGeocoder;
}

-(void) setTargetLocation:(STargetLocation)targetLocation {
    _targetLocation = targetLocation;
    if(targetLocation.type != TARGET_NONE) {
        self.targetLocationAnnotation.coordinate = targetLocation.location;
        [self showTargetPin:true];
    } else {
        [self showTargetPin:false];
    }
    [self updateBottomBar];
}

-(int)hasReservation {
    ParkifyAppDelegate *delegate = (ParkifyAppDelegate*)[[UIApplication sharedApplication] delegate];
    double currentTime = [[NSDate date] timeIntervalSince1970];
    int numOfRes=0;
    NSMutableDictionary *actives = [[delegate.transactions objectForKey:@"active"] copy];
    for (NSString *transactionkey in actives){
        NSMutableDictionary *transaction = [actives objectForKey:transactionkey];
        double startTime = [[transaction objectForKey:@"starttime"] doubleValue];
        double endTime =[[transaction objectForKey:@"endtime"] doubleValue];
        
        if ((currentTime >= startTime) && (currentTime <= endTime)){
            [transaction setValue:@"1" forKey:@"active"];
            numOfRes++;
        }
        else{
            [[delegate.transactions objectForKey:@"active"] removeObjectForKey:transactionkey];
            [transaction setValue:@"0" forKey:@"active"];
            
        }

    }
    return [actives count];
    /*
    double startTime = [Persistance retrieveCurrentStartTime];
    double endTime = [Persistance retrieveCurrentEndTime];
    
    double currentTime = [[NSDate date] timeIntervalSince1970];
    return (currentTime >= startTime) && (currentTime <= endTime);*/
}

-(void)updateBottomBar {
    int numRes = [self hasReservation];
    if(numRes!=0) {
        Formatter formatter = ^(double val) {
            NSDate* time = [[NSDate alloc] initWithTimeIntervalSince1970:val];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"h:mma"];
            return [dateFormatter stringFromDate:time]; };
        
        [UIView animateWithDuration:0.3 animations:^{
            self.bottomBarView.frame = self.bottomBarLargeReferenceView.frame;
            self.bottomBarView.backgroundColor = [UIColor colorWithRed:32/255.0 green:147/255.0 blue:255/255.0 alpha:1];
            self.bottomBarLabel.textColor = [UIColor colorWithWhite:0.95 alpha:1];
            self.myLocationButton.frame = self.locationButtonLargeReferenceView.frame;
        }];
        
        
        NSMutableDictionary *actives =  [[((ParkifyAppDelegate*)[[UIApplication sharedApplication] delegate]) transactions] objectForKey:@"active"];
        NSDictionary *transact = [actives objectForKey:[[actives allKeys] lastObject]];
        double endTime = [[transact objectForKey:@"endtime"] doubleValue];
        self.bottomBarLabel.text = [NSString stringWithFormat:@"   (%i)   Reservation ends at %@        Details ", numRes, formatter(endTime)];
        self.bottomBarLabel.textAlignment = UITextAlignmentRight;
        
        
        [self.confirmationButton setHidden:false];
        
    } else {
        self.bottomBarLabel.textAlignment = UITextAlignmentCenter;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.bottomBarView.frame = self.bottomBarSmallReferenceView.frame;
            self.bottomBarView.backgroundColor = [UIColor whiteColor];
            self.bottomBarLabel.textColor = [UIColor colorWithWhite:0.1 alpha:1];
            self.myLocationButton.frame = self.locationButtonSmallReferenceView.frame;
        }];
        
        [self.confirmationButton setHidden:true];
    if(self.targetLocation.type != TARGET_NONE) {
        double distanceToSpot = [[self getParkingSpots] distanceToClosestAvailableSpotToCoord:self.targetLocation.location];
        if(distanceToSpot <= 5) {
            self.bottomBarLabel.text = [NSString stringWithFormat:@"Closest spot is %@ away.", [TextFormatter formatDistanceClose:distanceToSpot]];
        } else {
            self.bottomBarLabel.text = @"No spots within 5 miles... Yet!";
        }
    } else {
        self.bottomBarLabel.text = @"";
    }
    }
}

-(STargetLocation)targetLocation {
    /*
    if(self.targetType == TARGET_CURRENT_LOCATION) {
        toRtn.latitude = self.currentLat;
        toRtn.longitude = self.currentLong;
    } else if (self.targetType == TARGET_SEARCHED_LOCATION) {
        toRtn = self.lastSearchedLocation;
    }
     */
    return _targetLocation;
}


- (void)setMapView:(MKMapView *)mapView {
    _mapView = mapView;
    [self updateMapView];
}

- (void)setAnnotations:(NSArray *)annotations {
    _annotations = annotations;
    [self updateMapView];
}

-(void)checkURL{
    ParkifyAppDelegate *delegate = (ParkifyAppDelegate*)[[UIApplication sharedApplication] delegate];
    if(delegate.openURL){
        NSString *command = [[delegate.openURL host] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString * q = [delegate.openURL query];
        NSArray * pairs = [q componentsSeparatedByString:@"&"];
        NSMutableDictionary * kvPairs = [NSMutableDictionary dictionary];
        for (NSString * pair in pairs) {
            NSArray * bits = [pair componentsSeparatedByString:@"="];
            NSString * key = [[bits objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            NSString * value = [[bits objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            [kvPairs setObject:value forKey:key];
        }
        

        if ([command isEqualToString:@"extend"]){
            
            
            NSString *key = [kvPairs objectForKey:@"spotid"];
            if(!key)
                return;
            if ( [[delegate.transactions objectForKey:@"active"] objectForKey:key])
                [self performSelectorOnMainThread:@selector(launchExtendReservation:) withObject:key waitUntilDone:NO];
            else if(   [[self getParkingSpots] parkingSpotForID:[key intValue]]){
                [self performSelectorOnMainThread:@selector(openSpotViewControllerWithSpot:) withObject:key waitUntilDone:NO];
            }

        }
    }

}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [self setAddressBar:nil];
    [self setMyLocationButton:nil];
    [self setCurrentLocationButton:nil];
    [self setSettingsButton:nil];
    [self setBottomBarLabel:nil];
    [self setBottomBarView:nil];
    [self setConfirmationButton:nil];
    [self setBottomBarSmallReferenceView:nil];
    [self setBottomBarLargeReferenceView:nil];
    [self setSearchButton:nil];
    [self setSearchBarLargeReferenceView:nil];
    [self setSearchBarSmallReferenceView:nil];
    [self setSearchBarContainer:nil];
    [self setBottomBarButton:nil];
    [self setLocationButtonLargeReferenceView:nil];
    [self setLocationButtonSmallReferenceView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
    /*
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
     */
}

- (void) viewWillDisappear:(BOOL)animated
{
    //[self.navigationController setNavigationBarHidden:NO animated:animated];
    [self stopPolling];
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkURL) name:@"launchURL" object:nil];
    
    [super viewWillAppear:animated];
    if(!self.bAlreadyInit) {
        //[PlacedAgent logPageView:@"MapView-Init"];
        //** Set up waitingMask **//
        CGRect waitingMaskFrame = self.view.frame;
        waitingMaskFrame.origin.x = 0;
        waitingMaskFrame.origin.y = 0;
        
        self.waitingMask = [[WaitingMask alloc] initWithFrame:waitingMaskFrame];
        [self.view addSubview:self.waitingMask];
        //**  **//
        ParkifyAppDelegate *delegate = (ParkifyAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        delegate.currentLat = 37.872679;
        delegate.currentLong = -122.266797;
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager startUpdatingLocation];
        self.mapView.delegate = self;
        
        STargetLocation initTarget;
        
        
        initTarget.type = TARGET_NONE;

        if(self.locationManager.location != nil) {

            delegate.currentLat = self.locationManager.location.coordinate.latitude;
            delegate.currentLong = self.locationManager.location.coordinate.longitude;
            initTarget.type = TARGET_CURRENT_LOCATION;
        }
        
        CLLocationCoordinate2D initCoord;
        initCoord.latitude = delegate.currentLat;
        initCoord.longitude = delegate.currentLong;
        
        self.targetLocationAnnotation = [[LocationAnnotation alloc] init];
        self.targetLocationAnnotation.coordinate = initCoord;
        
        initTarget.location = CLLocationCoordinate2DMake(delegate.currentLat, delegate.currentLong);
        self.targetLocation = initTarget;
        /*
        self.targetType = TARGET_SEARCHED_LOCATION;
        self.lastSearchedLocation = targetLocation;
        */
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(initCoord, INIT_VIEW_WIDTH_IN_MILES*METERS_PER_MILE, INIT_VIEW_WIDTH_IN_MILES*METERS_PER_MILE);
        MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
        [self.mapView setRegion:adjustedRegion animated:YES];
        
        
        self.addressBar.delegate = self;
    
        self.addressBar.showsSearchResultsButton = false;
        
        self.addressBarOrigFrame = self.addressBar.frame;
        
        [[UISearchBar appearance] setBackgroundImage:[UIImage imageNamed:@"clear.png"]];
        
        self.bAlreadyInit = true;
        
        
        
        //[self.mapView addAnnotation:self.targetLocationAnnotation];
        
        /*
        self.
        self.mapView.alpha = .5;
        */
        
        [self.mapView setNeedsDisplay];
        //[UIView animateWithDuration:5
          //               animations: ^{[self.mapView setAlpha:1];}
            //             completion: ^(BOOL finished){}];

        
    } else {
        //[PlacedAgent logPageView:@"MapView-Return"];
    }
   
    
    
    
    [self updateBottomBar];
    self.timerDuration = 10;
    [self refreshSpots];
    [self startPolling];
    
    if ([Persistance retrieveAuthToken]){
        [[Mixpanel sharedInstance] identify:[NSString stringWithFormat:@"%@_%@", [Persistance retrieveFirstName], [Persistance retrieveLastName]]];
        [[Mixpanel sharedInstance] registerSuperPropertiesOnce:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[Persistance retrieveUserID], [Persistance retrieveFirstName],[Persistance retrieveLastName], nil] forKeys:[NSArray arrayWithObjects:@"userid",@"firstname",@"lastname", nil]]];
        [[Mixpanel sharedInstance] track:@"loggedinafterloaded"];

    }
    
}


- (void)showTargetPin:(BOOL)bShow {
    if(bShow) {
        if (![self.mapView.annotations containsObject:self.targetLocationAnnotation])
        {
            [self.mapView addAnnotation:self.targetLocationAnnotation];
        }
    } else {
        if ([self.mapView.annotations containsObject:self.targetLocationAnnotation]) {
            [self.mapView removeAnnotation:self.targetLocationAnnotation];
        }
    }
    
}

- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation {
    
    //self.myLocationButton.enabled = true;
    ParkifyAppDelegate *delegate = (ParkifyAppDelegate*)[[UIApplication sharedApplication] delegate];

    delegate.currentLat = newLocation.coordinate.latitude;
    delegate.currentLong = newLocation.coordinate.longitude;
    
    if (self.targetLocation.type == TARGET_CURRENT_LOCATION) {
        STargetLocation target;
        target.type = TARGET_CURRENT_LOCATION;
        target.location = newLocation.coordinate;
        self.targetLocation = target;
    } else if (self.targetLocation.type == TARGET_NONE) {
        STargetLocation target;
        target.type = TARGET_CURRENT_LOCATION;
        target.location = newLocation.coordinate;
        self.targetLocation = target;
        [self goToCoord:target.location handleZoom:true viewNearestSpot:true];
    }
    
    [self updateBottomBar];
    
    //NSLog(@"New latitude: %f", newLocation.coordinate.latitude);
    //NSLog(@"New longitude: %f", newLocation.coordinate.longitude);
}

- (void)goToRegion:(MKCoordinateRegion)region {
    //int curZoom = [self.mapView zoomLevel];
    [self.mapView setRegion:region animated:TRUE];
    //[self.mapView setCenterCoordinate:target zoomLevel:curZoom animated:TRUE];
}

/*december*/
- (void)goToCoord:(CLLocationCoordinate2D)target handleZoom:(BOOL)bHandleZoom viewNearestSpot:(BOOL)bNearestSpot{
    [self.mapView selectAnnotation:nil animated:true];
    for (id selectedAnnotation in self.mapView.selectedAnnotations) {
        [self.mapView deselectAnnotation:selectedAnnotation animated:false];
    }
    
    ParkingSpot* closest = [[self getParkingSpots] closestAvailableSpotToCoord:target];
    double distanceToSpot = [[self getParkingSpots] distanceToClosestAvailableSpotToCoord:self.targetLocation.location];
    if(bNearestSpot && closest && (distanceToSpot <= 5)) {
        double minLat = MIN(target.latitude, closest.mLat);
        double minLong = MIN(target.longitude, closest.mLong);
        double maxLat = MAX(target.latitude, closest.mLat);
        double maxLong = MAX(target.longitude, closest.mLong);
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake((maxLat+minLat)/2.0, (maxLong+minLong)/2.0);
        
        MKCoordinateSpan span = MKCoordinateSpanMake(fabsf(maxLat-minLat)*ZOOM_MARGIN_FACTOR, fabsf(maxLong-minLong)*ZOOM_MARGIN_FACTOR);
        [self.mapView setRegion:MKCoordinateRegionMake(center, span) animated:true];
    }
    else {
        int zoomLevel = [self.mapView zoomLevel];
        if( bHandleZoom ) {
            zoomLevel = ZOOM_LEVEL_STREET;
        }
        [self.mapView setCenterCoordinate:target zoomLevel:zoomLevel animated:TRUE];
    }
    
}

- (IBAction)settingsButtonTapped:(UIButton *)sender {
    
    [Api settingsModallyFrom:self withSuccess:^(NSDictionary * results) {
        NSLog(@"%@", results);
    }];
}

- (IBAction)myLocationTapped:(id)sender {
    if(![CLLocationManager headingAvailable]) {
        //don't move!
        [[[iToast makeText:@"Can't find current location."] setGravity:iToastGravityBottom ] show];
        return;
    }
    
    
    
    //[self showTargetPin:false];
    
    CLLocationCoordinate2D myLocation;
    ParkifyAppDelegate *delegate = (ParkifyAppDelegate*)[[UIApplication sharedApplication] delegate];

    myLocation.latitude = delegate.currentLat;
    myLocation.longitude = delegate.currentLong;
    
    STargetLocation target;
    target.type = TARGET_CURRENT_LOCATION;
    target.location = myLocation;
    self.targetLocation = target;
    
    //self.targetType = TARGET_CURRENT_LOCATION;
    
    [self goToCoord:myLocation handleZoom:true viewNearestSpot:true];
}

- (void)expandAddressBar:(BOOL)bExpand {
    if(bExpand) {
        //CGRect newFrame = self
        //newFrame.size.width = self.view.frame.size.width;
        //newFrame.origin.x = 0;
        //newFrame.origin.y = self.addressBarOrigFrame.size.height;
        [UIView animateWithDuration:.2                                 animations: ^{
            self.searchBarContainer.frame = self.searchBarLargeReferenceView.frame;
            //self.addressBar.frame = newFrame;
            //[self.addressBar layoutSubviews];
                                 }
                                 completion: ^(BOOL finished){}];

    } else {
        [UIView animateWithDuration:.1
                         animations: ^{
                             self.searchBarContainer.frame = self.searchBarSmallReferenceView.frame;
                             //[self.addressBar layoutSubviews];
                         }
                         completion: ^(BOOL finished){
                         }
         ];
    }
}

- (IBAction)AddressEntered:(UITextField*)sender {
    NSLog(@"%@",sender.text);
    [self expandAddressBar:false];
    [sender resignFirstResponder];
}
#define MINIMUM_ZOOM_ARC 0.014 //approximately 1 miles (1 degree of arc ~= 69 miles)
#define ANNOTATION_REGION_PAD_FACTOR 1.15
#define MAX_DEGREES_ARC 360

- (void)zoomMapViewToFitAnnotations:(MKMapView *)mapView animated:(BOOL)animated
{
    NSArray *annotations = mapView.annotations;
    int count = [mapView.annotations count];
    if ( count == 0) { return; } //bail if no annotations
    //convert NSArray of id <MKAnnotation> into an MKCoordinateRegion that can be used to set the map size
    //can't use NSArray with MKMapPoint because MKMapPoint is not an id
    MKMapPoint points[count]; //C array of MKMapPoint struct
    for( int i=0; i<count; i++ ) //load points C array by converting coordinates to points
    {
        CLLocationCoordinate2D coordinate = [(id <MKAnnotation>)[annotations objectAtIndex:i] coordinate];
        points[i] = MKMapPointForCoordinate(coordinate);
    }
    //create MKMapRect from array of MKMapPoint
    MKMapRect mapRect = [[MKPolygon polygonWithPoints:points count:count] boundingMapRect];
    //convert MKCoordinateRegion from MKMapRect
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    //add padding so pins aren't scrunched on the edges
    region.span.latitudeDelta  *= ANNOTATION_REGION_PAD_FACTOR;
    region.span.longitudeDelta *= ANNOTATION_REGION_PAD_FACTOR;
    //but padding can't be bigger than the world
    if( region.span.latitudeDelta > MAX_DEGREES_ARC ) { region.span.latitudeDelta  = MAX_DEGREES_ARC; }
    if( region.span.longitudeDelta > MAX_DEGREES_ARC ){ region.span.longitudeDelta = MAX_DEGREES_ARC; }
    
    //and don't zoom in stupid-close on small samples
    if( region.span.latitudeDelta  < MINIMUM_ZOOM_ARC ) { region.span.latitudeDelta  = MINIMUM_ZOOM_ARC; }
    if( region.span.longitudeDelta < MINIMUM_ZOOM_ARC ) { region.span.longitudeDelta = MINIMUM_ZOOM_ARC; }
    //and if there is a sample of 1 we want the max zoom-in instead of max zoom-out
    if( count == 1 )
    {
        region.span.latitudeDelta = MINIMUM_ZOOM_ARC;
        region.span.longitudeDelta = MINIMUM_ZOOM_ARC;
    }
    [mapView setRegion:region animated:animated];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    
    static NSString *identifier; 
    
    
    if ([annotation isKindOfClass:[ParkingSpotAnnotation class]]) {
        
        ParkingSpot* spot = ((ParkingSpotAnnotation*)annotation).spot;
        
        
        if([spot.mSpotType isEqualToString: @"premium"])
        {
            identifier = @"premium";
        } else if ([spot.mSpotType isEqualToString: @"charging"]) {
            identifier = @"charging";
        } else {
            identifier = @"economy";
        }
        
        
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.canShowCallout = YES;
            annotationView.enabled = YES;
            //annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,30,30)];
        }
        
        annotationView.annotation = annotation;
        //[(UIImageView*)annotationView.leftCalloutAccessoryView setImage:nil];
        
        UIImage* img;
        if([spot.mSpotType isEqualToString: @"premium"])
        {
            img=[UIImage imageNamed:@"black_spot_marker_cool.png"];
        } else if ([spot.mSpotType isEqualToString: @"charging"]) {
            img=[UIImage imageNamed:@"black_spot_marker_cool.png"];
        } else {
            img=[UIImage imageNamed:@"black_spot_marker_cool.png"];
        }
        
        annotationView.image=img;
        
        CGRect frame = annotationView.frame;
        frame.size.width = ANNOTATION_WIDTH;
        frame.size.height = ANNOTATION_HEIGHT;
        annotationView.frame = frame;
        
        //annotationView.center = CGPointMake(frame.size.width/2, frame.size.height);
        
        
        //UIButton* btnViewVenue = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        UIButton* btnViewVenue = [UIButton buttonWithType:UIButtonTypeCustom];
        btnViewVenue.frame = CGRectMake(0, 0,74, 32);
        
        //NSString *btnString = @"PARK!";
        NSString *btnString = @"Info";
        CGSize s = [btnString sizeWithFont:[UIFont fontWithName:@"Arial Rounded MT Bold" size:(16.0)] constrainedToSize:btnViewVenue.frame.size lineBreakMode:UILineBreakModeMiddleTruncation];
        [btnViewVenue setBackgroundImage:[UIImage imageNamed:@"blue_button.png"]
                            forState:UIControlStateNormal];

        btnViewVenue.titleLabel.frame = CGRectMake(0,0,s.width,s.height);
        [btnViewVenue setTitle:btnString forState:UIControlStateNormal];
        
        btnViewVenue.titleLabel.textColor = [UIColor whiteColor];
        btnViewVenue.titleLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(16.0)];
        
        
        btnViewVenue.tag = spot.actualID;
        [btnViewVenue addTarget:self action:@selector(spotMoreInfo:) forControlEvents:UIControlEventTouchUpInside];
        annotationView.rightCalloutAccessoryView = btnViewVenue;
        
        annotationView.centerOffset = CGPointMake(0, -annotationView.frame.size.height/2);
        
        return annotationView;
    } else if ([annotation isKindOfClass:[LocationAnnotation class]]) {
        identifier = @"location";
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
        }
        annotationView.annotation = annotation;
        
        //We want default pin
        //annotationView.image=[UIImage imageNamed:@"location_icon.png"];
        
        /*
        CGRect frame = annotationView.frame;
        frame.size.width = ANNOTATION_WIDTH;
        frame.size.height = ANNOTATION_HEIGHT;
        annotationView.frame = frame;
        */
        
        return annotationView;
    }
    
    return nil;    
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    MKAnnotationView *aV;
    for (aV in views) {
        
        CGRect endFrame = aV.frame;
        
        aV.frame = CGRectMake(aV.frame.origin.x+aV.frame.size.width/2, aV.frame.origin.y+aV.frame.size.height, 1, 1);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.45];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
        [aV setFrame:endFrame];
        [UIView commitAnimations];
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ViewSpot"]) {
        
        double distanceToSpot = [[self getParkingSpots] distFromSpot:self.targetSpot toCoord:self.targetLocation.location];
        
        
        ParkifySpotViewController *newController = segue.destinationViewController;
        [self getParkingSpots].observerDelegate = nil;
        //newController.parkingSpots = self.parkingSpots;
        //self.parkingSpots.observerDelegate = newController;
        newController.spot = self.targetSpot;
        ParkifyAppDelegate *delegate = (ParkifyAppDelegate*)[[UIApplication sharedApplication] delegate];

        newController.currentLat = delegate.currentLat;
        newController.currentLong = delegate.currentLong;
        newController.distanceString = [TextFormatter formatDistanceClose:distanceToSpot];
        
        [newController.spot updateAsynchronouslyWithLevelOfDetail:@"all"];
        
        if(self.waitingMask) {
            [self.waitingMask removeFromSuperview];
            self.waitingMask = nil;
        }
    }
}





#pragma mark opening spot

- (void)openSpotViewControllerWithSpot:(NSString*)spotIDstr  {
    int spotID = [spotIDstr intValue];
    [self stopPolling];
    
    //** Set up waitingMask **//
    CGRect waitingMaskFrame = self.view.frame;
    waitingMaskFrame.origin.x = 0;
    waitingMaskFrame.origin.y = 0;
    
    self.waitingMask = [[WaitingMask alloc] initWithFrame:waitingMaskFrame];
    [self.view addSubview:self.waitingMask];
    //**  **//
        
    self.targetSpot = [[self getParkingSpots] parkingSpotForID:spotID];
    [[Mixpanel sharedInstance] track:@"SpotDetails" properties:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:spotID] forKey:@"spotid"]];
    [Crittercism leaveBreadcrumb:@"spotdetails"];
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self performSegueWithIdentifier:@"ViewSpot" sender:self];
}

- (IBAction)spotMoreInfo:(UIButton*)sender {
    [self openSpotViewControllerWithSpot:[NSString stringWithFormat:@"%i", sender.tag]];
}
//- calloutAccessoryControlTapped:


//TODO: Change "little_man.png" to be thumbnail of parking spot image
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    //UIImage* image = [UIImage imageNamed:@"little_man.png"];
    //[(UIImageView*)view.leftCalloutAccessoryView setImage:image];
}

//TODO: Change make this happen based on the max zoom level, not just a hard-coded value.
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    //Temporarily removed because messes with the annotation images.
    /*
    NSLog(@"%d",[self.mapView zoomLevel]);
    if([self.mapView zoomLevel]>17) {
        [self.mapView setMapType:MKMapTypeSatellite];
        //[mapView setCenterCoordinate:[mapView centerCoordinate] zoomLevel:10 animated:TRUE];
    }
    if([self.mapView zoomLevel]<=17) {
        [self.mapView setMapType:MKMapTypeStandard];
        //[mapView setCenterCoordinate:[mapView centerCoordinate] zoomLevel:10 animated:TRUE];
    }
     */
}


-(void)spotsWereUpdatedWithCount:(NSString *)count withLevelOfDetail:(NSString*)lod withSpot:(int)spotID
{
    [self updateBottomBar];
    if(self.waitingMask) {
        [self.waitingMask removeFromSuperview];
        self.waitingMask = nil;
        [self performSelectorInBackground:@selector(checkURL) withObject:nil];
        [Api getListOfCurrentAcceptances:[[UIApplication sharedApplication] delegate]];
    }

    NSDictionary *parkingspots = [[self getParkingSpots] parkingSpots];
    NSMutableArray *usedkeys = [[NSMutableArray alloc] init];
    for(ParkingSpotAnnotation* map_annotation in [self.mapView.annotations copy]) {
        if ([map_annotation class] != [ParkingSpotAnnotation class])
            continue;
        NSString *key = [NSString stringWithFormat:@"%i", map_annotation.spot.actualID];
        ParkingSpot* spot = [parkingspots objectForKey:key];
        if (!spot || !spot.mFree){
            [self.mapView removeAnnotation:map_annotation];
        }
        else {
            [usedkeys addObject:key];
        }
    }
    for (NSString *key in [parkingspots allKeys]){
        if (![usedkeys containsObject:key]){
            [self.mapView addAnnotation:[ParkingSpotAnnotation annotationForSpot:[parkingspots objectForKey:key]]];
        }
    }
    /*
    NSMutableArray* annotations = [[NSMutableArray alloc] init ];
    
    for (ParkingSpot* spot in [[self getParkingSpots].parkingSpots allValues]) {
        [annotations addObject:[ParkingSpotAnnotation annotationForSpot:spot]];
    }
    self.annotations = annotations;
    */
#if ADMIN_VER
        NSMutableArray* ids = [[NSMutableArray alloc] init ];
        for (ParkingSpot* spot in [[self getParkingSpots].parkingSpots allValues]) {
        
        [ids addObject:[NSNumber numberWithInt:(spot.mID)]];
        }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"intValue" ascending:TRUE];
    [ids sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
        NSString * toToast = @"";
        for (NSNumber * num in ids) {
            toToast = [toToast stringByAppendingString:[NSString stringWithFormat:@"%d,",[num intValue]]];
        }
    
        [[[iToast makeText:toToast] setGravity:iToastGravityBottom ] show];

#endif

    
}

- (void)updateMapView {
    //Terrible, must be some better way to update.
    
    if(self.waitingMask) {
        [self.waitingMask removeFromSuperview];
        self.waitingMask = nil;
        [self performSelectorInBackground:@selector(checkURL) withObject:nil];
    }
    
    BOOL bChanged = false;
 /*   NSMutableArray* annotationsToRemove = [[NSMutableArray alloc] init];
    NSMutableArray* annotationsAdded = [[NSMutableArray alloc] init];
    
    //NSLog(@"Before_m=%d, Before_map=%d\t", [self.annotations count],[self.mapView.annotations count] );
    for(ParkingSpotAnnotation* map_annotation in self.mapView.annotations) {
        bChanged = false;
        if([map_annotation respondsToSelector:@selector(updateAnnotationWith:onlyifIDsAreSame:)]) {
            for(id m_annotation in self.annotations) {
                bChanged = [map_annotation updateAnnotationWith:m_annotation onlyifIDsAreSame:true];
                if(bChanged) {
                    [annotationsAdded addObject:m_annotation];
                    break;
                }
            }
            if(!bChanged) {
                [annotationsToRemove addObject:map_annotation];
            }
        }
    }
    
    for(id m_annotation in self.annotations) {
        if(![annotationsAdded containsObject:m_annotation]) {
            [self.mapView addAnnotation:m_annotation];
        }
    }
    
    [self.mapView removeAnnotations:annotationsToRemove];
    */
    //NSLog(@"After_m=%d, After_map=%d\n", [self.annotations count],[self.mapView.annotations count] );
    //if(self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    //[self.mapView addAnnotations:self.annotations];
}

- (void)refreshSpots
{
    //GAURAV removing this low thing so i can use the offers to query of the spot status
    
    
    [[self getParkingSpots] updateWithRequest:[NSDictionary dictionaryWithObject:@"all" forKey:@"level_of_detail"]];
    //    [[self getParkingSpots] updateWithRequest:[NSDictionary dictionaryWithObject:@"low" forKey:@"level_of_detail"]];
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

// --ADDRESS BAR-- //

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //NSLog(@"%@",textField.text);
    [self expandAddressBar:false];
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)confirmationButtonTapped:(id)sender {
    if([self hasReservation]==0) {
        return;
    }
    [self switchToConfirmation];
    //[self openSpotConirmationViewWithSpot:[Persistance retrieveCurrentSpotId]];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self handleSearch:searchBar];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self expandAddressBar:true];
    //searchBar.showsCancelButton = true;
    self.mapView.userInteractionEnabled = false;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    //searchBar.showsCancelButton = false;
    [self expandAddressBar:false];
    self.mapView.userInteractionEnabled = true;
    //[self handleSearch:searchBar];
}

- (void)handleSearch:(UISearchBar *)searchBar {
    
    CLLocationCoordinate2D southwest, northeast;
    CLLocationCoordinate2D center = self.mapView.centerCoordinate;
    
    southwest.latitude = center.latitude - 3;
    southwest.longitude = center.longitude - 3;
    northeast.latitude = center.latitude + 3;
    northeast.longitude = center.longitude +3;
    
    /* Failed to find this symbol (BSForwardGeocoderCoordinateBounds) when I pushed the BSGeocoder library into the project directory.
    BSForwardGeocoderCoordinateBounds *bounds = [BSForwardGeocoderCoordinateBounds boundsWithSouthWest:southwest northEast:northeast];
     */
    
    NSLog(@"Searching for: %@", searchBar.text);
    [self.forwardGeocoder forwardGeocodeWithQuery:searchBar.text regionBiasing:nil];

    [self expandAddressBar:false];
    [searchBar resignFirstResponder]; //close the keyboard
}
- (void)forwardGeocodingDidSucceed:(BSForwardGeocoder*)geocoder withResults:(NSArray *)results{
    if([results count] >= 1) {
        BSKmlResult* place = [results objectAtIndex:0];
        
        STargetLocation target;
        target.type = TARGET_SEARCHED_LOCATION;
        target.location = place.coordinate;
        
        self.targetLocation = target;
        
        self.lastSearchedLocation = place.coordinate;
        
        
        [self showTargetPin:true];
        
        NSString* toastText = [NSString stringWithFormat:@"Found place: %@", place.address];
        
        [[[iToast makeText:toastText] setGravity:iToastGravityBottom ] show];
        
        
        
        [self goToCoord:place.coordinate handleZoom:true viewNearestSpot:true];
        
        //[self goToRegion:place.coordinateRegion];
    }
}

//for some reason, can't get this to be called.
-(void)forwardGeocodingDidFail:(BSForwardGeocoder *)geocoder withErrorCode:(int)errorCode andErrorMessage:(NSString *)errorMessage {
    [[[iToast makeText:errorMessage] setGravity:iToastGravityBottom ] show];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self expandAddressBar:false];
    [searchBar resignFirstResponder]; //close the keyboard
}

// --END ADDRESS BAR-- //


- (IBAction)parkMeNowButtonTapped:(UIButton *)sender {
    //Testing modal stuff
    
    double dist = [[self getParkingSpots] distanceToClosestAvailableSpotToCoord:self.targetLocation.location];
    
    if(dist > 5) {
        [[[iToast makeText:@"No spot within 5 miles."] setGravity:iToastGravityBottom ] show];
        return;
    }
    ParkingSpot* parkMeNowSpot = [[self getParkingSpots] closestAvailableSpotToCoord:self.targetLocation.location];
    if(parkMeNowSpot) {
        [self openSpotViewControllerWithSpot:[NSString stringWithFormat:@"%i", parkMeNowSpot.actualID]];
    } else {
        [[[iToast makeText:@"No closest available spot"] setGravity:iToastGravityBottom ] show];
    }
     
}
-(void)launchExtendReservation:(NSString *)key{
    [self stopPolling];
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                             bundle: nil];
    
    ParkifyConfirmationViewController* controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"ConfirmationVC"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [navController.navigationBar setTintColor:[UIColor blackColor]];
    
    controller.spot = [Persistance retrieveCurrentSpot];
    ParkifyAppDelegate *delegate = (ParkifyAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSDictionary *actives = [delegate.transactions objectForKey:@"active"];
    NSMutableDictionary *transact = [actives objectForKey:key];
    
    controller.transactionInfo = transact ;
    // controller.startTime = [Persistance retrieveCurrentStartTime];
    // controller.endTime = [Persistance retrieveCurrentEndTime];

    controller.currentLat = delegate.currentLat;
    controller.currentLong = delegate.currentLong;
    
    extendReservationViewController *controllerer = [mainStoryboard instantiateViewControllerWithIdentifier: @"extendResVC"];
    controllerer.transactioninfo= transact;
    [controller.navigationController pushViewController:controllerer animated:NO];

    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:navController animated:true completion:^{}];

}

- (void) switchToConfirmation {
    [self stopPolling];
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                                 bundle: nil];
        
        ParkifyConfirmationViewController* controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"ConfirmationVC"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [navController.navigationBar setTintColor:[UIColor blackColor]];

    controller.spot = [Persistance retrieveCurrentSpot];
    ParkifyAppDelegate *delegate = (ParkifyAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSDictionary *actives = [delegate.transactions objectForKey:@"active"];
    NSMutableDictionary *transact = [actives objectForKey:[[actives allKeys] lastObject]];

    controller.transactionInfo = transact ;
       // controller.startTime = [Persistance retrieveCurrentStartTime];
       // controller.endTime = [Persistance retrieveCurrentEndTime];
        
        controller.currentLat = delegate.currentLat;
        controller.currentLong = delegate.currentLong;
        
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:navController animated:true completion:^{}];
}
- (IBAction)searchButtonTapped:(id)sender {
    [self.addressBar becomeFirstResponder];
}
@end
