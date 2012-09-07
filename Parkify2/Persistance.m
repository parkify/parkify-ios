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


+(void)saveLicensePlateNumber:(NSString*)lpn {
    [Persistance saveRecord:lpn withName:@"LicensePlateNumber"];
}
+(NSString*)retrieveLicensePlateNumber {
    return [Persistance retrieveRecordwithName:@"LicensePlateNumber"];
}

+(void)saveLastFourDigits:(NSString*)lfd {
    [Persistance saveRecord:lfd withName:@"LastFourDigits"];
}
+(NSString*)retrieveLastFourDigits {
    return [Persistance retrieveRecordwithName:@"LastFourDigits"];

}

+(void)saveLastAmountCharged:(double)lac {
    [Persistance saveRecord:[NSNumber numberWithDouble:lac] withName:@"LastAmountCharged"];
}
+(double)retrieveLastAmountCharged {
    return [[Persistance retrieveRecordwithName:@"LastAmountCharged"] doubleValue];
}


+(void)saveCurrentSpotId:(int)spotId{
    if (spotId == -1) {
        [Persistance saveRecord:nil withName:@"CurrentSpotId"];
    } else {
        [Persistance saveRecord:[NSNumber numberWithInt:spotId] withName:@"CurrentSpotId"];
    }
}
+(int)retrieveCurrentSpotId {
    return [[Persistance retrieveRecordwithName:@"CurrentSpotId"] intValue];
}



+(void)saveCurrentStartTime:(double)timeIn {
    if (timeIn == -1) {
        [Persistance saveRecord:nil withName:@"CurrentStartTime"];
    } else {
        [Persistance saveRecord:[NSNumber numberWithDouble:timeIn] withName:@"CurrentStartTime"];
    }
}
+(double)retrieveCurrentStartTime {
    return [[Persistance retrieveRecordwithName:@"CurrentStartTime"] doubleValue];
}

+(void)saveCurrentEndTime:(double)timeIn {
    if (timeIn == -1) {
        [Persistance saveRecord:nil withName:@"CurrentEndTime"];
    } else {
        [Persistance saveRecord:[NSNumber numberWithDouble:timeIn] withName:@"CurrentEndTime"];
    }
}
+(double)retrieveCurrentEndTime {
    return [[Persistance retrieveRecordwithName:@"CurrentEndTime"] doubleValue];
}

+(void)saveCurrentSpot:(ParkingSpot*)spot {
    if (spot) {
        [Persistance saveRecord:[spot asDictionary] withName:@"CurrentSpot"];
    } else {
        [Persistance saveRecord:nil withName:@"CurrentSpot"];
    }
}

+(ParkingSpot*)retrieveCurrentSpot {
    if([Persistance retrieveRecordwithName:@"CurrentSpot"]) {
        ParkingSpot* toRtn = [[ParkingSpot alloc] init];
        [toRtn updateFromDictionary:[Persistance retrieveRecordwithName:@"CurrentSpot"] withLevelOfDetail:@"all"];
        return toRtn;
    } else {
        return nil;
    }
}

@end
