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

+(NSMutableDictionary*)addNewTransaction:(ParkingSpot*)spot withStartTime:(double)timeIn andEndTime:(double)timeOut andLastPaymentDetails:(NSString*)details withTransactionID:(NSString*)acceptanceid;
+(NSDictionary*)retrieveTransactions;
+(void)saveUserID:(NSNumber*)user;
+(NSNumber*)retrieveUserID;
+(void)saveAuthToken:(NSString*)token;
+(NSString*)retrieveAuthToken;

+(void)updatePersistedDataWithAppVersion;


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
//+(double)retrieveCurrentStartTime;

+(void)saveCurrentEndTime:(double)timeIn;
//+(double)retrieveCurrentEndTime;

+(void)saveLastPaymentInfoDetails:(NSString*)lpid;
+(NSString*)retrieveLastPaymentInfoDetails;



+(void)saveFirstName:(NSString*)name;
+(NSString*)retrieveFirstName;
+(void)saveLastName:(NSString*)name;
+(NSString*)retrieveLastName;

//ok, so I need to add spots serverside and check if spots are free

/*
+(NSString*)retrieveShadowLastFourDigits;
+(NSString*)retrieveShadowLicensePlate;
 */
@end
