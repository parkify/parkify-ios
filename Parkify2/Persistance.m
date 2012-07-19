//
//  Persistance.m
//  Parkify2
//
//  Created by Me on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Persistance.h"

@implementation Persistance

+(void)saveUser:(NSDictionary*)myString { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) { 
        [standardUserDefaults setObject:myString forKey:@"User"]; 
        [standardUserDefaults synchronize]; }
}
+(NSDictionary*)retrieveUser { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* val = nil;
    if (standardUserDefaults) val = [standardUserDefaults objectForKey:@"User"];
    return val; 
}

+(void)saveAuthToken:(NSString*)myString { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) { 
        [standardUserDefaults setObject:myString forKey:@"User"]; 
        [standardUserDefaults synchronize]; }
}
+(NSString*)retrieveAuthToken { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString* val = nil;
    if (standardUserDefaults) val = [standardUserDefaults objectForKey:@"User"];
    return val; 
}

@end
