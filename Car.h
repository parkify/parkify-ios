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
@property (strong, nonatomic) NSString* state;

- (id)init;

- (NSDictionary*)asDictionary;

- (void)updateFromDictionary:(NSDictionary*)dictIn;

- (void)pushToServerWithSuccess:(SuccessBlock)successBlock
         withFailure:(FailureBlock)failureBlock;

- (void)pushChangesToServerWithSuccess:(SuccessBlock)successBlock
                withFailure:(FailureBlock)failureBlock;

+(void) pushChangesForCars:(NSArray*)cars toServerWithSuccess:(SuccessBlock)success withFailure:(FailureBlock)failure;

+(NSMutableDictionary*) licensePlateLocationDictionary;
+(NSMutableArray*) licensePlateLocationOrder;
- (NSString*) validate;
@end
