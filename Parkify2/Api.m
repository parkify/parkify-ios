//
//  Api.m
//  Parkify2
//
//  Created by Me on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Api.h"
#import "Stripe.h"
#import "SBJson.h"
#import "ASIFormDataRequest.h"
#import "ASIDownloadCache.h"
#import "Authentication.h"
#import "ModalSettingsController.h"
#import "Persistance.h"
#import "iToast.h"
#import "ParkifyWebViewWrapperController.h"

#define TESTING_V1 true

@interface Api()
+ (void)signUpStripeSuccessWithCard:(NSString*)token
                          withEmail:(NSString*)email 
                       withPassword:(NSString*)password
           withPasswordConfirmation:(NSString*)passwordConfirmation
                      withFirstName:(NSString*)firstName
                       withLastName:(NSString*)lastName
                   withLicensePlate:(NSString*)licensePlate
                        withZipCode:(NSString*)zipCode
                          withPhone:(NSString*)phone
                        withSuccess:(SuccessBlock)successBlock
                        withFailure:(FailureBlock)failureBlock;
@end

@implementation Api

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
            withFailure:(FailureBlock)failureBlock {
    
    
    StripeCard *card      = [[StripeCard alloc] init];
    card.number           = ccn;
    card.expiryMonth      = expMonth;
    card.expiryYear       = expYear;
    //card.name         = self.nameField.text;
    card.securityCode = cvc;
    card.addressZip = zipCode;
    
    
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    StripeConnection* stripeConnection = [StripeConnection connectionWithPublishableKey:@"pk_XeTF5KrqXMeSyyqApBF4q9qDzniMn"];
    
    [stripeConnection performRequestWithCard:card 
                                     success:^(StripeResponse *response) 
     {
         NSLog(@"STRIPE SUCCESS!");
         [self signUpStripeSuccessWithCard:response.token
                                 withEmail:email
                              withPassword:password
                  withPasswordConfirmation:passwordConfirmation     
                             withFirstName:firstName 
                              withLastName:lastName
                          withLicensePlate:licensePlate
                               withZipCode:zipCode
                                 withPhone:phone
                               withSuccess:successBlock
                               withFailure:failureBlock];
     }
                                       error:^(NSError *error) 
     {
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         
         failureBlock(error);
         /*
         if ([error.domain isEqualToString:@"Stripe"]) {
             // Handle stipe error here 
             NSDictionary* result = [NSDictionary dictionaryWithObjectsAndKeys: [error.userInfo objectForKey:@"message"], nil
             self.errorLabel = [error.userInfo objectForKey:@"message"];             
         } else {
             // Handle network error here 
             NSLog(@"%@", error);
         }
          */
                                    
     }];
}




