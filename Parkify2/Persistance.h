//
//  Persistance.h
//  Parkify2
//
//  Created by Me on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParkingSpot.h"
#import "Acceptance.h"
@interface Persistance : NSObject

+(Acceptance*)addNewTransaction:(ParkingSpot*)spot withStartTime:(double)timeIn andEndTime:(double)timeOut andLastPaymentDetails:(NSString*)details withTransactionID:(NSString*)acceptanceid withNeedsPayment:(double)needsPayment withPayBy:(double)payBy;
+(NSDictionary*)retrieveTransactions;
+(void)saveUserID:(NSNumber*)user;
+(NSNumber*)retrieveUserID;
+(void)saveAuthToken:(NSString*)token;
+(NSString*)retrieveAuthToken;

+(void)updatePersistedDataWithAppVersion;

+(void)saveGotPastDemo:(BOOL)gpd;
+(BOOL)retrieveGotPastDemo;


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

+(void)saveDemoDict:(NSMutableDictionary*)dict;
+(NSMutableDictionary*)retrieveDemoDict;

+(void)saveRefreshTransactions:(BOOL)needsRefresh;
+(BOOL)retrieveRefreshTransactions;


+(void)saveFirstName:(NSString*)name;
+(NSString*)retrieveFirstName;
+(void)saveLastName:(NSString*)name;
+(NSString*)retrieveLastName;


+(void)saveFirstUse:(NSString*)firstUse;

+(NSString*)retrieveFirstUse;


//ok, so I need to add spots serverside and check if spots are free

/*
+(NSString*)retrieveShadowLastFourDigits;
+(NSString*)retrieveShadowLicensePlate;
 */
@end
