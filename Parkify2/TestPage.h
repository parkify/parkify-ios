//
//  ErrorPage.h
//  Parkify
//
//  Created by Me on 1/24/13.
//
//

#import <UIKit/UIKit.h>
#import "DirectionsFlowing.h"
#import "ParkingSpot.h"

@interface TestPage : UIControl <DirectionsFlowing>

- (void)moreToLeft:(BOOL)isMore;
- (void)moreToRight:(BOOL)isMore;

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

@property (strong, nonatomic) UILabel* label;

@end
