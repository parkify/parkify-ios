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
//#import "UIViewController+overView.h"
#import "Api.h"
#import "iToast.h"
#import "WaitingMask.h"

#define ORIG_ANNOTATION_WIDTH 54
#define ORIG_ANNOTATION_HEIGHT 89

#define ANNOTATION_WIDTH (ORIG_ANNOTATION_WIDTH*0.5)
#define ANNOTATION_HEIGHT (ORIG_ANNOTATION_HEIGHT*0.5)

#define INIT_VIEW_WIDTH_IN_MILES 1.0

typedef enum targetLocationType {
    TARGET_CURRENT_LOCATION = 0,
    TARGET_SEARCHED_LOCATION = 1,
}targetLocationType;


@interface Parkify2ViewController ()
@property (nonatomic, strong) BSForwardGeocoder* forwardGeocoder;
@property targetLocationType targetType;
@property BOOL bAlreadyInit;
@property (nonatomic, strong) LocationAnnotation*  targetLocationAnnotation;

@property (nonatomic, strong) WaitingMask* waitingMask;
@end

@implementation Parkify2ViewController
@synthesize mapView = _mapView;
@synthesize timerPolling = _timerPolling;
@synthesize timerDuration = _timerDuration;
@synthesize locationManager = _locationManager;
@synthesize currentLat = _currentLat;
@synthesize currentLong = _currentLong;
@synthesize addressBar = _addressBar;
@synthesize myLocationButton = _myLocationButton;
@synthesize targetSpot = _targetSpot;
@synthesize lastSearchedLocation = _lastSearchedLocation;
@synthesize targetType = _targetType;
@synthesize vcToSwitch = _vcToSwitch;
@synthesize bAlreadyInit = _bAlreadyInit;

@synthesize annotations = _annotations;

@synthesize parkingSpots = _parkingSpots;

@synthesize forwardGeocoder = _forwardGeocoder;

@synthesize targetLocationAnnotation = _targetLocationAnnotation;

@synthesize waitingMask = _waitingMask;



- (ParkingSpotCollection*)parkingSpots {
    if(!_parkingSpots) {
        _parkingSpots = [[ParkingSpotCollection alloc] init];
    }
    _parkingSpots.observerDelegate = self;
    return _parkingSpots;
}

- (BSForwardGeocoder*)forwardGeocoder {
    if(_forwardGeocoder == nil) {
        _forwardGeocoder = [[BSForwardGeocoder alloc] initWithDelegate:self];
    }
    return _forwardGeocoder;
}

-(CLLocationCoordinate2D)targetLocation {
    CLLocationCoordinate2D toRtn;
    toRtn.latitude = self.currentLat;
    toRtn.longitude = self.currentLong;
    /*
    if(self.targetType == TARGET_CURRENT_LOCATION) {
        toRtn.latitude = self.currentLat;
        toRtn.longitude = self.currentLong;
    } else if (self.targetType == TARGET_SEARCHED_LOCATION) {
        toRtn = self.lastSearchedLocation;
    }
     */
    return toRtn;
}


- (void)setMapView:(MKMapView *)mapView {
    _mapView = mapView;
    [self updateMapView];
}

- (void)setAnnotations:(NSArray *)annotations {
    _annotations = annotations;
    [self updateMapView];
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    //[self.navigationController setNavigationBarHidden:NO animated:animated];
    [self stopPolling];
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [super viewWillAppear:animated];
    if(!self.bAlreadyInit) {
        
        //** Set up waitingMask **//
        CGRect waitingMaskFrame = self.view.frame;
        waitingMaskFrame.origin.x = 0;
        waitingMaskFrame.origin.y = 0;
        
        self.waitingMask = [[WaitingMask alloc] initWithFrame:waitingMaskFrame];
        [self.view addSubview:self.waitingMask];
        //**  **//
        
        self.currentLat = 37.872679;
        self.currentLong = -122.266797;
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager startUpdatingLocation];
        self.mapView.delegate = self;
        
        if(self.locationManager.location != nil) {
            self.currentLat = self.locationManager.location.coordinate.latitude;
            self.currentLong = self.locationManager.location.coordinate.longitude;
        }
        CLLocationCoordinate2D initCoord;
        initCoord.latitude = self.currentLat;
        initCoord.longitude = self.currentLong;
        
        /*
        self.targetType = TARGET_SEARCHED_LOCATION;
        self.lastSearchedLocation = targetLocation;
        */
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(initCoord, INIT_VIEW_WIDTH_IN_MILES*METERS_PER_MILE, INIT_VIEW_WIDTH_IN_MILES*METERS_PER_MILE);
        MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
        [self.mapView setRegion:adjustedRegion animated:YES];
        
        
        self.addressBar.delegate = self;
    
        self.addressBar.showsSearchResultsButton = false;
        
        self.bAlreadyInit = true;
        
        self.targetLocationAnnotation = [[LocationAnnotation alloc] init];
        self.targetLocationAnnotation.coordinate = initCoord;
        
        //[self.mapView addAnnotation:self.targetLocationAnnotation];
        
        /*
        self.
        self.mapView.alpha = .5;
        */
        [self.mapView setNeedsDisplay];
        
        //[UIView animateWithDuration:5
          //               animations: ^{[self.mapView setAlpha:1];}
            //             completion: ^(BOOL finished){}];

        
    }
    
    
    //[[UISearchBar appearance]setSearchFieldBackgroundImage:[UIImage imageNamed:@"crosshair.png"] forState:UIControlStateNormal];
    
    /*
    for (UIView *subview in self.addressBar.subviews) {
        NSLog(@"%@", subview.class);
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [subview removeFromSuperview];
            //break;
        }
    } */
    /*
    for (UIView *subview in self.addressBar.subviews) {
        NSLog(@"%@", subview.class);
        if (![subview isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
            [subview removeFromSuperview];
            //break;
        }
    } */
    
    self.timerDuration = 10;
    [self refreshSpots];
    [self startPolling];
    
    
    
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
    self.currentLat = newLocation.coordinate.latitude;
    self.currentLong = newLocation.coordinate.longitude;
    
    //NSLog(@"New latitude: %f", newLocation.coordinate.latitude);
    //NSLog(@"New longitude: %f", newLocation.coordinate.longitude);
}

