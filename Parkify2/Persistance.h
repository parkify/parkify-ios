//
//  Persistance.h
//  Parkify2
//
//  Created by Me on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Persistance : NSObject
+(void)saveUser:(NSDictionary*)user;
+(NSDictionary*)retrieveUser;
+(void)saveAuthToken:(NSString*)token;
+(NSString*)retrieveAuthToken;

/*
+(NSString*)retrieveShadowLastFourDigits;
+(NSString*)retrieveShadowLicensePlate;
 */
@end
