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

@protocol PriceStore <NSObject>
- (NSArray*) findPricesInRange:(double)startTime endTime:(double)endTime;
@end




#endif
