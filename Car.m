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

- (id)init {
    self = [super init];
    if(self) {
        self.license_plate_number = @"";
    }
    return self;
}

- (void)updateFromDictionary:(NSDictionary*)dictIn {
    self.mId = [[dictIn objectForKey:@"id"] intValue];
    self.license_plate_number = [dictIn objectForKey:@"license_plate_number"];
}

- (void)pushToServerWithSuccess:(SuccessBlock)successBlock
         withFailure:(FailureBlock)failureBlock {
    //STUB
    //todo: create new car. duh.
    [Api addCar:self.license_plate_number withSuccess:successBlock withFailure:failureBlock];
    
}

- (void)pushChangesToServerWithSuccess:(SuccessBlock)successBlock
                withFailure:(FailureBlock)failureBlock {
    //STUB
    //todo: just update this license plate. duh.
}

- (NSDictionary*)asDictionary {
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:self.mId], @"id", self.license_plate_number, @"license_plate_number", nil];
}

+(void) pushChangesForCars:(NSArray*)cars toServerWithSuccess:(SuccessBlock)success withFailure:(FailureBlock)failure {
    [Api udateCars:(NSArray*)cars
       withSuccess:success
       withFailure:failure];
}

@end