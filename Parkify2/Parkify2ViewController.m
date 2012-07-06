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

@interface Parkify2ViewController ()

@end

@implementation Parkify2ViewController
@synthesize mapView = _mapView;
@synthesize timerPolling = _timerPolling;
@synthesize timerDuration = _timerDuration;
@synthesize locationManager = _locationManager;
@synthesize currentLat = _currentLat;
@synthesize currentLong = _currentLong;

@synthesize annotations = _annotations;

@synthesize parkingSpots = _parkingSpots;

-(void)spotsWereUpdated 
{
    NSMutableArray* annotations = [[NSMutableArray alloc] init ];
    for (ParkingSpot* spot in [self.parkingSpots.parkingSpots allValues]) {
        [annotations addObject:[ParkingSpotAnnotation annotationForSpot:spot]];
    }
    self.annotations = annotations;
}

- (void)updateMapView {
    if(self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:self.annotations];
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
        _parkingSpots.observerDelegate = self;
    }
    return _parkingSpots;
}

- (void)refreshSpots
{
    //MKCoordinateRegion mapRegion = [self.mapView region];
    //CLLocationCoordinate2D centerLocation = mapRegion.center;
    
    // 2
    /*
     NSString *jsonFile = [[NSBundle mainBundle] pathForResource:@"command" ofType:@"json"];
     NSString *formatString = [NSString stringWithContentsOfFile:jsonFile encoding:NSUTF8StringEncoding error:nil];
     NSString *json = [NSString stringWithFormat:formatString, 
     centerLocation.latitude, centerLocation.longitude, 0.5*METERS_PER_MILE];
     */
    // 3
    NSURL *url = [NSURL URLWithString:@"http://swooplot.herokuapp.com/parking_spots"];
    
    // 4
    ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *request = _request;
    
    request.requestMethod = @"GET";    
    //[request addRequestHeader:@"Content-Type" value:@"application/json"];
    //[request appendPostData:[json dataUsingEncoding:NSUTF8StringEncoding]];
    // 5
    [request setDelegate:self];
    [request setCompletionBlock:^{         
        NSString *responseString = [request responseString];
        //NSLog(@"Response: %@", responseString);
        [self plotParkingSpotsFromString:responseString];
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"Error: %@", error.localizedDescription);
    }];
    
    // 6
    [request startAsynchronous];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setMapView:nil];
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

- (void)plotParkingSpotsFromString:(NSString *)responseString {
    [self.parkingSpots updateFromJSONString:responseString];
}


- (IBAction)refreshTapped:(id)sender {
    [self refreshSpots];
    NSLog(@"ZOOM LEVEL: %d\n", [self.mapView zoomLevel]);
}

- (IBAction)myLocationTapped:(id)sender {
    int curZoom = [self.mapView zoomLevel];
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = self.currentLat;
    zoomLocation.longitude = self.currentLong;
    
    [self.mapView setCenterCoordinate:zoomLocation zoomLevel:curZoom animated:TRUE];
    
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
        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        if([spot mFree])
        {
            annotationView.image=[UIImage imageNamed:@"parking_icon_free.png"];//here we use a nice image instead of the default pins
        } else {
            annotationView.image=[UIImage imageNamed:@"parking_icon_taken.png"];
        }
        
        return annotationView;
    }
    
    return nil;    
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"%@",textField.text);
    [textField resignFirstResponder];
    return NO;
}

@end
