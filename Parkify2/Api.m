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
#import "Authentication.h"
#import "ModalSettingsController.h"

@interface Api()
+ (void)signUpStripeSuccessWithCard:(NSString*)token
                          withEmail:(NSString*)email 
                       withPassword:(NSString*)password
           withPasswordConfirmation:(NSString*)passwordConfirmation
                      withFirstName:(NSString*)firstName
                       withLastName:(NSString*)lastName
                   withLicensePlate:(NSString*)licensePlate
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
            withSuccess:(SuccessBlock)successBlock
            withFailure:(FailureBlock)failureBlock {
    
    
    StripeCard *card      = [[StripeCard alloc] init];
    card.number           = ccn;
    card.expiryMonth      = expMonth;
    card.expiryYear       = expYear;
    //card.name         = self.nameField.text;
    card.securityCode = cvc;
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    StripeConnection* stripeConnection = [StripeConnection connectionWithPublishableKey:@"pk_GP95lUPyExWOy8e81qL5vIbwMH7G8"];
    
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
                        withSuccess:(SuccessBlock)successBlock
                        withFailure:(FailureBlock)failureBlock {

    id userRequest = [Authentication makeUserRegistrationRequest:email
                                                withPassword:password
                                    withPasswordConfirmation:passwordConfirmation
                                               withFirstName:firstName
                                                withLastName:lastName
                                                withLicensePlate:licensePlate];
    id tokenRequest = [Authentication makeTokenRequestWithToken:token];

    NSURL *url = [NSURL URLWithString:@"http://swooplot.herokuapp.com/api/users.json"];
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


//Called for user login
+ (void)loginWithEmail:(NSString*)email
          withPassword:(NSString*)password 
           withSuccess:(SuccessBlock)successBlock
           withFailure:(FailureBlock)failureBlock  {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURL *url = [NSURL URLWithString:@"http://swooplot.herokuapp.com/api/users/sign_in.json"];
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
    [parent presentViewController:controller animated:true completion:^{}];
}

@end


