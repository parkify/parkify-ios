//
//  Persistance.m
//  Parkify2
//
//  Created by Me on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "Persistance.h"
#import "ParkifyAppDelegate.h"
#import "Acceptance.h"  
@interface  Persistance()
+ (void) saveUserRecord:(id)record withName:(NSString*)name;
+ (id) retrieveUserRecordwithName:(NSString*)name;
+ (void) saveRecord:(id)record withName:(NSString*)name;
+ (id) retrieveRecordwithName:(NSString*)name;
+ (void) saveUserPlist:(id)record withName:(NSString *)name;
+ (id) retrievePlistWithName:(NSString *)name;

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

+(void)saveUserID:(NSNumber*)user {
    [Persistance saveRecord:user withName:@"CurrentUser"];
}
+(NSNumber*)retrieveUserID {
    NSNumber* toRtn = [Persistance retrieveRecordwithName:@"CurrentUser"];
    return toRtn;
}

+ (void) saveUserPlist:(id)record withName:(NSString *)name{
    if ( ![Persistance retrieveUserID])
        return;

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", [Persistance retrieveUserID], name]];
    BOOL saved= [NSKeyedArchiver archiveRootObject:record toFile:writableDBPath];
    NSLog(@"did save object with name %@, %d", name, saved);

}
+ (id) retrievePlistWithName:(NSString *)name{
    if ( ![Persistance retrieveUserID])
        return nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", [Persistance retrieveUserID], name]];
    
    
    NSFileManager *fmang = [NSFileManager defaultManager];
    if ([fmang isReadableFileAtPath:writableDBPath]){
        return [NSKeyedUnarchiver unarchiveObjectWithFile:writableDBPath];
    }
    return nil;
}

+ (void) saveUserRecord:(id)record withName:(NSString*)name {
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        NSNumber* currentUser = [Persistance retrieveUserID];
        currentUser = (currentUser != nil) ? currentUser : [NSNumber numberWithInt:-1];
        
        NSDictionary* toStore = [NSDictionary dictionaryWithObjectsAndKeys:record, [NSString stringWithFormat:@"%@", currentUser ], nil];
        [standardUserDefaults setObject:[toStore copy] forKey:name];
        [standardUserDefaults synchronize]; } 
}
+ (id) retrieveUserRecordwithName:(NSString*)name {
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber* currentUser = [Persistance retrieveUserID];
    currentUser = (currentUser != nil) ? currentUser : [NSNumber numberWithInt:-1];
    
    id val = nil;
    if (standardUserDefaults)
        val = [standardUserDefaults objectForKey:name];
    if (val)
        val = [val objectForKey:[NSString stringWithFormat:@"%@", currentUser ]];
    return val;
}


+(void)saveVersion:(NSString*)version {
    [Persistance saveRecord:version withName:@"Version"];
}
+(NSString*)retrieveVersion {
    return [Persistance retrieveRecordwithName:@"Version"];
}

//TODO: manage compatability across versions instead of erase on every update.

+(void)updatePersistedDataWithAppVersion {
    NSString* thisVersion = [Persistance retrieveVersion];
    if(thisVersion && [thisVersion isEqualToString:APP_VERSION]) {
        return;
    } else {
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        
        [Persistance saveVersion:APP_VERSION];
    }
    
}


//Deprecated
+(void)saveUser:(NSDictionary*)user { 
    [Persistance saveUserRecord:user withName:@"User"];
}
//Deprecated
+(NSDictionary*)retrieveUser { 
    return [Persistance retrieveUserRecordwithName:@"User"];
}


+(void)saveAuthToken:(NSString*)token {
    if(token == nil) {
        [Persistance saveRefreshTransactions:true];
    }
    [Persistance saveUserRecord:token withName:@"AuthToken"];
}
+(NSString*)retrieveAuthToken { 
    return [Persistance retrieveUserRecordwithName:@"AuthToken"];
}


+(void)saveLicensePlateNumber:(NSString*)lpn {
    [Persistance saveUserRecord:lpn withName:@"LicensePlateNumber"];
}
+(NSString*)retrieveLicensePlateNumber {
    return [Persistance retrieveUserRecordwithName:@"LicensePlateNumber"];
}

+(void)saveLastFourDigits:(NSString*)lfd {
    [Persistance saveUserRecord:lfd withName:@"LastFourDigits"];
}
+(NSString*)retrieveLastFourDigits {
    return [Persistance retrieveUserRecordwithName:@"LastFourDigits"];

}

+(void)saveLastAmountCharged:(double)lac {
    [Persistance saveUserRecord:[NSNumber numberWithDouble:lac] withName:@"LastAmountCharged"];
}
+(double)retrieveLastAmountCharged {
    return [[Persistance retrieveUserRecordwithName:@"LastAmountCharged"] doubleValue];
}

+(void)saveLastPaymentInfoDetails:(NSString*)lpid {
    [Persistance saveUserRecord:lpid withName:@"LastPaymentInfoDetails"];
}
+(NSString*)retrieveLastPaymentInfoDetails {
    return [Persistance retrieveUserRecordwithName:@"LastPaymentInfoDetails"];
}

