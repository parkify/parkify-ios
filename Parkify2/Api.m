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
#import "ErrorTransformer.h"

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
    
    
        id userRequest = [Authentication makeUserRegistrationRequest:email
                                                        withPassword:password
                                            withPasswordConfirmation:passwordConfirmation
                                                       withFirstName:firstName
                                                        withLastName:lastName
                                                         withZipCode:zipCode
                                                           withPhone:phone];
        id tokenRequest = [Authentication makeTokenRequestWithToken:token];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/api/v1/users.json", TARGET_SERVER]];
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
                [Persistance saveFirstName:[[root objectForKey:@"user"] objectForKey:@"first_name"]];
                [Persistance saveLastName:[[root objectForKey:@"user"] objectForKey:@"last_name"]];
                
                successBlock(root);
            } else {
                NSError* error = [ErrorTransformer apiErrorToNSError:[root objectForKey:@"error"]];
                failureBlock(error);
            }
        }];
        
        [request setFailedBlock:^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            failureBlock([request error]);
        }];
        
        [request startAsynchronous];
        
}


//Called for card creation
+ (void)registerCardWithCreditCardNumber:(NSString*)ccn
                                 withCVC:(NSString*)cvc
                     withExpirationMonth:(NSNumber*)expMonth
                      withExpirationYear:(NSNumber*)expYear
                             withZipCode:(NSString*)zipCode
                             withSuccess:(SuccessBlock)successBlock
                             withFailure:(FailureBlock)failureBlock  {
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
         [self registerCardStripeSuccessWithCard:response.token
                               withSuccess:successBlock
                               withFailure:failureBlock];
     }
                                       error:^(NSError *error)
     {
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         
         failureBlock(error);
     }];
}


// Helper method for card registration
+ (void)registerCardStripeSuccessWithCard:(NSString*)token
                        withSuccess:(SuccessBlock)successBlock
                        withFailure:(FailureBlock)failureBlock {
    
    NSString* authToken = [Persistance retrieveAuthToken];
    if(!authToken) {
        //NSError* error = [[NSError errorWithDomain:@"Auth" code:0 userInfo:[NSDictionary dictionaryWithObject: forKey:]]]
        //TODO: GIVE BETTER ERROR
        failureBlock(nil);
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/api/v1/account/add_card.json?&auth_token=%@", TARGET_SERVER, authToken]];
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    id tokenRequest = [Authentication makeTokenRequestWithToken:token];
    [request addPostValue:tokenRequest forKey:@"stripe_token_id"];
    
    [request addRequestHeader:@"User-Agent" value:@"ASIFormDataRequest"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    
    [request setCompletionBlock:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        NSString *responseString = [request responseString];
        NSDictionary * root = [responseString JSONValue];
        BOOL success = [[root objectForKey:@"success"] boolValue];
        
        if(success) {
            successBlock(root);
        } else {
            NSError* error = [ErrorTransformer apiErrorToNSError:[root objectForKey:@"error"]];
            failureBlock(error);
        }
    }];
    
    [request setFailedBlock:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        failureBlock([request error]);
    }];
    
    [request startAsynchronous];
    
}

