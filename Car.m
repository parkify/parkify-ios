//
//  Car.m
//  Parkify
//
//  Created by Me on 10/25/12.
//
//

#import "Car.h"
#import "Api.h"

@implementation Car

@synthesize license_plate_number = _license_plate_number;
@synthesize mId = _mId;
@synthesize state = _state;

- (id)init {
    self = [super init];
    if(self) {
        self.license_plate_number = @"";
        self.state = @"";
    }
    return self;
}

- (void)updateFromDictionary:(NSDictionary*)dictIn {
    self.mId = [[dictIn objectForKey:@"id"] intValue];
    self.license_plate_number = [dictIn objectForKey:@"license_plate_number"];
    self.state = [dictIn objectForKey:@"state"];
}

- (void)pushToServerWithSuccess:(SuccessBlock)successBlock
         withFailure:(FailureBlock)failureBlock {
    //STUB
    //todo: create new car. duh.
    [Api addCar:self.license_plate_number withState:self.state withSuccess:successBlock withFailure:failureBlock];
    
}

- (void)pushChangesToServerWithSuccess:(SuccessBlock)successBlock
                withFailure:(FailureBlock)failureBlock {
    //STUB
    //todo: just update this license plate. duh.
}

- (NSDictionary*)asDictionary {
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:self.mId], @"id", self.license_plate_number, @"license_plate_number", self.state, @"state", nil];
}

+(void) pushChangesForCars:(NSArray*)cars toServerWithSuccess:(SuccessBlock)success withFailure:(FailureBlock)failure {
    [Api udateCars:(NSArray*)cars
       withSuccess:success
       withFailure:failure];
}


- (NSString*) validate {
    return nil;
}


+(NSMutableDictionary*) licensePlateLocationDictionary {
    NSMutableDictionary* toRtn = [[NSMutableDictionary alloc] init];
    [toRtn setObject: @"AL" forKey: @"Alabama"];
    [toRtn setObject: @"AK" forKey: @"Alaska"];
    [toRtn setObject: @"AZ" forKey: @"Arizona"];
    [toRtn setObject: @"AR" forKey: @"Arkansas"];
    [toRtn setObject: @"CA" forKey: @"California"];
    [toRtn setObject: @"CO" forKey: @"Colorado"];
    [toRtn setObject: @"CT" forKey: @"Connecticut"];
    [toRtn setObject: @"DE" forKey: @"Delaware"];
    [toRtn setObject: @"DC" forKey: @"District of Columbia"];
    [toRtn setObject: @"FL" forKey: @"Florida"];
    [toRtn setObject: @"GA" forKey: @"Georgia"];
    [toRtn setObject: @"HI" forKey: @"Hawaii"];
    [toRtn setObject: @"ID" forKey: @"Idaho"];
    [toRtn setObject: @"IL" forKey: @"Illinois"];
    [toRtn setObject: @"IN" forKey: @"Indiana"];
    [toRtn setObject: @"IA" forKey: @"Iowa"];
    [toRtn setObject: @"KS" forKey: @"Kansas"];
    [toRtn setObject: @"KY" forKey: @"Kentucky"];
    [toRtn setObject: @"LA" forKey: @"Louisiana"];
    [toRtn setObject: @"ME" forKey: @"Maine"];
    [toRtn setObject: @"MT" forKey: @"Montana"];
    [toRtn setObject: @"NE" forKey: @"Nebraska"];
    [toRtn setObject: @"NV" forKey: @"Nevada"];
    [toRtn setObject: @"NH" forKey: @"New Hampshire"];
    [toRtn setObject: @"NJ" forKey: @"New Jersey"];
    [toRtn setObject: @"NM" forKey: @"New Mexico"];
    [toRtn setObject: @"NY" forKey: @"New York"];
    [toRtn setObject: @"NC" forKey: @"North Carolina"];
    [toRtn setObject: @"ND" forKey: @"North Dakota"];
    [toRtn setObject: @"OH" forKey: @"Ohio"];
    [toRtn setObject: @"OK" forKey: @"Oklahoma"];
    [toRtn setObject: @"OR" forKey: @"Oregon"];
    [toRtn setObject: @"MD" forKey: @"Maryland"];
    [toRtn setObject: @"MA" forKey: @"Massachusetts"];
    [toRtn setObject: @"MI" forKey: @"Michigan"];
    [toRtn setObject: @"MN" forKey: @"Minnesota"];
    [toRtn setObject: @"MS" forKey: @"Mississippi"];
    [toRtn setObject: @"MO" forKey: @"Missouri"];
    [toRtn setObject: @"PA" forKey: @"Pennsylvania"];
    [toRtn setObject: @"RI" forKey: @"Rhode Island"];
    [toRtn setObject: @"SC" forKey: @"South Carolina"];
    [toRtn setObject: @"SD" forKey: @"South Dakota"];
    [toRtn setObject: @"TN" forKey: @"Tennessee"];
    [toRtn setObject: @"TX" forKey: @"Texas"];
    [toRtn setObject: @"UT" forKey: @"Utah"];
    [toRtn setObject: @"VT" forKey: @"Vermont"];
    [toRtn setObject: @"VA" forKey: @"Virginia"];
    [toRtn setObject: @"WA" forKey: @"Washington"];
    [toRtn setObject: @"WV" forKey: @"West  Virginia"];
    [toRtn setObject: @"WI" forKey: @"Wisconsin"];
    [toRtn setObject: @"WY" forKey: @"Wyoming"];
    
    return toRtn;
}

