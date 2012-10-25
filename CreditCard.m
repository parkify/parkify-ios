//
//  CreditCard.m
//  Parkify
//
//  Created by Me on 10/25/12.
//
//

#import "CreditCard.h"

@implementation CreditCard

@synthesize mId = _mId;

@synthesize credit_card_number = _credit_card_number;
@synthesize exp_month = _exp_month;
@synthesize exp_year = _exp_year;
@synthesize cvc = _cvc;
@synthesize zip = _zip;
@synthesize last4 = _last4;
@synthesize active = _active;



- (void)updateFromDictionary:(NSDictionary*)dictIn {
    self.mId = [[dictIn objectForKey:@"id"] intValue];
    self.last4 = [dictIn objectForKey:@"last4"];
    self.active = [[dictIn objectForKey:@"active"] boolValue];
}

- (void)pushToServerWithSuccess:(SuccessBlock)successBlock
         withFailure:(FailureBlock)failureBlock {
    //STUB
    //todo: push to stripe, then if success, push to server, then if success, run success.
}


- (void)pushChangesToServerWithSuccess:(SuccessBlock)successBlock
                withFailure:(FailureBlock)failureBlock {
    //STUB
    //todo: just activate this card.
}

@end