//Called for user login
+ (void)loginWithEmail:(NSString*)email
          withPassword:(NSString*)password
           withSuccess:(SuccessBlock)successBlock
           withFailure:(FailureBlock)failureBlock  {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURL *url;
    url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/api/v1/users/sign_in.json", TARGET_SERVER]];
    
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
          
            [Persistance saveAuthToken:[root objectForKey:@"auth_token"]];
            [Persistance saveLicensePlateNumber:[root objectForKey:@"license_plate_number"]];
            [Persistance saveLastFourDigits:[root objectForKey:@"last_four_digits"]];
            [Persistance saveFirstName:[[root objectForKey:@"user"] objectForKey:@"first_name"]];
            [Persistance saveLastName:[[root objectForKey:@"user"] objectForKey:@"last_name"]];
            successBlock(root);
        } else {
            NSError* error = [ErrorTransformer apiErrorToNSError:[root objectForKey:@"error"]];
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
        
        strUrl = [NSString stringWithFormat:@"http://%@/api/v1/resources/%d.json?level_of_detail=%@", TARGET_SERVER, spotID, @"low"];
    } else {
        strUrl = [NSString stringWithFormat:@"http://%@/api/v1/resources/%d.json?level_of_detail=%@", TARGET_SERVER, spotID, @"all"];
    }
    
    NSURL *url = [NSURL URLWithString:strUrl];
    
    
    ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *request = _request;
    
    request.requestMethod = @"GET";
    
    [request setDelegate:self];
    [request setCompletionBlock:^{
        NSString *responseString = [request responseString];
        NSDictionary * root = [responseString JSONValue];
        if([[root objectForKey:@"success"] boolValue]) {
            successBlock(root);
        } else {
            NSError* error = [ErrorTransformer apiErrorToNSError:[root objectForKey:@"error"]];
            failureBlock(error);
        }
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
        strUrl = [NSString stringWithFormat:@"http://%@/api/v1/resources.json?level_of_detail=%@",TARGET_SERVER, @"low"];
    } else {
        strUrl = [NSString stringWithFormat:@"http://%@/api/v1/resources.json?level_of_detail=%@", TARGET_SERVER, @"all"];
    }
            
    NSURL *url = [NSURL URLWithString:strUrl];
        
    
    ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *request = _request;
    
    request.requestMethod = @"GET";
    
    [request setDelegate:self];
    [request setCompletionBlock:^{
        NSString *responseString = [request responseString];
        NSDictionary * root = [responseString JSONValue];
        if([[root objectForKey:@"success"] boolValue]) {
            successBlock(root);
        } else {
            NSError* error = [ErrorTransformer apiErrorToNSError:[root objectForKey:@"error"]];
            failureBlock(error);
        }
    }];
    [request setFailedBlock:^{
        failureBlock([request error]);
    }];

    [request startAsynchronous];

}


//Downloads an image from the server and passes the image through
+ (void)downloadImageDataAsynchronouslyWithId:(int)imageID withStyle:(NSString*)style
                              withSuccess:(SuccessBlock)successBlock
                              withFailure:(FailureBlock)failureBlock {
                                  
    NSString* strUrl = [NSString stringWithFormat:@"http://%@/images/%d?image_attachment=true&style=%@", TARGET_SERVER, imageID, style];
    
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
        if(root.count != 0) {
            successBlock(root);
        } else {
            failureBlock(nil);
        }
    }];
    [request setFailedBlock:^{
        failureBlock([request error]);
    }];
    
    
    [request setDownloadCache:[ASIDownloadCache sharedCache]];
    
    [request startAsynchronous];

}


+ (void)getUserProfileWithSuccess:(SuccessBlock)successBlock
                      withFailure:(FailureBlock)failureBlock {
    
    NSString* authToken = [Persistance retrieveAuthToken];
    if(!authToken) {
        //NSError* error = [[NSError errorWithDomain:@"Auth" code:0 userInfo:[NSDictionary dictionaryWithObject:<#(id)#> forKey:<#(id<NSCopying>)#>]]]
        //TODO: GIVE BETTER ERROR
        failureBlock(nil);
        return;
    }
    NSString* strUrl = [NSString stringWithFormat:@"https://%@/api/v1/account.json?&auth_token=%@", TARGET_SERVER, authToken];
    
    NSURL *url = [NSURL URLWithString:strUrl];
    
    
    ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *request = _request;
    
    request.requestMethod = @"GET";
    
    [request setDelegate:self];
    [request setCompletionBlock:^{
        NSString *responseString = [request responseString];
        NSDictionary * root = [responseString JSONValue];
        if([[root objectForKey:@"success"] boolValue]) {
            successBlock([root objectForKey:@"user"]);
        } else {
            NSError* error = [ErrorTransformer apiErrorToNSError:[root objectForKey:@"error"]];
            failureBlock(error);
        }
    }];
    [request setFailedBlock:^{
        failureBlock([request error]);
    }];
    
    [request startAsynchronous];
    
}

+ (void)updateUserProfileWithDict:(NSDictionary*)dicIn
                      withSuccess:(SuccessBlock)successBlock
                      withFailure:(FailureBlock)failureBlock {
    NSString* authToken = [Persistance retrieveAuthToken];
    if(!authToken) {
        //NSError* error = [[NSError errorWithDomain:@"Auth" code:0 userInfo:[NSDictionary dictionaryWithObject:<#(id)#> forKey:<#(id<NSCopying>)#>]]]
        //TODO: GIVE BETTER ERROR
        failureBlock(nil);
        return;
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/api/v1/account.json?&auth_token=%@", TARGET_SERVER, authToken]];
    NSLog(@"%@", [dicIn JSONRepresentation]);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addPostValue:[dicIn JSONRepresentation] forKey:@"user"];
    [request addRequestHeader:@"User-Agent" value:@"ASIFormDataRequest"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setRequestMethod:@"PUT"];
    
    [request setCompletionBlock:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        NSString *responseString = [request responseString];
        NSDictionary * root = [responseString JSONValue];
        BOOL success = [[root objectForKey:@"success"] boolValue];
        
        if(success) {
            successBlock([root objectForKey:@"user"]);
        } else {
            NSError* error = [ErrorTransformer apiErrorToNSError:[root objectForKey:@"error"]];
            failureBlock(error);
        }
    }];
    
    [request setFailedBlock:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        failureBlock([request error]);
    }];
    
    [request startAsynchronous];
    
}


