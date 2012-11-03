//
//  ErrorTransformer.h
//  Parkify
//
//  Created by Me on 11/3/12.
//
//

#import <Foundation/Foundation.h>

#define API_ERROR_DOMAIN @"ParkifyApi"

@interface ErrorTransformer : NSObject

+(NSError*) apiErrorToNSError:(NSDictionary*)errors;
+(void) errorToAlert:(NSError*)error withDelegate:(id)delegate;

@end
