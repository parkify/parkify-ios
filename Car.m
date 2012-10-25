//
//  Car.m
//  Parkify
//
//  Created by Me on 10/25/12.
//
//

#import "Car.h"

@implementation Car

@synthesize license_plate_number = _license_plate_number;
@synthesize mId = _mId;

- (void)updateFromDictionary:(NSDictionary*)dictIn {
    self.mId = [[dictIn objectForKey:@"id"] intValue];
    self.license_plate_number = [dictIn objectForKey:@"license_plate_number"];
}

- (void)pushToServerWithSuccess:(SuccessBlock)successBlock
         withFailure:(FailureBlock)failureBlock {
    //STUB
    //todo: create new car. duh.
}

- (void)pushChangesToServerWithSuccess:(SuccessBlock)successBlock
                withFailure:(FailureBlock)failureBlock {
    //STUB
    //todo: just update this license plate. duh.
}

@end