+ (void)activateCard:(int)mId
                      withSuccess:(SuccessBlock)successBlock
                      withFailure:(FailureBlock)failureBlock {
    NSString* authToken = [Persistance retrieveAuthToken];
    if(!authToken) {
        //NSError* error = [[NSError errorWithDomain:@"Auth" code:0 userInfo:[NSDictionary dictionaryWithObject:<#(id)#> forKey:<#(id<NSCopying>)#>]]]
        //TODO: GIVE BETTER ERROR
        NSError* error = [ErrorTransformer apiErrorToNSError:[NSDictionary dictionaryWithObject:@"should be logged in" forKey:@"user"]];
        failureBlock(error);
        return;
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/api/v1/account/activate_card.json?&auth_token=%@", TARGET_SERVER, authToken]];
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addPostValue:[NSString stringWithFormat:@"%d",mId] forKey:@"id"];
    [request addRequestHeader:@"User-Agent" value:@"ASIFormDataRequest"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    
    [request setCompletionBlock:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        NSString *responseString = [request responseString];
        NSDictionary * root = [responseString JSONValue];
        BOOL success = [[root objectForKey:@"success"] boolValue];
        
        if(success) {
            successBlock([root objectForKey:@"user"]);
        } else {
            NSError* error = [ErrorTransformer apiErrorToNSError:[root objectForKey:@"error"]];
            failureBlock(error);        }
    }];
    
    [request setFailedBlock:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        failureBlock([request error]);
    }];
    
    [request startAsynchronous];
    
}

+ (void)addCar:(NSString*)license_plate_number
         withSuccess:(SuccessBlock)successBlock
         withFailure:(FailureBlock)failureBlock {
    NSString* authToken = [Persistance retrieveAuthToken];
    if(!authToken) {
        //NSError* error = [[NSError errorWithDomain:@"Auth" code:0 userInfo:[NSDictionary dictionaryWithObject:<#(id)#> forKey:<#(id<NSCopying>)#>]]]
        //TODO: GIVE BETTER ERROR
        failureBlock(nil);
        return;
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/api/v1/account/add_car.json?&auth_token=%@", TARGET_SERVER, authToken]];
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addPostValue:license_plate_number forKey:@"license_plate_number"];
    [request addRequestHeader:@"User-Agent" value:@"ASIFormDataRequest"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    
    [request setCompletionBlock:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        NSString *responseString = [request responseString];
        NSDictionary * root = [responseString JSONValue];
        BOOL success = [[root objectForKey:@"success"] boolValue];
        
        if(success) {
            successBlock(root);
        } else {
            NSError* error = [ErrorTransformer apiErrorToNSError:[root objectForKey:@"error"]];
            failureBlock(error);
        }
    }];
    
    [request setFailedBlock:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        failureBlock([request error]);
    }];
    
    [request startAsynchronous];
    
}


+ (void)addPromo:(NSString*)code_text
   withSuccess:(SuccessBlock)successBlock
   withFailure:(FailureBlock)failureBlock {
    NSString* authToken = [Persistance retrieveAuthToken];
    if(!authToken) {
        //NSError* error = [[NSError errorWithDomain:@"Auth" code:0 userInfo:[NSDictionary dictionaryWithObject:<#(id)#> forKey:<#(id<NSCopying>)#>]]]
        //TODO: GIVE BETTER ERROR
        failureBlock(nil);
        return;
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/api/v1/account/add_promo.json?&auth_token=%@", TARGET_SERVER, authToken]];
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addPostValue:code_text forKey:@"code_text"];
    [request addRequestHeader:@"User-Agent" value:@"ASIFormDataRequest"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    
    [request setCompletionBlock:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        NSString *responseString = [request responseString];
        NSDictionary * root = [responseString JSONValue];
        BOOL success = [[root objectForKey:@"success"] boolValue];
        
        if(success) {
            successBlock([root objectForKey:@"promo"]);
        } else {
            NSError* error = [ErrorTransformer apiErrorToNSError:[root objectForKey:@"error"]];
            failureBlock(error);
        }
    }];
    
    [request setFailedBlock:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        failureBlock([request error]);
    }];
    
    [request startAsynchronous];
    
}



