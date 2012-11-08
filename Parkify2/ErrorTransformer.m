//
//  ErrorTransformer.m
//  Parkify
//
//  Created by Me on 11/3/12.
//
//

#import "ErrorTransformer.h"
#import "ExtraTypes.h"
@implementation ErrorTransformer

+(NSError*) apiErrorToNSError:(NSDictionary*)errors {
    NSString* message = @"";
    
    
    //only take the first one.
    
    if(errors.count == 0) {
        message = @"An unknown error occurred. Please contact us at 1-855-Parkify for assistance.";
    } else {
    
        id firstKey = [errors.allKeys objectAtIndex:0];
        
        id firstValue = [errors objectForKey:firstKey];
        
        Class c = [firstValue class];
        /*
        firstValue = [firstValue stringByTrimmingCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
        message = [NSString stringWithFormat:@"%@ %@", firstKey, firstValue];              
        */
        while(true) {
            if([c isSubclassOfClass:[NSString class]]) {
                message = [NSString stringWithFormat:@"%@ %@", firstKey, firstValue];
                break;
            } else if([c isSubclassOfClass:[NSMutableDictionary class]] && ((NSMutableDictionary*)firstValue).count != 0) {
                firstValue = [firstValue objectForKey:[((NSMutableDictionary*)firstValue).allKeys objectAtIndex:0]];
                c = [firstValue class];
            } else if([c isSubclassOfClass:[NSMutableArray class]] && ((NSMutableArray*)firstValue).count != 0) {
                firstValue = [((NSMutableArray*)firstValue) objectAtIndex:0];
                c = [firstValue class];
            } else {
                message = @"An unknown error occurred. Please contact us at 1-855-Parkify for assistance.";
                break;
            }
        }
            /*
            
             }
         */
    
        
                  
    }
    
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:message,@"message", nil];
    
    return [NSError errorWithDomain:API_ERROR_DOMAIN code:0 userInfo:userInfo];
}

+(void) errorToAlert:(NSError*)error withDelegate:(id)delegate {
    
    UIAlertView* alert;
    if([error.userInfo count] == 0) {
        alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"" delegate:delegate cancelButtonTitle:@"Ok"
                                 otherButtonTitles: nil];
    } else if([error.userInfo objectForKey:@"message"]) {
        NSString* messageString = [error.userInfo objectForKey:@"message"];
        alert = [[UIAlertView alloc] initWithTitle:@"Error" message:messageString delegate:delegate cancelButtonTitle:@"Ok"
                                 otherButtonTitles: nil];
    }
    else {
        id firstKey = [[error.userInfo allKeys] objectAtIndex:0];
        NSString* messageString = [error.userInfo objectForKey:firstKey];
        alert = [[UIAlertView alloc] initWithTitle:@"Error" message:messageString delegate:delegate cancelButtonTitle:@"Ok"
                                 otherButtonTitles: nil];

        
    }
    alert.tag =kGenericErrorAlertTag;
    [alert show];
}

@end
