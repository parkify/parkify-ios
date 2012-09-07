//
//  Persistance.h
//  Parkify2
//
//  Created by Me on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParkingSpot.h"

@interface Persistance : NSObject
+(void)saveUser:(NSDictionary*)user;
+(NSDictionary*)retrieveUser;
+(void)saveAuthToken:(NSString*)token;
+(NSString*)retrieveAuthToken;


+(void)saveLicensePlateNumber:(NSString*)lpn;
+(NSString*)retrieveLicensePlateNumber;

+(void)saveLastFourDigits:(NSString*)lfd;
+(NSString*)retrieveLastFourDigits;

+(void)saveLastAmountCharged:(double)lac;
+(double)retrieveLastAmountCharged;

+(void)saveCurrentSpotId:(int)spotId;
+(int)retrieveCurrentSpotId;

+(void)saveCurrentSpot:(ParkingSpot*)spot;
+(ParkingSpot*)retrieveCurrentSpot;

+(void)saveCurrentStartTime:(double)timeIn;
+(double)retrieveCurrentStartTime;

+(void)saveCurrentEndTime:(double)timeIn;
+(double)retrieveCurrentEndTime;

//ok, so I need to add spots serverside and check if spots are free

/*
+(NSString*)retrieveShadowLastFourDigits;
+(NSString*)retrieveShadowLicensePlate;
 */
@end