// Helper method for user registration
// (actually does the user registration after credit
// card info is accepted and converted to token)
+ (void)signUpStripeSuccessWithCard:(NSString*)token
                          withEmail:(NSString*)email 
                       withPassword:(NSString*)password
           withPasswordConfirmation:(NSString*)passwordConfirmation
                      withFirstName:(NSString*)firstName
                       withLastName:(NSString*)lastName
                   withLicensePlate:(NSString*)licensePlate
                        withZipCode:(NSString*)zipCode
                          withPhone:(NSString *)phone
                        withSuccess:(SuccessBlock)successBlock
                        withFailure:(FailureBlock)failureBlock {
    
    if(TESTING_V1) {
        
        id userRequest = [Authentication makeUserRegistrationRequest:email
                                                        withPassword:password
                                            withPasswordConfirmation:passwordConfirmation
                                                       withFirstName:firstName
                                                        withLastName:lastName
                                                         withZipCode:zipCode
                                                           withPhone:phone];
        id tokenRequest = [Authentication makeTokenRequestWithToken:token];
        
        NSURL *url = [NSURL URLWithString:@"https://parkify-rails.herokuapp.com/api/v1/users.json"];
        NSLog(@"%@", [userRequest JSONRepresentation]);
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request addPostValue:[userRequest JSONRepresentation] forKey:@"user"];
        [request addPostValue:tokenRequest forKey:@"stripe_token_id"];
        [request addPostValue:licensePlate forKey:@"license_plate_number"];
        
        [request addRequestHeader:@"User-Agent" value:@"ASIFormDataRequest"]; 
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        [request setRequestMethod:@"POST"];
        
        [request setCompletionBlock:^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            NSString *responseString = [request responseString];
            NSDictionary * root = [responseString JSONValue];
            BOOL success = [[root objectForKey:@"success"] boolValue];
            
            if(success) {
                int userID = [[[root objectForKey:@"user"] objectForKey:@"id"] intValue];
                [Persistance saveUserID:[NSNumber numberWithInt:userID]];
                [Persistance saveAuthToken:[root objectForKey:@"auth_token"]];
                [Persistance saveLicensePlateNumber:[root objectForKey:@"license_plate_number"]];
                [Persistance saveLastFourDigits:[root objectForKey:@"last_four_digits"]];
                successBlock(root);
            } else {
                NSString* message = @"";
                
                NSDictionary* errorDescription = [root objectForKey:@"error"];
                
                for( NSString* key in errorDescription.allKeys) {
                    for( NSString* val in [errorDescription objectForKey:key]) {
                        message = [NSString stringWithFormat:@"%@%@ %@\n", message, key, val] ;
                    }
                    //NSString* object = [[NSString stringWithFormat:@"%@",[errorDescription objectForKey:key]]stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                }
                
                NSDictionary* userInfo;
                if(![message isEqualToString:@""]) {
                    userInfo = [NSDictionary dictionaryWithObjectsAndKeys:message,@"message", nil];
                }
                else {
                    NSLog(@"WARNING: Error from server not handled well: %@", responseString);
                    userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"error from server not formatted correctly",@"message", nil];
                }
                NSError* error = [NSError errorWithDomain:@"UserRegistration" code:0 userInfo:userInfo];
                failureBlock(error);
            }
        }];
        
        [request setFailedBlock:^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            failureBlock([request error]);
        }];
        
        [request startAsynchronous];
        
        
    } else {
 
    id userRequest = [Authentication makeUserRegistrationRequest:email
                                                withPassword:password
                                    withPasswordConfirmation:passwordConfirmation
                                               withFirstName:firstName
                                                withLastName:lastName
                                                withLicensePlate:licensePlate];
    id tokenRequest = [Authentication makeTokenRequestWithToken:token];

    NSURL *url = [NSURL URLWithString:@"https://swooplot.herokuapp.com/api/users.json"];
    NSLog(@"%@", [userRequest JSONRepresentation]);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addPostValue:[userRequest JSONRepresentation] forKey:@"user"];
    [request addPostValue:tokenRequest forKey:@"stripe_token_id"];
    
    [request addRequestHeader:@"User-Agent" value:@"ASIFormDataRequest"]; 
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request  setRequestMethod:@"POST"];
    
    [request setCompletionBlock:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        NSString *responseString = [request responseString];
        NSDictionary * root = [responseString JSONValue];
        BOOL success = [[root objectForKey:@"success"] boolValue];
        
        if(success) {
            successBlock(root);
        } else {
            NSString* message = @"";

            NSDictionary* errorDescription = [root objectForKey:@"error"];

            for( NSString* key in errorDescription.allKeys) {
                for( NSString* val in [errorDescription objectForKey:key]) {
                    message = [NSString stringWithFormat:@"%@%@ %@\n", message, key, val] ;
                }
                //NSString* object = [[NSString stringWithFormat:@"%@",[errorDescription objectForKey:key]]stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            }
            
            NSDictionary* userInfo;
            if(![message isEqualToString:@""]) {
                userInfo = [NSDictionary dictionaryWithObjectsAndKeys:message,@"message", nil];
            }
            else {
                NSLog(@"WARNING: Error from server not handled well: %@", responseString);
                userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"error from server not formatted correctly",@"message", nil];
            }
            NSError* error = [NSError errorWithDomain:@"UserRegistration" code:0 userInfo:userInfo];
            failureBlock(error);
        }
    }];
    
    [request setFailedBlock:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        failureBlock([request error]);
    }];

    [request startAsynchronous];
    }
}