+(NSMutableArray*) licensePlateLocationOrder {
    NSMutableArray* toRtn = [[NSMutableArray alloc] init];
    [toRtn addObject: @"Alabama"];
    [toRtn addObject: @"Alaska"];
    [toRtn addObject: @"Arizona"];
    [toRtn addObject: @"Arkansas"];
    [toRtn addObject: @"California"];
    [toRtn addObject: @"Colorado"];
    [toRtn addObject: @"Connecticut"];
    [toRtn addObject: @"Delaware"];
    [toRtn addObject: @"District of Columbia"];
    [toRtn addObject: @"Florida"];
    [toRtn addObject: @"Georgia"];
    [toRtn addObject: @"Hawaii"];
    [toRtn addObject: @"Idaho"];
    [toRtn addObject: @"Illinois"];
    [toRtn addObject: @"Indiana"];
    [toRtn addObject: @"Iowa"];
    [toRtn addObject: @"Kansas"];
    [toRtn addObject: @"Kentucky"];
    [toRtn addObject: @"Louisiana"];
    [toRtn addObject: @"Maine"];
    [toRtn addObject: @"Montana"];
    [toRtn addObject: @"Nebraska"];
    [toRtn addObject: @"Nevada"];
    [toRtn addObject: @"New Hampshire"];
    [toRtn addObject: @"New Jersey"];
    [toRtn addObject: @"New Mexico"];
    [toRtn addObject: @"New York"];
    [toRtn addObject: @"North Carolina"];
    [toRtn addObject: @"North Dakota"];
    [toRtn addObject: @"Ohio"];
    [toRtn addObject: @"Oklahoma"];
    [toRtn addObject: @"Oregon"];
    [toRtn addObject: @"Maryland"];
    [toRtn addObject: @"Massachusetts"];
    [toRtn addObject: @"Michigan"];
    [toRtn addObject: @"Minnesota"];
    [toRtn addObject: @"Mississippi"];
    [toRtn addObject: @"Missouri"];
    [toRtn addObject: @"Pennsylvania"];
    [toRtn addObject: @"Rhode Island"];
    [toRtn addObject: @"South Carolina"];
    [toRtn addObject: @"South Dakota"];
    [toRtn addObject: @"Tennessee"];
    [toRtn addObject: @"Texas"];
    [toRtn addObject: @"Utah"];
    [toRtn addObject: @"Vermont"];
    [toRtn addObject: @"Virginia"];
    [toRtn addObject: @"Washington"];
    [toRtn addObject: @"West Virginia"];
    [toRtn addObject: @"Wisconsin"];
    [toRtn addObject: @"Wyoming"];
    
    return toRtn;
}



@end