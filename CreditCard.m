//
//  CreditCard.m
//  Parkify
//
//  Created by Me on 10/25/12.
//
//

#import "CreditCard.h"
#import "Api.h"

@implementation CreditCard

@synthesize mId = _mId;

@synthesize credit_card_number = _credit_card_number;
@synthesize exp_month = _exp_month;
@synthesize exp_year = _exp_year;
@synthesize cvc = _cvc;
@synthesize zip = _zip;
@synthesize last4 = _last4;
@synthesize active = _active;


- (id)init {
    self = [super init];
    if(self) {
        self.credit_card_number = @"";
        self.exp_month = @"";
        self.exp_year = @"";
        self.cvc = @"";
        self.last4 = @"";
    }
    return self;
}

- (void)updateFromDictionary:(NSDictionary*)dictIn {
    self.mId = [[dictIn objectForKey:@"id"] intValue];
    self.last4 = [dictIn objectForKey:@"last4"];
    self.active = [[dictIn objectForKey:@"active"] boolValue];
}

- (void)pushToServerWithSuccess:(SuccessBlock)successBlock
         withFailure:(FailureBlock)failureBlock {
    //STUB
    //todo: push to stripe, then if success, push to server, then if success, run success.
    
    [Api registerCardWithCreditCardNumber:self.credit_card_number
                                  withCVC:self.cvc
                      withExpirationMonth:[NSNumber numberWithInteger:[self.exp_month integerValue] ]
                       withExpirationYear:[NSNumber numberWithInteger:[self.exp_year integerValue] ]
                              withZipCode:self.zip
                              withSuccess:^(NSDictionary* d){
                                  [self updateFromDictionary:[d objectForKey:@"card"]];
                                  successBlock(d);
                              }
                              withFailure:failureBlock];
}

- (void)pushChangesToServerWithSuccess:(SuccessBlock)successBlock
                withFailure:(FailureBlock)failureBlock {
    //STUB
    //todo: just activate this card.
    [Api activateCard:self.mId withSuccess:^(NSDictionary * d) {
      //[self updateFromDictionary:[d objectForKey:@"card"]];
         successBlock(d);
    } withFailure:failureBlock];
    
}

-(NSString*)debugDescription {
  return [NSString stringWithFormat:@"<CreditCard | last4:%@, active:%@>", self.last4, self.active ? @"true" : @"false"];
}


@end
