//
//  ParkingDirectionsPage.h
//  Parkify
//
//  Created by Me on 1/26/13.
//
//

#import <UIKit/UIKit.h>
#import "DirectionsFlowing.h"
#import "ParkingSpot.h"
#import "Acceptance.h"


@interface ParkingDirectionsPage : UIControl<DirectionsFlowing, MKMapViewDelegate>

@property (nonatomic, strong) ParkingSpot* spot;
@property (nonatomic, weak) Acceptance *reservation;
@property int index;
@property int totalIndex;

- (id)initWithFrame:(CGRect)frame withSpot:(ParkingSpot *)spot withReservation:(Acceptance *)reservation withIndex:(int)index withTotalIndex:(int)totalIndex;

-(void)moreToRight:(BOOL)isMore;
-(void)moreToLeft:(BOOL)isMore;

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

@end


@interface DirectionAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) double heading;

@end