//
//  Promo.m
//  Parkify
//
//  Created by Me on 10/25/12.
//
//

#import "Promo.h"
#import "Api.h"

@implementation Promo

@synthesize description = _description;
@synthesize code_text = _code_text;
@synthesize mId = _mId;
@synthesize name = _name;

- (id)init {
    self = [super init];
    if(self) {
        self.description = @"";
        self.name = @"";
        self.code_text = @"";
    }
    return self;
}


- (void)updateFromDictionary:(NSDictionary*)dictIn {
    self.description = [dictIn objectForKey:@"description"];
    self.code_text = [dictIn objectForKey:@"code_text"];
    self.mId = [[dictIn objectForKey:@"id"] intValue];
    self.name = [dictIn objectForKey:@"name"];
}

- (void)pushToServerWithSuccess:(SuccessBlock)successBlock
         withFailure:(FailureBlock)failureBlock {
    
    [Api addPromo:self.code_text withSuccess:successBlock withFailure:failureBlock];
    //STUB
    //todo: try to register this promo. duh.
}

- (void)pushChangesToServerWithSuccess:(SuccessBlock)successBlock
                withFailure:(FailureBlock)failureBlock {
    //STUB
    //todo: not much to do here. duh.
}

@end