//
//  CreditCard.h
//  Parkify
//
//  Created by Me on 10/25/12.
//
//

#import <Foundation/Foundation.h>

#import "ExtraTypes.h"

@interface CreditCard : NSObject

@property int mId;

@property (strong, nonatomic) NSString* credit_card_number;
@property (strong, nonatomic) NSString* exp_month;
@property (strong, nonatomic) NSString* exp_year;
@property (strong, nonatomic) NSString* cvc;
@property (strong, nonatomic) NSString* zip;

@property (strong, nonatomic) NSString* last4;

@property BOOL active;

- (id)init;

- (void)updateFromDictionary:(NSDictionary*)dictIn;

- (void)pushToServerWithSuccess:(SuccessBlock)successBlock
         withFailure:(FailureBlock)failureBlock;

- (void)pushChangesToServerWithSuccess:(SuccessBlock)successBlock
                withFailure:(FailureBlock)failureBlock;
- (NSString*) validate;
@end
