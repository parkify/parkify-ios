//
//  Authentication.m
//  Parkify2
//
//  Created by Me on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Authentication.h"
#import "Persistance.h"

@implementation Authentication
+ (id)makeUserRegistrationRequest:(NSString *)email withPassword:(NSString *)password withPasswordConfirmation:(NSString *)passwordConfirmation withFirstName:(NSString *)firstName withLastName:(NSString*)lastName withLicensePlate:(NSString*)licensePlate {
    NSDictionary *request =  [NSDictionary dictionaryWithObjectsAndKeys:
                              email, @"email", 
                              password, @"password", 
                              passwordConfirmation, @"password_confirmation",
                              firstName, @"first_name",
                              lastName, @"last_name",
                              licensePlate, @"license_plate",
                              nil];
    return request;
}
+ (id)makeUserRegistrationRequest:(NSString *)email withPassword:(NSString *)password withPasswordConfirmation:(NSString *)passwordConfirmation withFirstName:(NSString *)firstName withLastName:(NSString*)lastName withZipCode:(NSString*)zipCode withPhone:(NSString*)phone{
    NSDictionary *request =  [NSDictionary dictionaryWithObjectsAndKeys:
                              email, @"email", 
                              password, @"password", 
                              passwordConfirmation, @"password_confirmation",
                              firstName, @"first_name",
                              lastName, @"last_name",
                              zipCode, @"zip_code",
                              phone, @"phone_number",
                              nil];
    return request;
}

+ (id) makeTokenRequestWithToken:(NSString*)token {
    return token;
}

+ (id) makeTransactionRequestWithUserToken:(NSString*)token withSpotId:(int)spotID withStartTime:(double)startTime withEndTime:(double)endTime withOfferIds:(NSArray*)offerIds withLicensePlate:(NSString*)licensePlate {
    NSDictionary *request =  [NSDictionary dictionaryWithObjectsAndKeys:
                              token, @"authentication_token",
                              [[NSNumber alloc] initWithInt:spotID], @"parking_spot_id", 
                              [[NSNumber alloc] initWithDouble:startTime], @"start_time",
                              [[NSNumber alloc] initWithDouble:endTime], @"end_time",
                              offerIds, @"offer_ids",
                              licensePlate, @"license_plate_number",
                              nil];
        return request;
}

+ (id) makeUserLoginRequest:(NSString *)email withPassword:(NSString *)password {
    NSDictionary *request =  [NSDictionary dictionaryWithObjectsAndKeys:
                              email, @"email",
                              password, @"password", nil];
    return request;
}



@end
