//
//  Persistance.h
//  Parkify2
//
//  Created by Me on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Persistance : NSObject
+(void)saveUser:(NSDictionary*)myString;
+(NSDictionary*)retrieveUser;
+(void)saveAuthToken:(NSString*)myString;
+(NSString*)retrieveAuthToken;
@end
