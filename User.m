//
//  User.m
//  Parkify
//
//  Created by Me on 10/25/12.
//
//

#import "User.h"
#import "CreditCard.h"
#import "Car.h"
#import "Promo.h"
#import "Api.h"

@implementation User

@synthesize first_name = _first_name;
@synthesize last_name = _last_name;
@synthesize email = _email;
@synthesize password = _password;
@synthesize phone_number = _phone_number;
@synthesize credit = _credit;
@synthesize credit_cards = _credit_cards;
@synthesize cars = _cars;
@synthesize promos = _promos;

-(NSArray*)cars {
    if(!_cars) {
        _cars = [[NSMutableArray alloc] init];
    }
    return _cars;
}

-(NSArray*)credit_cards {
    if(!_credit_cards) {
        _credit_cards = [[NSMutableArray alloc] init];
    }
  return _credit_cards;
}


- (void)updateFromDictionary:(NSDictionary*)dictIn {
    self.first_name = [dictIn objectForKey:@"first_name"];
    self.last_name = [dictIn objectForKey:@"last_name"];
    self.email = [dictIn objectForKey:@"email"];
    self.phone_number = [dictIn objectForKey:@"phone_number"];
    self.credit = [[dictIn objectForKey:@"credit"] doubleValue];
    self.accountType = [dictIn objectForKey:@"account_type"];
    
    //Credit Cards
    NSMutableArray* credit_cards = [[NSMutableArray alloc] init];
    for( NSDictionary* credit_card_dict in [dictIn objectForKey:@"credit_cards"]) {
        CreditCard* credit_card = [[CreditCard alloc] init];
        [credit_card updateFromDictionary:credit_card_dict];
        [credit_cards addObject:credit_card];
    }
    self.credit_cards = [credit_cards copy];
    
    //Cars
    NSMutableArray* cars = [[NSMutableArray alloc] init];
    for( NSDictionary* car_dict in [dictIn objectForKey:@"cars"]) {
        Car* car = [[Car alloc] init];
        [car updateFromDictionary:car_dict];
        [cars addObject:car];
    }
    self.cars = [cars copy];
    
    //Promos
    NSMutableArray* promos = [[NSMutableArray alloc] init];
    for( NSDictionary* promo_dict in [dictIn objectForKey:@"promos"]) {
        Promo* promo = [[Promo alloc] init];
        [promo updateFromDictionary:promo_dict];
        [promos addObject:promo];
    }
    self.promos = [promos copy];
     
     
}

- (void)updateFromServerWithSuccess:(SuccessBlock)successBlock
             withFailure:(FailureBlock)failureBlock {
    [Api getUserProfileWithSuccess:^(NSDictionary * dictIn) {
        [self updateFromDictionary:dictIn];
        successBlock(dictIn);
    } withFailure:failureBlock];
}

- (void)pushToServerWithSuccess:(SuccessBlock)successBlock
         withFailure:(FailureBlock)failureBlock {
    //STUB
    //todo: register new user
}

- (void)pushChangesToServerWithSuccess:(SuccessBlock)successBlock
         withFailure:(FailureBlock)failureBlock {
    
    NSDictionary* dictOut = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.first_name,@"first_name",
                             self.last_name,@"last_name",
                             self.email,@"email",
                             self.phone_number,@"phone_number",
                             self.accountType, @"account_type",
                             nil];
    
    [Api updateUserProfileWithDict:dictOut withSuccess:^(NSDictionary * dictIn) {
        [self updateFromDictionary:dictIn];
        successBlock(dictIn);
    } withFailure:failureBlock ];
}

- (void)clear {
  self.first_name = @"";
  self.last_name = @"";
  self.email = @"";
  self.phone_number = @"";
  self.credit = 0;
  self.credit_cards = [[NSMutableArray alloc] init];
  self.cars = [[NSMutableArray alloc] init];
  self.promos = [[NSMutableArray alloc] init];
    self.accountType = @"";
}

- (NSString*) validate {
    
    if(self.phone_number.length != 14) {
        return @"Please give a valid phone number.";
    }
    
    if(self.first_name.length == 0) {
        return @"Please give a valid name.";
    }
    
    if(self.last_name.length == 0) {
        return @"Please give a valid name.";
    }
    
    if(self.email.length == 0) {
        return @"Please give a valid email.";
    }
    
    if(self.password.length == 0) {
        return @"Please give a valid password.";
    }
    
    return nil;
    
    /*
    if(self.zipField.text.length == 0) {
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please give a valid zip code." delegate:self cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [error show];
        return;
    }
    
    if(self.licensePlateField.text.length == 0) {
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please give a valid license plate." delegate:self cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [error show];
        return;
    }
     */
    
}





@end