+ (void)udateCars:(NSArray*)cars
         withSuccess:(SuccessBlock)successBlock
         withFailure:(FailureBlock)failureBlock {
    NSString* authToken = [Persistance retrieveAuthToken];
    if(!authToken) {
        //NSError* error = [[NSError errorWithDomain:@"Auth" code:0 userInfo:[NSDictionary dictionaryWithObject:<#(id)#> forKey:<#(id<NSCopying>)#>]]]
        //TODO: GIVE BETTER ERROR
        failureBlock(nil);
        return;
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/api/v1/account/update_cars.json?&auth_token=%@", TARGET_SERVER, authToken]];
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addPostValue:[[cars valueForKey:@"asDictionary"] JSONRepresentation] forKey:@"cars"];
    [request addRequestHeader:@"User-Agent" value:@"ASIFormDataRequest"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    
    [request setCompletionBlock:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        NSString *responseString = [request responseString];
        NSDictionary * root = [responseString JSONValue];
        BOOL success = [[root objectForKey:@"success"] boolValue];
        
        if(success) {
            successBlock([root objectForKey:@"user"]);
        } else {
            NSError* error = [ErrorTransformer apiErrorToNSError:[root objectForKey:@"error"]];
            failureBlock(error);
        }
    }];
    
    [request setFailedBlock:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        failureBlock([request error]);
    }];
    
    [request startAsynchronous];
    
}



+ (void)updatePassword:(NSString*)password
 passwordConfirmation:(NSString*)passwordConf
origPassword:(NSString*)origPassword
      withSuccess:(SuccessBlock)successBlock
      withFailure:(FailureBlock)failureBlock {
  NSString* authToken = [Persistance retrieveAuthToken];
  if(!authToken) {
    //NSError* error = [[NSError errorWithDomain:@"Auth" code:0 userInfo:[NSDictionary dictionaryWithObject:<#(id)#> forKey:<#(id<NSCopying>)#>]]]
    //TODO: GIVE BETTER ERROR
    failureBlock(nil);
    return;
  }
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/api/v1/account/update_password.json?&auth_token=%@", TARGET_SERVER, authToken]];
  
  NSDictionary* passDict = [NSDictionary dictionaryWithObjectsAndKeys:password,@"password", passwordConf, @"password_confirmation", origPassword, @"current_password", nil];
  
  ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
  [request addPostValue:[passDict JSONRepresentation] forKey:@"user"];
  [request addRequestHeader:@"User-Agent" value:@"ASIFormDataRequest"];
  [request addRequestHeader:@"Content-Type" value:@"application/json"];
  [request setRequestMethod:@"POST"];
  
  [request setCompletionBlock:^{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSString *responseString = [request responseString];
    NSDictionary * root = [responseString JSONValue];
    BOOL success = [[root objectForKey:@"success"] boolValue];
    
    if(success) {
      [Persistance saveAuthToken:[root objectForKey:@"auth_token"]];
      successBlock([root objectForKey:@"user"]);
    } else {
        NSError* error = [ErrorTransformer apiErrorToNSError:[root objectForKey:@"error"]];
        failureBlock(error);
    }
  }];
  
  [request setFailedBlock:^{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    failureBlock([request error]);
  }];
  
  [request startAsynchronous];
  
}


+ (void)resetPasswordWithEmail:(NSString*)email
           withSuccess:(SuccessBlock)successBlock
           withFailure:(FailureBlock)failureBlock {
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/api/v1/account/reset_password.json", TARGET_SERVER]];
  
  
  
  ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
  [request addPostValue:email forKey:@"email"];
  [request addRequestHeader:@"User-Agent" value:@"ASIFormDataRequest"];
  [request addRequestHeader:@"Content-Type" value:@"application/json"];
  [request setRequestMethod:@"POST"];
  
  [request setCompletionBlock:^{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSString *responseString = [request responseString];
    NSDictionary * root = [responseString JSONValue];
    BOOL success = [[root objectForKey:@"success"] boolValue];
    
    if(success) {
      successBlock(root);
    } else {
        NSError* error = [ErrorTransformer apiErrorToNSError:[root objectForKey:@"error"]];
        failureBlock(error);
    }
  }];
  
  [request setFailedBlock:^{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    failureBlock([request error]);
  }];
  
  [request startAsynchronous];
  
}


@end


