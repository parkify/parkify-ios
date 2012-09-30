//
//  PlacedAgent.h
//  SewichiAgent
//
//  Created by Charles Skoda on 1/10/12.
//  Copyright (c) 2012 Placed. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	MALE,
	FEMALE
} Gender;

typedef enum {
	USER,
	SESSION,
    PAGE
} Scope;

typedef enum {
    DEFAULT,
    CONSERVATIVE,
    PRECISE
} DataCollectionMode;

@interface PlacedAgent : NSObject

// Must call first to initialize!
+ (void)initWithAppKey:(NSString*)appKey;

+ (void)setEnableLogging:(BOOL)state;
+ (void)setDataCollectionMode:(DataCollectionMode)mode;

+ (void)logStartSession;
+ (void)logEndSession;

+ (void)logPageView:(NSString*)pageTitle;
+ (void)logCustomEvent:(NSString*)eventTitle;
+ (void)logCustomEventWithTitle:(NSString*)eventTitle andAttributes:(NSArray*)attributes;
+ (void)logCustomVariableWithScope:(Scope)scope andValue:(NSString*)value;
+ (void)logUniqueID:(NSString*)uniqueID;

+ (void)logAge:(int)age;
+ (void)logGender:(Gender)gender;

// For logCustomEventWithTitle: andAttributes:
// "attributes" is an NSArray of dictionaries returned from this method
+ (NSDictionary*)attributeWithName:(NSString*)name andValue:(NSString*)value;

@end
