//
//  ExtraTypes.h
//  Parkify2
//
//  Created by Me on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Parkify2_ExtraTypes_h
#define Parkify2_ExtraTypes_h

typedef void(^CompletionBlock)(void);
typedef void(^SuccessBlock)(NSDictionary*);
typedef void(^FailureBlock)(NSError*);

typedef NSString* (^Formatter)(double val);

#define ADMIN_VER false
#define DEBUGVER
#define APIVER @"v2"
#ifdef DEBUGVER
//#define TARGET_SERVER @"192.168.1.117:3000"
    #define TARGET_SERVER @"parkify-rails-staging.herokuapp.com"

#else
    #define TARGET_SERVER @"parkify-rails-staging.herokuapp.com"

#endif



#define kGenericErrorAlertTag 6727
#define kAlertViewErrorInProblemUpload 9989
#define kAlertViewSuccessProblemUpload 9990
#define kAlertViewSuccessButOtherProbem 9991
#define kAlertViewChoicesForProblems 9992
#define kPreviewTransaction 9988
#define kAttempTransaction 9987
#define kPhoneNumber @"tel:1-800-luv-park"
#define kLoadUDIDandPush 9986
#define kGetAcceptances 9985
#define kStripeToken @"pk_XeTF5KrqXMeSyyqApBF4q9qDzniMn"
//#define kStripeTest @"pk_GP95lUPyExWOy8e81qL5vIbwMH7G8"

//#define TARGET_SERVER_NORMAL @"parkify-rails.herokuapp.com"

//#define TARGET_SERVER TARGET_SERVER_NORMAL //@"192.168.1.132:3000"

@protocol PriceStore <NSObject>
- (NSArray*) findPricesInRange:(double)startTime endTime:(double)endTime;
@end

@protocol NameIdMappingDelegate <NSObject>

- (int) idForName:(NSString *)name;

@end

/*
@protocol CreditCardsSource <NSObject>

@property (strong, nonatomic) NSArray* credit_cards;

@end

@protocol CarSource <NSObject>

@property (strong, nonatomic) NSArray* cars;

@end


@protocol PromoSource <NSObject>

@property (strong, nonatomic) NSArray* promos;

@end
*/


#endif
