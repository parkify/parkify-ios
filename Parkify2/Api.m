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
#import "problemSpotViewController.h"
#import "ParkifyAppDelegate.h"
#import "ExtraTypes.h"

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
    NSString *urlstring = [Api apirootstring];
    
    urlstring = [urlstring stringByAppendingFormat:@"users.json"];
    
    
    
    NSURL *url = [NSURL URLWithString:urlstring];
    
    
    
    

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
                [Api registerUserWithCurrentDevice];
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
    StripeConnection* stripeConnection = [StripeConnection connectionWithPublishableKey:kStripeToken];
    
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
    NSString *urlstring = [Api apirootstring];
    
    urlstring = [urlstring stringByAppendingFormat:@"account/add_card.json?&auth_token=%@", authToken];
    
    
    
    NSURL *url = [NSURL URLWithString:urlstring];
    
    
    


    
    
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
    
    NSString *urlstring = [Api apirootstring];
    
    urlstring = [urlstring stringByAppendingFormat:@"users/sign_in.json"];
    
    
    
    NSURL *url = [NSURL URLWithString:urlstring];
    


    
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
            [[Mixpanel sharedInstance] identify:[NSString stringWithFormat:@"%@_%@", [Persistance retrieveFirstName], [Persistance retrieveLastName]]];
            [[Mixpanel sharedInstance] registerSuperPropertiesOnce:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[Persistance retrieveUserID], [Persistance retrieveFirstName],[Persistance retrieveLastName], nil] forKeys:[NSArray arrayWithObjects:@"userid",@"firstname",@"lastname", nil]]];
            [[Mixpanel sharedInstance] track:@"loggedin"];
            [Crittercism leaveBreadcrumb:@"loggedin"];
            successBlock(root);
        } else {
            [[Mixpanel sharedInstance] track:@"loginerror" properties:root];
            [Crittercism leaveBreadcrumb:@"loginerror"];

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
    [[Mixpanel sharedInstance] track:@"AuthenticateModally"];
    [Crittercism leaveBreadcrumb:@"AuthenticateModally"];
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
    
    NSString *urlstring = [Api apirootstring];
    
    urlstring = [urlstring stringByAppendingFormat:@"resources.json/%d.json?level_of_detail=%@",spotID, lod];
    
    
    
    NSURL *url = [NSURL URLWithString:urlstring];

    
    
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
    
    
    
    NSString *urlstring = [Api apirootstring];
    
    urlstring = [urlstring stringByAppendingFormat:@"resources.json?level_of_detail=%@", lod];
    
    
    
    NSURL *url = [NSURL URLWithString:urlstring];
    
    

    
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
    NSString *urlstring = [Api apirootstring];
    
    urlstring = [urlstring stringByAppendingFormat:@"account.json?&auth_token=%@", authToken];
    
    
    
    NSURL *url = [NSURL URLWithString:urlstring];
    
    
    
    
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
    NSString *urlstring = [Api apirootstring];
    
    urlstring = [urlstring stringByAppendingFormat:@"account/account.json?&auth_token=%@", authToken];
    
    
    
    NSURL *url = [NSURL URLWithString:urlstring];
    
    

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
    NSString *urlstring = [Api apirootstring];
    
    urlstring = [urlstring stringByAppendingFormat:@"account/activate_card.json?&auth_token=%@", authToken];
    
    
    
    NSURL *url = [NSURL URLWithString:urlstring];
    
    
    
    
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
    NSString *urlstring = [Api apirootstring];
    
    urlstring = [urlstring stringByAppendingFormat:@"account/add_car.json?&auth_token=%@", authToken];
    
    
    
    NSURL *url = [NSURL URLWithString:urlstring];
    
    

    
    
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
    NSString *urlstring = [Api apirootstring];
    
    urlstring = [urlstring stringByAppendingFormat:@"account/add_promo.json?&auth_token=%@", authToken];
    
    
    
    NSURL *url = [NSURL URLWithString:urlstring];
    
    


    
    
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
    NSString *urlstring = [Api apirootstring];
    
    urlstring = [urlstring stringByAppendingFormat:@"account/update_cars.json?&auth_token=%@", authToken];
    
    
    
    NSURL *url = [NSURL URLWithString:urlstring];
    


    
    
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
    NSString *urlstring = [Api apirootstring];
    
    urlstring = [urlstring stringByAppendingFormat:@"account/update_password.json?&auth_token=%@", authToken];
    
    
    
    NSURL *url = [NSURL URLWithString:urlstring];
    
  
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
    NSString *urlstring = [Api apirootstring];
    
    urlstring = [urlstring stringByAppendingFormat:@"account/reset_password.json"];

    
    
    NSURL *url = [NSURL URLWithString:urlstring];
  
  
  
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


#pragma mark Gaurav functions start here

#pragma mark AWS methods
+ (void)processGrandCentralDispatchUpload:(NSData *)imageData withImageName:(NSString*)imageName
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY] ;
    
    // Create the picture bucket.
    S3CreateBucketRequest *createBucketRequest = [[S3CreateBucketRequest alloc] initWithName:PICTURE_BUCKET] ;
    S3CreateBucketResponse *createBucketResponse = [s3 createBucket:createBucketRequest];
    if(createBucketResponse.error != nil)
    {
        NSLog(@"Error: %@", createBucketResponse.error);
    }

    dispatch_async(queue, ^{
        
        // Upload image data.  Remember to set the content type.
        S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:imageName
                                                                  inBucket:PICTURE_BUCKET] ;
        por.contentType = @"image/jpeg";
        por.data        = imageData;
        por.cannedACL = [S3CannedACL publicRead];
        // Put the image data into the specified s3 bucket and object.
        S3PutObjectResponse *putObjectResponse = [s3 putObject:por];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(putObjectResponse.error != nil)
            {
                NSLog(@"Error: %@", putObjectResponse.error);
                
                //[self showAlertMessage:[putObjectResponse.error.userInfo objectForKey:@"message"] withTitle:@"Upload Error"];
            }
            else
            {
                NSLog(@"Image successfully uploaded");
                NSLog(@"putobject respones %@", putObjectResponse.request.JSONRepresentation);
                
//                [self showAlertMessage:@"The image was successfully uploaded." withTitle:@"Upload Completed"];
            }
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}
#pragma mark methods dealing with problem spots
+ (void)sendProblemSpotWithText:(NSString *)problem
                       andImage:(UIImage*)problemImage
                  andResourceID:(int)spotid
                        withLat:(double)latitude
                        andLong:(double)longitude
               withAcceptanceID:(int)acceptid
                    shouldCancel:(BOOL)shouldCancel
            withASIHTTPDelegate:(id)delegate
{
    NSString *urlstring = [Api apirootstring];
    
    urlstring = [urlstring stringByAppendingFormat:@"complaints.json?auth_token=%@", [Persistance retrieveAuthToken]];

    NSURL *url = [NSURL URLWithString:urlstring];
    NSString *filename = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    if ( [Persistance retrieveAuthToken]){
        filename= [filename stringByAppendingFormat:@"_%@_%@", [Persistance retrieveFirstName],[Persistance retrieveLastName]];
    }
       
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.yyyy_HH:mm:ss"];
    NSString *imageurl = @"";
    
    
    if(problemImage){
    filename = [filename stringByAppendingFormat:@"_%@.png",[dateFormatter stringFromDate:[NSDate date]]];
   [Api processGrandCentralDispatchUpload:[NSData dataWithData:UIImagePNGRepresentation(problemImage)] withImageName:filename];
    NSLog(@"Logging new problem with text: %@", problem);
    imageurl = [NSString stringWithFormat:@"https://s3.amazonaws.com/%@/%@",PICTURE_BUCKET, filename];
    NSLog(@"The url is %@", imageurl);
    }
    
    NSDictionary *complaints = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:spotid-90000], problem, imageurl, [NSNumber numberWithDouble:latitude], [NSNumber numberWithDouble:longitude], nil] forKeys:[NSArray arrayWithObjects:@"resource_offer_id",@"descriptions", @"imageurl", @"latitude",@"longitude", nil]];

    ParkifyAppDelegate *appdelegate = (ParkifyAppDelegate*)[[UIApplication sharedApplication] delegate];
    [[appdelegate.transactions objectForKey:@"active"] removeObjectForKey:[NSString stringWithFormat:@"%i", spotid]];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];

    [request addPostValue:[complaints JSONRepresentation] forKey:@"complaint"];
    [request addPostValue:[NSNumber numberWithInt:acceptid] forKey:@"acceptanceid"];
    [request addPostValue:[NSString stringWithFormat:@"%@", shouldCancel ? @"1" : @"0"] forKey:@"shouldCancel"];
    [request addRequestHeader:@"User-Agent" value:@"ASIFormDataRequest"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    request.delegate=delegate;
      
    [request startAsynchronous];

}
+ (void)logout{
    [[Mixpanel sharedInstance] track:@"logout"];
    
    [Persistance saveAuthToken:nil];
    [Persistance saveUserID:[NSNumber numberWithInt:-1]];
    ParkifyAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    delegate.transactions=nil;
    

}

