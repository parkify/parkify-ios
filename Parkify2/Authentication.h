//
//  Authentication.h
//  Parkify2
//
//  Created by Me on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Authentication : NSObject
+ (id)makeUserRegistrationRequest:(NSString *)email withPassword:(NSString *)password withPasswordConfirmation:(NSString *)passwordConfirmation withFirstName:(NSString *)firstName withLastName:(NSString*)lastName withLicensePlate:(NSString*)licensePlate;

+ (id)makeUserRegistrationRequest:(NSString *)email withPassword:(NSString *)password withPasswordConfirmation:(NSString *)passwordConfirmation withFirstName:(NSString *)firstName withLastName:(NSString*)lastName withZipCode:(NSString*)zipCode withPhone:(NSString*)withPhone;

+ (id) makeTokenRequestWithToken:(NSString*)token;

+ (id) makeTransactionRequestWithUserToken:(NSString*)token withSpotId:(int)spotID withStartTime:(double)startTime withEndTime:(double)endTime withOfferIds:(NSArray*)offerIds withLicensePlate:(NSString*)licensePlate withPriceType:(NSString*)priceType withFlatRateName:(NSString*)flatRateName;

+ (id) makeUserLoginRequest:(NSString *)email withPassword:(NSString *)password;

@end
