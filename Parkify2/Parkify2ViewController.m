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


@interface Parkify2ViewController ()
@property (nonatomic, strong) BSForwardGeocoder* forwardGeocoder;
@end

@implementation Parkify2ViewController
@synthesize mapView = _mapView;
@synthesize timerPolling = _timerPolling;
@synthesize timerDuration = _timerDuration;
@synthesize locationManager = _locationManager;
@synthesize currentLat = _currentLat;
@synthesize currentLong = _currentLong;
@synthesize addressBar = _addressBar;
@synthesize targetSpot = _targetSpot;

@synthesize annotations = _annotations;

@synthesize parkingSpots = _parkingSpots;

@synthesize forwardGeocoder = _forwardGeocoder;

- (BSForwardGeocoder*)forwardGeocoder {
    if(_forwardGeocoder == nil) {
        _forwardGeocoder = [[BSForwardGeocoder alloc] initWithDelegate:self];
    }
    return _forwardGeocoder;
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

- (void)setMapView:(MKMapView *)mapView {
    _mapView = mapView;
    [self updateMapView];
}

- (void)setAnnotations:(NSArray *)annotations {
    _annotations = annotations;
    [self updateMapView];
}

- (ParkingSpotCollection*)parkingSpots {
    if(!_parkingSpots) {
        _parkingSpots = [[ParkingSpotCollection alloc] init];
    }
    _parkingSpots.observerDelegate = self;
    return _parkingSpots;
}

- (void)refreshSpots
{
    [self.parkingSpots updateWithRequest:nil];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 37.872679;
    zoomLocation.longitude = -122.266797;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    self.mapView.delegate = self;
    
    self.addressBar.delegate = self;
    
    self.timerDuration = 3;
    [self refreshSpots];
    [self startPolling];
    
    
    
}

- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation {

    self.currentLat = newLocation.coordinate.latitude;
    self.currentLong = newLocation.coordinate.longitude;
    
    //NSLog(@"New latitude: %f", newLocation.coordinate.latitude);
    //NSLog(@"New longitude: %f", newLocation.coordinate.longitude);
}

- (void)goToCoord:(CLLocationCoordinate2D)target {
    int curZoom = [self.mapView zoomLevel];
    [self.mapView setCenterCoordinate:target zoomLevel:curZoom animated:TRUE];
}

- (IBAction)myLocationTapped:(id)sender {
    int curZoom = [self.mapView zoomLevel];
    
    CLLocationCoordinate2D myLocation;
    myLocation.latitude = self.currentLat;
    myLocation.longitude = self.currentLong;
    
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
        
        if([spot mFree])
        {
            identifier = @"ParkingSpot-Free";
        } else {
            identifier = @"ParkingSpot-Taken";
        }
        
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.canShowCallout = YES;
            annotationView.enabled = YES;
            annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,30,30)];
        }
        
        annotationView.annotation = annotation;
        [(UIImageView*)annotationView.leftCalloutAccessoryView setImage:nil];
        if([spot mFree])
        {
            annotationView.image=[UIImage imageNamed:@"parking_icon_free.png"];//here we use a nice image instead of the default pins
        } else {
            annotationView.image=[UIImage imageNamed:@"parking_icon_taken.png"];
        }
        
        UIButton* btnViewVenue = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        btnViewVenue.tag = spot.mID;
        [btnViewVenue addTarget:self action:@selector(spotMoreInfo:) forControlEvents:UIControlEventTouchUpInside];
        annotationView.rightCalloutAccessoryView = btnViewVenue;
        
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
    [self performSegueWithIdentifier:@"ViewSpot" sender:self];
}

- (IBAction)spotMoreInfo:(UIButton*)sender {
    [self openSpotViewControllerWithSpot:sender.tag];
}
//- calloutAccessoryControlTapped:


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    UIImage* image = [UIImage imageNamed:@"crosshair.png"];
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

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
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
        NSLog(@"Found place at location (%g,%g)", place.latitude, place.longitude);
        
        CLLocationCoordinate2D targetLocation;
        targetLocation.latitude = place.latitude;
        targetLocation.longitude = place.longitude;
        
        [self goToCoord:targetLocation];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder]; //close the keyboard
}

// --END ADDRESS BAR-- //

@end
