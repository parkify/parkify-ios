//
//  Promo.m
//  Parkify
//
//  Created by Me on 10/25/12.
//
//

#import "Promo.h"

@implementation Promo

@synthesize description = _description;
@synthesize code_text = _code_text;


- (void)updateFromDictionary:(NSDictionary*)dictIn {
    self.description = [dictIn objectForKey:@"description"];
    self.code_text = [dictIn objectForKey:@"code_text"];
}

- (void)pushToServerWithSuccess:(SuccessBlock)successBlock
         withFailure:(FailureBlock)failureBlock {
    //STUB
    //todo: try to register this promo. duh.
}

- (void)pushChangesToServerWithSuccess:(SuccessBlock)successBlock
                withFailure:(FailureBlock)failureBlock {
    //STUB
    //todo: not much to do here. duh.
}

@end