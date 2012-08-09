//
//  Persistance.m
//  Parkify2
//
//  Created by Me on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "Persistance.h"

@interface  Persistance()
+ (void) saveRecord:(id)record withName:(NSString*)name;
+ (id) retrieveRecordwithName:(NSString*)name;

@end

@implementation Persistance

+ (void) saveRecord:(id)record withName:(NSString*)name {
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) { 
        [standardUserDefaults setObject:record forKey:name]; 
        [standardUserDefaults synchronize]; } 
}
+ (id) retrieveRecordwithName:(NSString*)name {
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    id val = nil;
    if (standardUserDefaults) val = [standardUserDefaults objectForKey:name];
    return val; 
}


+(void)saveUser:(NSDictionary*)user { 
    [Persistance saveRecord:user withName:@"User"];
}
+(NSDictionary*)retrieveUser { 
    return [Persistance retrieveRecordwithName:@"User"];
}



+(void)saveAuthToken:(NSString*)token { 
    [Persistance saveRecord:token withName:@"AuthToken"];
}
+(NSString*)retrieveAuthToken { 
    return [Persistance retrieveRecordwithName:@"AuthToken"];
}

/*
+(void)saveShadowLastFourDigits:(NSString*)token { 
    [Persistance saveRecord:token withName:@"ShadowLastFourDigits"];
}
+(NSString*)retrieveShadowLastFourDigits { 
    return [Persistance retrieveRecordwithName:@"ShadowLastFourDigits"];
}


+(NSString*)retrieve {
    
}
+(NSString*)retrieveShadowLicensePlate;
*/
@end
