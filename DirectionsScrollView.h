//
//  DirectionsScrollView.h
//  Parkify
//
//  Created by Me on 1/24/13.
//
//

#import <UIKit/UIKit.h>
#import "Acceptance.h"
#import "ParkingSpot.h"
#import "ConfirmationPage.h"

@interface DirectionsScrollView : UIControl <UIScrollViewDelegate>

@property (strong, nonatomic) UIControl<DirectionsFlowing>* drivingDirectionsPage;
@property (strong, nonatomic) NSMutableArray* parkingDirectionsPages;
@property (strong, nonatomic) UIControl<DirectionsFlowing>* confirmationPage;

@property int currentParkingDirectionsPage;
@property int currentDirectionsGroup;

-(void)setPageGroup:(int)group;

@property (nonatomic, strong) Acceptance* reservation;
@property (nonatomic, strong) ParkingSpot* spot;

- (id)initWithFrame:(CGRect)frame withSpot:(ParkingSpot *)spot withReservation:(Acceptance *)reservation;

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

@end
