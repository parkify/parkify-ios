//
//  Parkify2AppDelegate.h
//  Parkify2
//
//  Created by Me on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "User.h"
#import "ParkingSpotCollection.h"

#define APP_VERSION @"v1.3"


@interface ParkifyAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//TODO: Generalize shared objects as a "AppDataObject" class
@property (strong, nonatomic) User* user;
@property (strong, nonatomic) ParkingSpotCollection* parkingSpots;

@end