- (void)goToRegion:(MKCoordinateRegion)region {
    //int curZoom = [self.mapView zoomLevel];
    [self.mapView setRegion:region animated:TRUE];
    //[self.mapView setCenterCoordinate:target zoomLevel:curZoom animated:TRUE];
}

- (void)goToCoord:(CLLocationCoordinate2D)target{
    int curZoom = [self.mapView zoomLevel];
    [self.mapView setCenterCoordinate:target zoomLevel:curZoom animated:TRUE];
}

- (IBAction)settingsButtonTapped:(UIButton *)sender {
    /*
    [Api settingsModallyFrom:self withSuccess:^(NSDictionary * results) {
        NSLog(@"%@", results);
    }];
    */
    
    [Api authenticateModallyFrom:self withSuccess:^(NSDictionary * results) {
        NSLog(@"%@", results);
    }];
     
}

- (IBAction)myLocationTapped:(id)sender {
    if(![CLLocationManager headingAvailable]) {
        //don't move!
        [[[iToast makeText:@"Can't find current location."] setGravity:iToastGravityBottom ] show];
        return;
    }
    
    [self showTargetPin:false];
    
    CLLocationCoordinate2D myLocation;
    myLocation.latitude = self.currentLat;
    myLocation.longitude = self.currentLong;
    
    
    
    self.targetType = TARGET_CURRENT_LOCATION;
    
    [self goToCoord:myLocation];
}

- (IBAction)AddressEntered:(UITextField*)sender {
    NSLog(@"%@",sender.text);
    [sender resignFirstResponder];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    
    static NSString *identifier; 
    
    
    if ([annotation isKindOfClass:[ParkingSpotAnnotation class]]) {
        
        ParkingSpot* spot = ((ParkingSpotAnnotation*)annotation).spot;
        
        
        if(spot.mPrice < LOW_PRICE_THRESHOLD)
        {
            identifier = @"spot_low_cost";
        } else if (spot.mPrice < HIGH_PRICE_THRESHOLD) {
            identifier = @"spot_mid_cost";
        } else {
            identifier = @"spot_high_cost";
        }
        
        
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.canShowCallout = YES;
            annotationView.enabled = YES;
            annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,30,30)];
        }
        
        annotationView.annotation = annotation;
        [(UIImageView*)annotationView.leftCalloutAccessoryView setImage:nil];
        
        UIImage* img;
        if(spot.mPrice < LOW_PRICE_THRESHOLD)
        {
            img=[UIImage imageNamed:@"blue_spot_marker.png"];
        } else if (spot.mPrice < HIGH_PRICE_THRESHOLD) {
            img=[UIImage imageNamed:@"black_spot_marker.png"];
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
        btnViewVenue.frame = CGRectMake(0, 0,65, 25);
        
        //NSString *btnString = @"PARK!";
        NSString *btnString = @"Park";
        CGSize s = [btnString sizeWithFont:[UIFont fontWithName:@"Arial Rounded MT Bold" size:(14.0)] constrainedToSize:btnViewVenue.frame.size lineBreakMode:UILineBreakModeMiddleTruncation];
        [btnViewVenue setBackgroundImage:[UIImage imageNamed:@"blue_small_button.png"]
                            forState:UIControlStateNormal];

        btnViewVenue.titleLabel.frame = CGRectMake(0,0,s.width,s.height);
        [btnViewVenue setTitle:btnString forState:UIControlStateNormal];
        
        btnViewVenue.titleLabel.textColor = [UIColor whiteColor];
        btnViewVenue.titleLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(14.0)];
        
        
        btnViewVenue.tag = spot.mID;
        [btnViewVenue addTarget:self action:@selector(spotMoreInfo:) forControlEvents:UIControlEventTouchUpInside];
        annotationView.rightCalloutAccessoryView = btnViewVenue;
        
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ViewSpot"]) {
        
        ParkifySpotViewController *newController = segue.destinationViewController;
        newController.parkingSpots = self.parkingSpots;
        self.parkingSpots.observerDelegate = newController;
        newController.spot = self.targetSpot;
    }
}

