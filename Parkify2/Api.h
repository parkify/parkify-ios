//
//  Api.h
//  Parkify2
//
//  Created by Me on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExtraTypes.h"


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
            withSuccess:(SuccessBlock)successBlock
            withFailure:(FailureBlock)failureBlock ;

//Called for user login
+ (void)loginWithEmail:(NSString*)email
          withPassword:(NSString*)password 
           withSuccess:(SuccessBlock)successBlock
           withFailure:(FailureBlock)failureBlock;

//Called to bring up AuthenticationVC modally
+ (void)authenticateModallyFrom:(UIViewController*)parent withSuccess:(SuccessBlock)successBlock;


@end