+(void)saveFirstName:(NSString*)name {
    [Persistance saveUserRecord:name withName:@"FirstName"];
}
+(NSString*)retrieveFirstName {
    return [Persistance retrieveUserRecordwithName:@"FirstName"];
}
+(void)saveLastName:(NSString*)name {
    [Persistance saveUserRecord:name withName:@"LastName"];
}
+(NSString*)retrieveLastName {
    return [Persistance retrieveUserRecordwithName:@"LastName"];
}


+(Acceptance*)addNewTransaction:(ParkingSpot*)spot withStartTime:(double)timeIn andEndTime:(double)timeOut andLastPaymentDetails:(NSString*)details withTransactionID:(NSString*)acceptanceid
{
    NSMutableDictionary *newTransaction = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:spot.actualID], details, [NSNumber numberWithDouble:timeIn],[NSNumber numberWithDouble:timeOut],@"1",spot.offers, acceptanceid, nil] forKeys:[NSArray arrayWithObjects:@"spotid",@"lastpayment", @"starttime",@"endtime",@"active" ,@"offers",@"acceptanceid", nil]];
    Acceptance *newAcceptance = [[Acceptance alloc] init:newTransaction];
    
    ParkifyAppDelegate *delegate = (ParkifyAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSLog(@"Saving transaciton %@", newTransaction);
    [[delegate.transactions objectForKey:@"active"] setValue:newAcceptance forKey:acceptanceid];
    [[delegate.transactions objectForKey:@"all"] setValue:newAcceptance forKey:acceptanceid];

    /*
     [[delegate.transactions objectForKey:@"active"] setValue:newTransaction forKey:[NSString stringWithFormat:@"%i", spot.actualID]];
    [[delegate.transactions objectForKey:@"all"] setValue:newTransaction forKey:[NSString stringWithFormat:@"%i", spot.actualID]];
     */
    NSLog(@"Saving transaction %@", newTransaction);
    [Persistance saveUserPlist:delegate.transactions withName:@"transactionarray"];
//    [Persistance saveUserRecord:delegate.transactions withName:@"transactionarray"];
    return newAcceptance;
}
+(NSDictionary*)retrieveTransactions{
    return [Persistance retrievePlistWithName:@"transactionarray"];
//    return [Persistance retrieveUserRecordwithName:@"transactionarray"];
}
+(void)saveCurrentSpotId:(int)spotId{
    if (spotId == -1) {
        [Persistance saveUserRecord:nil withName:@"CurrentSpotId"];
    } else {
        [Persistance saveUserRecord:[NSNumber numberWithInt:spotId] withName:@"CurrentSpotId"];
    }
}

+(int)retrieveCurrentSpotId {
    return [[Persistance retrieveUserRecordwithName:@"CurrentSpotId"] intValue];
}



+(void)saveCurrentStartTime:(double)timeIn {
    if (timeIn == -1) {
        [Persistance saveUserRecord:nil withName:@"CurrentStartTime"];
    } else {
        [Persistance saveUserRecord:[NSNumber numberWithDouble:timeIn] withName:@"CurrentStartTime"];
    }
}
+(double)retrieveCurrentStartTime {
    return [[Persistance retrieveUserRecordwithName:@"CurrentStartTime"] doubleValue];
}

+(void)saveCurrentEndTime:(double)timeIn {
    if (timeIn == -1) {
        [Persistance saveUserRecord:nil withName:@"CurrentEndTime"];
    } else {
        [Persistance saveUserRecord:[NSNumber numberWithDouble:timeIn] withName:@"CurrentEndTime"];
    }
}
/*+(double)retrieveCurrentEndTime {
    return [[Persistance retrieveUserRecordwithName:@"CurrentEndTime"] doubleValue];
}*/


+(void)saveDemoDict:(NSMutableDictionary*)dict {
    [Persistance saveRecord:dict withName:@"DemoDict"];
}
+(NSMutableDictionary*)retrieveDemoDict {
    id toRtn = [[Persistance retrieveRecordwithName:@"DemoDict"] mutableCopy];
    if (toRtn) return toRtn;
    return [[NSMutableDictionary alloc] init];
}

+(void)saveRefreshTransactions:(BOOL)needsRefresh {
    [Persistance saveRecord:[NSNumber numberWithBool:needsRefresh] withName:@"RefreshTransactions"];

}
+(BOOL)retrieveRefreshTransactions {
    NSNumber* toRtn = [Persistance retrieveRecordwithName:@"RefreshTransactions"];
    if (!toRtn) return true;
    return [toRtn boolValue];
}


+(void)saveCurrentSpot:(ParkingSpot*)spot {
    if (spot) {
        [Persistance saveUserRecord:[spot asDictionary] withName:@"CurrentSpot"];
    } else {
        [Persistance saveUserRecord:nil withName:@"CurrentSpot"];
    }
}

+(ParkingSpot*)retrieveCurrentSpot {
    if([Persistance retrieveUserRecordwithName:@"CurrentSpot"]) {
        ParkingSpot* toRtn = [[ParkingSpot alloc] init];
        [toRtn updateFromDictionary:[Persistance retrieveUserRecordwithName:@"CurrentSpot"] withLevelOfDetail:@"all"];
        return toRtn;
    } else {
        return nil;
    }
}

@end
