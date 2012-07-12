//
//  Parkify2ViewController.h
//  Parkify2
//
//  Created by Me on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MKMapView+ZoomLevel.h"
#import <CoreLocation/CoreLocation.h>
#import "ParkingSpot.h"
#import "BSForwardGeocoder.h"

#define METERS_PER_MILE 1609.344

@interface Parkify2ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate,ParkingSpotObserver, UISearchBarDelegate, BSForwardGeocoderDelegate>
{
    CLLocationManager *_locationManager;
    double _currentLat;
    double _currentLong;
}
@property(nonatomic, retain)CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSTimer *timerPolling;
@property float timerDuration;
@property double currentLat;
@property double currentLong;
@property (weak, nonatomic) IBOutlet UISearchBar *addressBar;
@property (weak, nonatomic) IBOutlet UIButton *myLocationButton;
@property CLLocationCoordinate2D lastSearchedLocation;

@property (nonatomic, strong) ParkingSpotCollection* parkingSpots;
@property (nonatomic, strong) ParkingSpot* targetSpot;

@property (nonatomic, strong) NSArray* annotations; //Of type id <MKAnnotation>

- (IBAction)parkMeNowButtonTapped:(UIButton *)sender;

- (IBAction)refreshTapped:(id)sender;

- (IBAction)myLocationTapped:(id)sender;

- (IBAction)AddressEntered:(id)sender;

- (BOOL)textFieldShouldReturn:(UITextField *)textField;


@end