+(void) tryTransacation:(NSObject *)spotinfo withStartTime:(double)minimumValue andEndTime:(double)maximumValue withASIdelegate:(id)asidelegate isPreview:(BOOL)preview withExtraParameter:(NSString*)parameter
{
    
    ParkingSpot *spot = (ParkingSpot*)spotinfo;
    [[Mixpanel sharedInstance] track:@"transactionpreview"];
    NSMutableArray* offerIds = [[NSMutableArray alloc] init];
    for (Offer* offer in spot.offers) {

        if ([offer overlapsWithStartTime:minimumValue endTime:maximumValue])
            [offerIds addObject:[NSNumber numberWithInt:offer.mId]];
    }
    
    id transactionRequest = [Authentication makeTransactionRequestWithUserToken:[Persistance retrieveAuthToken] withSpotId:spot.mID withStartTime:minimumValue withEndTime:maximumValue withOfferIds:offerIds withLicensePlate:[Persistance retrieveLicensePlateNumber]];
    
    NSString *urlstring = [Api apirootstring];

    if(preview)
        urlstring = [urlstring stringByAppendingFormat:@"acceptances/preview.json?auth_token=%@%@", [Persistance retrieveAuthToken], parameter];

    else
        urlstring = [urlstring stringByAppendingFormat:@"acceptances.json?auth_token=%@%@", [Persistance retrieveAuthToken], parameter];

    NSURL *url = [NSURL URLWithString:urlstring];
    
    NSLog(@"%@", [transactionRequest JSONRepresentation]);
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addPostValue:[transactionRequest JSONRepresentation] forKey:@"transaction"];
    
    [request addRequestHeader:@"User-Agent" value:@"ASIFormDataRequest"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request  setRequestMethod:@"POST"];
    [request setDelegate:asidelegate];
    if(preview)
        request.tag= kPreviewTransaction;
    else
        request.tag=kAttempTransaction;
    
    [request startAsynchronous];
    
}

