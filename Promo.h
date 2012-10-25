//
//  Promo.h
//  Parkify
//
//  Created by Me on 10/25/12.
//
//

#import <Foundation/Foundation.h>
#import "ExtraTypes.h"

@interface Promo : NSObject

@property (strong, nonatomic) NSString* code_text;

@property (strong, nonatomic) NSString* description;

- (void)updateFromDictionary:(NSDictionary*)dictIn;

- (void)pushToServerWithSuccess:(SuccessBlock)successBlock
         withFailure:(FailureBlock)failureBlock;

- (void)pushChangesToServerWithSuccess:(SuccessBlock)successBlock
                withFailure:(FailureBlock)failureBlock;

@end