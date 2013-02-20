//
//  ExtraTypes.h
//  Parkify2
//
//  Created by Me on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Parkify2_ExtraTypes_h
#define Parkify2_ExtraTypes_h
#define PARKIFY_CYAN ([UIColor colorWithRed:(97.0/255.0) green:(189.0/255.0) blue:(250.0/255.0) alpha:1])
typedef void(^CompletionBlock)(void);
typedef void(^SuccessBlock)(NSDictionary*);
typedef void(^FailureBlock)(NSError*);

typedef NSString* (^Formatter)(double val);

#define ADMIN_VER true
#define DEBUGVER
#define APIVER @"v3"
#ifdef DEBUGVER
//#define TARGET_SERVER @"10.0.2.15:3000"
#define TARGET_SERVER @"parkify-rails-staging.herokuapp.com"
#else
    #define TARGET_SERVER @"parkify-rails.herokuapp.com"

#endif

#define NOTRANSACTIONDEBUG false
#define DEBUG_FIRST_FLOW false


#define kGenericErrorAlertTag 6727
#define kAlertViewErrorInProblemUpload 9989
#define kAlertViewSuccessProblemUpload 9990
#define kAlertViewSuccessButOtherProbem 9991
#define kAlertViewChoicesForProblems 9992
#define kPreviewTransaction 9988
#define kAttempTransaction 9987
#define kPhoneNumber @"tel:1-855-727-5439"
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

enum {
    ExtendReservationRequestedActionEvent = 1 << 24,
    ShouldContinueActionEvent = 1 << 25,
};

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
