//
//  User.h
//  Parkify
//
//  Created by Me on 10/25/12.
//
//

#import <Foundation/Foundation.h>

#import "ExtraTypes.h"

@interface User : NSObject<CreditCardsSource, CarSource, PromoSource>

@property (strong, nonatomic) NSString* first_name;
@property (strong, nonatomic) NSString* last_name;
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* password; //only used for creating new user
@property (strong, nonatomic) NSString* phone_number;

@property double credit; //in cents

@property (strong, nonatomic) NSArray* credit_cards;
@property (strong, nonatomic) NSArray* cars;
@property (strong, nonatomic) NSArray* promos;



- (void)updateFromDictionary:(NSDictionary*)dictIn;

- (void)updateFromServerWithSuccess:(SuccessBlock)successBlock
             withFailure:(FailureBlock)failureBlock;

- (void)pushToServerWithSuccess:(SuccessBlock)successBlock
         withFailure:(FailureBlock)failureBlock;

- (void)pushChangesToServerWithSuccess:(SuccessBlock)successBlock
                withFailure:(FailureBlock)failureBlock;

@end
