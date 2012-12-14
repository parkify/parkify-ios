//
//  Api.h
//  Parkify2
//
//  Created by Me on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExtraTypes.h"
#import "ASIFormDataRequest.h"
#import "UIDevice+IdentifierAddition.h"
#define NO_SERVICE_DEBUG false
#define NO_SERVICE_DEBUG_SPOTS @"[spots:({\"id\":\"3\",\"location":{\"latitude\":\"37.872654\",\"longitude\":\"-122.266812\"},\"location_name\":\"Mikes Bikes\",\"mLocalID\":\"3\",\"mPrice\":\"1.02\",\"mPhoneNumber\":\"408-421-1194\",\"mDesc\":\"A Fantastic Spot!\",\"mFree\":\"true\"})]"
#define LOW_PRICE_THRESHOLD 5.01
#define HIGH_PRICE_THRESHOLD 5.02
#define kProblemAlertView 9929
#define ACCESS_KEY_ID          @"AKIAI2S3XWTFZUBVAIRA"
#define SECRET_KEY             @"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"


// Constants for the Bucket and Object name.
#define PICTURE_BUCKET         @"parkify-primages"


#define CREDENTIALS_ERROR_TITLE    @"Missing Credentials"
#define CREDENTIALS_ERROR_MESSAGE  @"AWS Credentials not configured correctly.  Please review the README file."
#import <AWSiOSSDK/S3/AmazonS3Client.h>

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

//Called for card creation
+ (void)registerCardWithCreditCardNumber:(NSString*)ccn
                withCVC:(NSString*)cvc
    withExpirationMonth:(NSNumber*)expMonth
     withExpirationYear:(NSNumber*)expYear
            withZipCode:(NSString*)zipCode
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
+ (void)activateCard:(int)mId
         withSuccess:(SuccessBlock)successBlock
         withFailure:(FailureBlock)failureBlock;

+ (void)udateCars:(NSArray*)cars
      withSuccess:(SuccessBlock)successBlock
      withFailure:(FailureBlock)failureBlock;

+ (void)addCar:(NSString*)license_plate_number
   withSuccess:(SuccessBlock)successBlock
   withFailure:(FailureBlock)failureBlock;

+ (void)addPromo:(NSString*)code_text
     withSuccess:(SuccessBlock)successBlock
     withFailure:(FailureBlock)failureBlock;

+ (void)updatePassword:(NSString*)password
  passwordConfirmation:(NSString*)passwordConf
          origPassword:(NSString*)origPassword
           withSuccess:(SuccessBlock)successBlock
           withFailure:(FailureBlock)failureBlock;

+ (void)resetPasswordWithEmail:(NSString*)email
          withSuccess:(SuccessBlock)successBlock
          withFailure:(FailureBlock)failureBlock;

#pragma mark startGauravMethods

+ (void)sendProblemSpotWithText:(NSString *)problem
                       andImage:(UIImage*)problemImage
                  andResourceID:(int)spotid
                        withLat:(double)latitude
                        andLong:(double)longitude
               withAcceptanceID:(int)acceptid
                   shouldCancel:(BOOL)shouldCancel

            withASIHTTPDelegate:(id)delegate;

+(void) tryTransacation:(NSObject *)spotinfo withStartTime:(double)minimumValue andEndTime:(double)maximumValue withASIdelegate:(id)asidelegate isPreview:(BOOL)preview withExtraParameter:(NSString*)parameter;
+ (void)registerUDIDandToken:(NSString*)tokenAsString withASIdelegate:(id)asidelegate;
+ (void)logout;
+(void)registerUserWithCurrentDevice;

+(void)getListOfCurrentAcceptances:(id)asidelegate;

@end
