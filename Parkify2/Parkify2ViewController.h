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


@interface Parkify2ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate,ParkingSpotObserver, UISearchBarDelegate, BSForwardGeocoderDelegate, UIAlertViewDelegate >
{
    CLLocationManager *_locationManager;
}


@property float timerDuration;

@property (nonatomic, strong) ParkingSpotCollection* parkingSpots;
@property (nonatomic, strong) ParkingSpot* targetSpot;
@property (nonatomic, strong) NSArray* annotations; //Of type id <MKAnnotation>


- (IBAction)parkMeNowButtonTapped:(UIButton *)sender;
- (IBAction)searchButtonTapped:(id)sender;
- (IBAction)settingsButtonTapped:(UIButton *)sender;
- (IBAction)myLocationTapped:(id)sender;
- (IBAction)confirmationButtonTapped:(id)sender;

- (BOOL)textFieldShouldReturn:(UITextField *)textField;




@end