+ (void)registerUDIDandToken:(NSString*)tokenAsString withASIdelegate:(id)asidelegate{
    NSString *udid = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    NSString *urlstring = [Api apirootstring];
    urlstring = [urlstring stringByAppendingFormat:@"devices.json"];
    if ([Persistance retrieveAuthToken] != nil) {
        urlstring = [urlstring stringByAppendingFormat:@"?auth_token=%@", [Persistance retrieveAuthToken]];
        
    }

    NSURL *url = [NSURL URLWithString:urlstring];
    NSLog(@"URL is %@",urlstring );
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSLog(@"Device is %@", [[UIDevice currentDevice] model]);
//    [request addPostValue:[userRequest JSONRepresentation] forKey:@"user"];
    [request addPostValue:[[UIDevice currentDevice] model] forKey:@"devicetype"];
    [request addPostValue:udid forKey:@"device_uid"];
    [request addPostValue:tokenAsString forKey:@"push_token_id"];
    request.tag = kLoadUDIDandPush;
    [request addRequestHeader:@"User-Agent" value:@"ASIFormDataRequest"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setDelegate:asidelegate];
    [request startAsynchronous];
    
    
/*    [request setCompletionBlock:^{
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
    */

}
+(void)registerUserWithCurrentDevice{
    NSString *udid = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    NSString *urlstring = [Api apirootstring];
    urlstring = [urlstring stringByAppendingFormat:@"device_users.json"];

    if ([Persistance retrieveAuthToken] != nil) {
        urlstring = [urlstring stringByAppendingFormat:@"?auth_token=%@", [Persistance retrieveAuthToken]];
        
    }
    else{
        NSLog(@"Attempting to register without logging in!");
        return;
    }
    
    NSURL *url = [NSURL URLWithString:urlstring];
    NSLog(@"URL is %@",urlstring );
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSLog(@"Device is %@", [[UIDevice currentDevice] model]);
    //    [request addPostValue:[userRequest JSONRepresentation] forKey:@"user"];
    [request addPostValue:[[UIDevice currentDevice] model] forKey:@"devicetype"];
    [request addPostValue:udid forKey:@"device_uid"];
    request.tag = kLoadUDIDandPush;
    [request addRequestHeader:@"User-Agent" value:@"ASIFormDataRequest"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setCompletionBlock:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        NSString *responseString = [request responseString];
        NSDictionary * root = [responseString JSONValue];
        BOOL success = [[root objectForKey:@"success"] boolValue];
        
        if(success) {
            NSLog(@"Successfully created device user record %@", responseString);
        
        } else {
            NSError* error = [ErrorTransformer apiErrorToNSError:[root objectForKey:@"error"]];
        }
    }];
    
    [request setFailedBlock:^{
    }];

    [request startAsynchronous];

}
+(void)getListOfCurrentAcceptances:(id)asidelegate{
    if ( ![Persistance retrieveAuthToken])
        return;
    NSString *urlstring = [Api apirootstring];
    urlstring = [urlstring stringByAppendingFormat:@"app_transactions.json"];
    urlstring = [urlstring stringByAppendingFormat:@"?auth_token=%@", [Persistance retrieveAuthToken]];
    NSURL *url = [NSURL URLWithString:urlstring];
    NSLog(@"URL is %@",urlstring );
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSLog(@"Device is %@", [[UIDevice currentDevice] model]);
    //    [request addPostValue:[userRequest JSONRepresentation] forKey:@"user"];
    request.tag = kGetAcceptances;
    [request addRequestHeader:@"User-Agent" value:@"ASIFormDataRequest"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setRequestMethod:@"GET"];
    [request setDelegate:asidelegate];
    [request startAsynchronous];

}
+(NSString *)apirootstring{
#ifdef DEBUGVER
    NSString *sslorno = @"http";
    
#else
    NSString *sslorno = @"https";
#endif
    NSString *urlstring = [NSString stringWithFormat:@"%@://%@/api/%@/", sslorno,TARGET_SERVER, APIVER];
    return urlstring;
    
}
@end


