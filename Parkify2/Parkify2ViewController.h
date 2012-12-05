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
#import "BSForwardGeocoder.h"
#import "UIViewController+AppData_ParkingSpotCollection.h"

#define METERS_PER_MILE 1609.344

@protocol VCNavigationDelegate <NSObject>

-(void)setNextViewControllerAs:(UIViewController *) toSwitch;

@end

@interface Parkify2ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate,ParkingSpotObserver, UISearchBarDelegate, BSForwardGeocoderDelegate, UIAlertViewDelegate >
{
    CLLocationManager *_locationManager;
    double _currentLat;
    double _currentLong;
}
@property (nonatomic, retain)CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSTimer *timerPolling;
@property float timerDuration;
@property double currentLat;
@property double currentLong;
@property (weak, nonatomic) IBOutlet UISearchBar *addressBar;
@property (weak, nonatomic) IBOutlet UIButton *myLocationButton;
@property CLLocationCoordinate2D lastSearchedLocation;
@property (weak, nonatomic) IBOutlet UIView *bottomBarSmallReferenceView;
@property (weak, nonatomic) IBOutlet UIView *bottomBarLargeReferenceView;
@property (weak, nonatomic) IBOutlet UIView *searchBarLargeReferenceView;
@property (weak, nonatomic) IBOutlet UIButton *bottomBarButton;
@property (weak, nonatomic) IBOutlet UIImageView *searchBarSmallReferenceView;
@property (weak, nonatomic) IBOutlet UIView *searchBarContainer;

@property (weak, nonatomic) IBOutlet UIView *locationButtonLargeReferenceView;
@property (weak, nonatomic) IBOutlet UIView *locationButtonSmallReferenceView;
@property (nonatomic, strong) ParkingSpotCollection* parkingSpots;
@property (nonatomic, strong) ParkingSpot* targetSpot;

@property (nonatomic, strong) NSArray* annotations; //Of type id <MKAnnotation>

- (IBAction)parkMeNowButtonTapped:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
- (IBAction)searchButtonTapped:(id)sender;

- (IBAction)settingsButtonTapped:(UIButton *)sender;

- (IBAction)myLocationTapped:(id)sender;

- (IBAction)AddressEntered:(id)sender;

- (BOOL)textFieldShouldReturn:(UITextField *)textField;

- (IBAction)confirmationButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *confirmationButton;

@end