//Called for user login
+ (void)loginWithEmail:(NSString*)email
          withPassword:(NSString*)password 
           withSuccess:(SuccessBlock)successBlock
           withFailure:(FailureBlock)failureBlock  {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURL *url;
    if(TESTING_V1) {
        url = [NSURL URLWithString:@"https://parkify-rails.herokuapp.com/api/v1/users/sign_in.json"];
    } else {
        url = [NSURL URLWithString:@"https://swooplot.herokuapp.com/api/users/sign_in.json"];
    }
    //NSLog(@"%@", [userRequest JSONRepresentation]);
    
    id loginRequest = [Authentication makeUserLoginRequest:email withPassword:password];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addPostValue:[loginRequest JSONRepresentation] forKey:@"user_login"];
    [request addRequestHeader:@"User-Agent" value:@"ASIFormDataRequest"]; 
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request  setRequestMethod:@"POST"];
    
    [request setCompletionBlock:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        NSString *responseString = [request responseString];
        NSDictionary * root = [responseString JSONValue];
        BOOL success = [[root objectForKey:@"success"] boolValue];
        
        if(success) {
            
            int userID = [[[root objectForKey:@"user"] objectForKey:@"id"] intValue];
            [Persistance saveUserID:[NSNumber numberWithInt:userID]];
            
            [Persistance saveLicensePlateNumber:[root objectForKey:@"license_plate_number"]];
            [Persistance saveLastFourDigits:[root objectForKey:@"last_four_digits"]];
            successBlock(root);
        } else {
            NSString* message = @"";
            
            NSDictionary* errorDescription = [root objectForKey:@"error"];
            
            for( NSString* key in errorDescription.allKeys) {
                for( NSString* val in [errorDescription objectForKey:key]) {
                    message = [NSString stringWithFormat:@"%@%@ %@\n", message, key, val] ;
                }
                //NSString* object = [[NSString stringWithFormat:@"%@",[errorDescription objectForKey:key]]stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            }
            
            NSDictionary* userInfo;
            if(![message isEqualToString:@""]) {
                userInfo = [NSDictionary dictionaryWithObjectsAndKeys:message,@"message", nil];
            }
            else {
                NSLog(@"WARNING: Error from server not handled well: %@", responseString);
                userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"error from server not formatted correctly",@"message", nil];
            }
            NSError* error = [NSError errorWithDomain:@"UserLogin" code:0 userInfo:userInfo];
            failureBlock(error);
        }
    }];
    
    [request setFailedBlock:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        failureBlock([request error]);
    }];
        
    [request startAsynchronous];
}

+ (void)authenticateModallyFrom:(UIViewController*)parent withSuccess:(SuccessBlock)successBlock {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                             bundle: nil];
    
    ModalSettingsController* controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"AuthenticateVC"];
    controller.successBlock = successBlock;
    UIModalTransitionStyle style = parent.modalTransitionStyle;
    //parent.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [parent presentViewController:controller animated:true completion:^{}];
    parent.modalTransitionStyle = style;
}


+ (void)settingsModallyFrom:(UIViewController*)parent withSuccess:(SuccessBlock)successBlock {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                             bundle: nil];
    
    ModalSettingsController* controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"SettingsVC"];
    controller.successBlock = successBlock;
    
    UIModalTransitionStyle style = parent.modalTransitionStyle;
    //parent.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [parent presentViewController:controller animated:true completion:^{}];
    parent.modalTransitionStyle = style;
}

//Called to bring up SettingsVC modally
+ (void)webWrapperModallyFrom:(UIViewController*)parent withURL:(NSString*)url {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                             bundle: nil];
    
    ParkifyWebViewWrapperController* controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"WebWrapperVC"];
    controller.url = url;
    UIModalTransitionStyle style = parent.modalTransitionStyle;
    //parent.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [parent presentViewController:controller animated:true completion:^{}];
    parent.modalTransitionStyle = style;
}

+ (void)getParkingSpotWithID:(int)spotID
           withLevelofDetail:(NSString*)lod
                  withSuccess:(SuccessBlock)successBlock
                  withFailure:(FailureBlock)failureBlock {
    NSString* strUrl;
    if([lod isEqualToString: @"low"]) {
        strUrl = [NSString stringWithFormat:@"http://parkify-rails.herokuapp.com/api/v1/resources/%d.json?level_of_detail=%@", spotID, @"low"];
    } else {
        strUrl = [NSString stringWithFormat:@"http://parkify-rails.herokuapp.com/api/v1/resources/%d.json?level_of_detail=%@", spotID, @"all"];
    }
    
    NSURL *url = [NSURL URLWithString:strUrl];
    
    
    ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *request = _request;
    
    request.requestMethod = @"GET";
    
    [request setDelegate:self];
    [request setCompletionBlock:^{
        NSString *responseString = [request responseString];
        NSDictionary * root = [responseString JSONValue];
        successBlock(root);
    }];
    [request setFailedBlock:^{
        failureBlock([request error]);
    }];
    
    [request startAsynchronous];
    
}


