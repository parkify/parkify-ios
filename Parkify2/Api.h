//
//  Api.h
//  Parkify2
//
//  Created by Me on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExtraTypes.h"

#define NO_SERVICE_DEBUG false
#define NO_SERVICE_DEBUG_SPOTS @"[spots:({\"id\":\"3\",\"location":{\"latitude\":\"37.872654\",\"longitude\":\"-122.266812\"},\"location_name\":\"Mikes Bikes\",\"mLocalID\":\"3\",\"mPrice\":\"1.02\",\"mPhoneNumber\":\"408-421-1194\",\"mDesc\":\"A Fantastic Spot!\",\"mFree\":\"true\"})]"
#define LOW_PRICE_THRESHOLD 5.01
#define HIGH_PRICE_THRESHOLD 5.02

@interface Api : NSObject

//Called for user registration
+ (void)signUpWithEmail:(NSString*)email 
           withPassword:(NSString*)password
withPasswordConfirmation:(NSString*)passwordConfirmation
          withFirstName:(NSString*)firstName
           withLastName:(NSString*)lastName
   withCreditCardNumber:(NSString*)ccn
                withCVC:(NSString*)cvc
    withExpirationMonth:(NSNumber*)expMonth
     withExpirationYear:(NSNumber*)expYear
       withLicensePlate:(NSString*)licensePlate
            withZipCode:(NSString*)zipCode
              withPhone:(NSString*)phone
            withSuccess:(SuccessBlock)successBlock
            withFailure:(FailureBlock)failureBlock ;

//Called for user login
+ (void)loginWithEmail:(NSString*)email
          withPassword:(NSString*)password 
           withSuccess:(SuccessBlock)successBlock
           withFailure:(FailureBlock)failureBlock;

//Called to bring up AuthenticationVC modally
+ (void)authenticateModallyFrom:(UIViewController*)parent withSuccess:(SuccessBlock)successBlock;

//Called to bring up SettingsVC modally
+ (void)settingsModallyFrom:(UIViewController*)parent withSuccess:(SuccessBlock)successBlock;

//Called to bring up SettingsVC modally
+ (void)webWrapperModallyFrom:(UIViewController*)parent withURL:(NSString*)url;

+ (void)getParkingSpotWithID:(int)spotID
           withLevelofDetail:(NSString*)lod
                             withSuccess:(SuccessBlock)successBlock
                             withFailure:(FailureBlock)failureBlock;

+ (void)getParkingSpotsWithLevelofDetail:(NSString*)lod
                             withSuccess:(SuccessBlock)successBlock
                             withFailure:(FailureBlock)failureBlock;
//Called to get particular info from the logged in user
/*
+ (void)getUserInfo:(NSArray*)requestedInfo
                 withSuccess:(SuccessBlock)successBlock
                 withFailure:(FailureBlock)failureBlock;
 */

//Downloads an image from the server and passes the image through
+ (void)downloadImageDataAsynchronouslyWithId:(int)imageID withStyle:(NSString*)style
                              withSuccess:(SuccessBlock)successBlock
                              withFailure:(FailureBlock)failureBlock;


+ (void)getUserProfileWithSuccess:(SuccessBlock)successBlock
withFailure:(FailureBlock)failureBlock;

+ (void)updateUserProfileWithDict:(NSDictionary*)dicIn
                      withSuccess:(SuccessBlock)successBlock
                      withFailure:(FailureBlock)failureBlock;


@end
