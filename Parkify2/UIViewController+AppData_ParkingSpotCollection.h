//
//  UIViewController+AppData_ParkingSpotCollection.h
//  Parkify
//
//  Created by Me on 11/3/12.
//
//

#import <UIKit/UIKit.h>
#import "ParkingSpotCollection.h"

@interface UIViewController (AppData_ParkingSpotCollection) <ParkingSpotObserver>

- (ParkingSpotCollection*)getParkingSpots;

@end
