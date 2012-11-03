//
//  UIViewController+AppData_ParkingSpotCollection.m
//  Parkify
//
//  Created by Me on 11/3/12.
//
//

#import "UIViewController+AppData_ParkingSpotCollection.h"
#import "ParkifyAppDelegate.h"

@implementation UIViewController (AppData_ParkingSpotCollection)

- (ParkingSpotCollection*)getParkingSpots {
    ParkingSpotCollection* toRtn = ((ParkifyAppDelegate*)[[UIApplication sharedApplication] delegate]).parkingSpots;
    toRtn.observerDelegate = self;
    return toRtn;
}

@end
