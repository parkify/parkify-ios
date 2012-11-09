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
#ifdef DEBUGVER
    #define TARGET_SERVER @"parkify-rails.herokuapp.com"
#else
    #define TARGET_SERVER @"192.168.1.132:3000"
#endif

#define kGenericErrorAlertTag 6727
#define kAlertViewErrorInProblemUpload 9989
#define kAlertViewSuccessProblemUpload 9990
#define kAlertViewSuccessButOtherProbem 9991
#define kAlertViewChoicesForProblems 9992
#define kPhoneNumber @"tel:1-800-luv-park"

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
