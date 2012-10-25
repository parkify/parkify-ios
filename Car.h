//
//  Car.h
//  Parkify
//
//  Created by Me on 10/25/12.
//
//

#import <Foundation/Foundation.h>
#import "ExtraTypes.h"

@interface Car : NSObject

@property int mId;

@property (strong, nonatomic) NSString* license_plate_number;



- (void)updateFromDictionary:(NSDictionary*)dictIn;

- (void)pushToServerWithSuccess:(SuccessBlock)successBlock
         withFailure:(FailureBlock)failureBlock;

- (void)pushChangesToServerWithSuccess:(SuccessBlock)successBlock
                withFailure:(FailureBlock)failureBlock;

@end