- (void)openSpotViewControllerWithSpot:(int)spotID {
    [self stopPolling];
    self.targetSpot = [self.parkingSpots parkingSpotForID:spotID];
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    //self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    //
    //ParkifySpotViewController *sampleView = [[ParkifySpotViewController alloc] initWithNibName:@"SpotView" bundle:nil];
    //sampleView.delegate = self;
    //[self.navigationController presentModalViewController:sampleView animated:YES];
    
    [self performSegueWithIdentifier:@"ViewSpot" sender:self];
    //ParkifySpotViewController* spotView = [[ParkifySpotViewController alloc] init];
    //[self.navigationController presentOverViewController:spotView animated:true];
}

- (IBAction)spotMoreInfo:(UIButton*)sender {
    [self openSpotViewControllerWithSpot:sender.tag];
}
//- calloutAccessoryControlTapped:


//TODO: Change "little_man.png" to be thumbnail of parking spot image
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    UIImage* image = [UIImage imageNamed:@"little_man.png"];
    [(UIImageView*)view.leftCalloutAccessoryView setImage:image];
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


-(void)spotsWereUpdated 
{
    NSMutableArray* annotations = [[NSMutableArray alloc] init ];
    for (ParkingSpot* spot in [self.parkingSpots.parkingSpots allValues]) {
        [annotations addObject:[ParkingSpotAnnotation annotationForSpot:spot]];
    }
    self.annotations = annotations;
}

- (void)updateMapView {
    //Terrible, must be some better way to update.
    
    if(self.waitingMask) {
        [self.waitingMask removeFromSuperview];
        self.waitingMask = nil;
    }
    
    BOOL bChanged = false;
    NSMutableArray* annotationsToRemove = [[NSMutableArray alloc] init];
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
    
    //NSLog(@"After_m=%d, After_map=%d\n", [self.annotations count],[self.mapView.annotations count] );
    //if(self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    //[self.mapView addAnnotations:self.annotations];
}

- (void)refreshSpots
{
    [self.parkingSpots updateWithRequest:nil];
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
    
    
    for(NSObject<MKAnnotation>* pin in self.mapView.annotations)
    {
        NSLog(@"IMG FOR %@ is %@", pin, [self.mapView viewForAnnotation:pin].image);
    }
    
    
    self.timerPolling = [NSTimer scheduledTimerWithTimeInterval: self.timerDuration
                                                         target: self
                                                       selector:@selector(onTick:)
                                                       userInfo: nil repeats:NO];

}

// --ADDRESS BAR-- //
/*
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //NSLog(@"%@",textField.text);
    [textField resignFirstResponder];
    return NO;
}
*/

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self handleSearch:searchBar];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = true;
    self.mapView.userInteractionEnabled = false;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = false;
    self.mapView.userInteractionEnabled = true;
    //[self handleSearch:searchBar];
}

- (void)handleSearch:(UISearchBar *)searchBar {
    NSLog(@"Searching for: %@", searchBar.text);
    [self.forwardGeocoder forwardGeocodeWithQuery:searchBar.text regionBiasing:nil];
    [searchBar resignFirstResponder]; //close the keyboard
}
- (void)forwardGeocodingDidSucceed:(BSForwardGeocoder*)geocoder withResults:(NSArray *)results{
    if([results count] >= 1) {
        BSKmlResult* place = [results objectAtIndex:0];
        
        self.targetType = TARGET_SEARCHED_LOCATION;
        self.lastSearchedLocation = place.coordinate;
        self.targetLocationAnnotation.coordinate = place.coordinate;
        [self showTargetPin:true];
        
        NSString* toastText = [NSString stringWithFormat:@"Found place: %@", place.address];
        
        [[[iToast makeText:toastText] setGravity:iToastGravityBottom ] show];
        
        [self goToCoord:place.coordinate];
        
        //[self goToRegion:place.coordinateRegion];
    }
}

//for some reason, can't get this to be called.
-(void)forwardGeocodingDidFail:(BSForwardGeocoder *)geocoder withErrorCode:(int)errorCode andErrorMessage:(NSString *)errorMessage {
    [[[iToast makeText:errorMessage] setGravity:iToastGravityBottom ] show];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder]; //close the keyboard
}

// --END ADDRESS BAR-- //


- (IBAction)parkMeNowButtonTapped:(UIButton *)sender {
    //Testing modal stuff
    
    ParkingSpot* parkMeNowSpot = [self.parkingSpots closestAvailableSpotToCoord:[self targetLocation]];
    if(parkMeNowSpot) {
        [self openSpotViewControllerWithSpot:parkMeNowSpot.mID];
    } else {
        [[[iToast makeText:@"No closest available spot"] setGravity:iToastGravityBottom ] show];
    }
     
}
@end
