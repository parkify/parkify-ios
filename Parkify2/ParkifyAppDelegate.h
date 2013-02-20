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
#import "ASIHTTPRequest.h"
#import "NSNull+Debug.h"
#define APP_VERSION @"v1.4"


@interface ParkifyAppDelegate : UIResponder <UIApplicationDelegate, ASIHTTPRequestDelegate>
{
    NSMutableDictionary *transactions;
    NSURL *openURL;
    BOOL isNew;
    BOOL reservationUsed;
    
}

@property double currentLat;
@property double currentLong;
@property (nonatomic, assign) BOOL reservationUsed;
@property (nonatomic, assign) BOOL isNew;
@property (nonatomic, strong) NSURL *openURL;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSMutableDictionary *transactions;
//TODO: Generalize shared objects as a "AppDataObject" class
@property (strong, nonatomic) User* user;
@property (strong, nonatomic) ParkingSpotCollection* parkingSpots;

@property (strong, nonatomic) CLLocationManager* locationManager;


@end