+ (void)getParkingSpotsWithLevelofDetail:(NSString*)lod
                             withSuccess:(SuccessBlock)successBlock
                             withFailure:(FailureBlock)failureBlock {
    
    
    
    NSString* strUrl;
    if([lod isEqualToString: @"low"]) {
        strUrl = [NSString stringWithFormat:@"http://parkify-rails.herokuapp.com/api/v1/resources.json?level_of_detail=%@", @"low"];
    } else {
        strUrl = [NSString stringWithFormat:@"http://parkify-rails.herokuapp.com/api/v1/resources.json?level_of_detail=%@", @"all"];
    }
            
    NSURL *url = [NSURL URLWithString:strUrl];
        
    
    ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *request = _request;
    
    request.requestMethod = @"GET";
    
    [request setDelegate:self];
    [request setCompletionBlock:^{
        NSString *responseString = [request responseString];
        NSDictionary * root = [responseString JSONValue];
        successBlock(root);
    }];
    [request setFailedBlock:^{
        failureBlock([request error]);
    }];

    [request startAsynchronous];

}

//Called to get particular info from the logged in user
/*
+ (void)getUserInfo:(NSArray*)requestedInfo
                 withSuccess:(SuccessBlock)successBlock
                 withFailure:(FailureBlock)failureBlock {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURL *url;
    if(TESTING_V1) {
        url = [NSURL URLWithString:@"http://parkify-rails.herokuapp.com/api/v1/users/info.json"];
    } else {
        url = [NSURL URLWithString:@"http://swooplot.herokuapp.com/api/users/info.json"];
    }
    //NSLog(@"%@", [userRequest JSONRepresentation]);
    
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addPostValue:requestedInfo forKey:@"requested_info"];
    [request addPostValue:[Persistance retrieveAuthToken] forKey:@"authentication_token"];
    [request addRequestHeader:@"User-Agent" value:@"ASIFormDataRequest"]; 
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request  setRequestMethod:@"POST"];
    
    [request setCompletionBlock:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        NSString *responseString = [request responseString];
        NSDictionary * root = [responseString JSONValue];
        BOOL success = [[root objectForKey:@"success"] boolValue];
        
        if(success) {
            successBlock(root);
        } else {
            NSString* message = @"";
            
            NSDictionary* errorDescription = [root objectForKey:@"error"];
            
            for( NSString* key in errorDescription.allKeys) {
                for( NSString* val in [errorDescription objectForKey:key]) {
                    message = [NSString stringWithFormat:@"%@%@ %@\n", message, key, val] ;
                }
                //NSString* object = [[NSString stringWithFormat:@"%@",[errorDescription objectForKey:key]]stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            }
            NSDictionary* userInfo;
            if(![message isEqualToString:@""]) {
                userInfo = [NSDictionary dictionaryWithObjectsAndKeys:message,@"message", nil];
            }
            else {
                NSLog(@"WARNING: Error from server not handled well: %@", responseString);
                userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"error from server not formatted correctly",@"message", nil];
            }
            NSError* error = [NSError errorWithDomain:@"UserLogin" code:0 userInfo:userInfo];
            failureBlock(error);
        }
    }];
    
    [request setFailedBlock:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        failureBlock([request error]);
    }];
    
    [request startAsynchronous];
}
*/

//Downloads an image from the server and passes the image through
+ (void)downloadImageDataAsynchronouslyWithId:(int)imageID withStyle:(NSString*)style
                              withSuccess:(SuccessBlock)successBlock
                              withFailure:(FailureBlock)failureBlock {
    NSString* strUrl = [NSString stringWithFormat:@"http://parkify-rails.herokuapp.com/images/%d?image_attachment=true&style=%@", imageID, style];
    
    NSURL *url = [NSURL URLWithString:strUrl];
    
    
    ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *request = _request;
    
    request.requestMethod = @"GET";
    
    
    
    [request setDelegate:self];
    [request setCompletionBlock:^{
        /*NSString *responseString = [request responseString];
         NSMutableDictionary * root = [(NSDictionary*)[responseString JSONValue] mutableCopy];
         [root setObject:image forKey:@"image"];*/
        NSData* image = [request rawResponseData];
        NSMutableDictionary * root = [NSMutableDictionary dictionaryWithObject:image forKey:@"image"];
        successBlock(root);
    }];
    [request setFailedBlock:^{
        failureBlock([request error]);
    }];
    
    
    [request setDownloadCache:[ASIDownloadCache sharedCache]];
    
    [request startAsynchronous];

}

@end


