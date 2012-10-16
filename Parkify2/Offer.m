//
//  Offer.m
//  Parkify
//
//  Created by Me on 8/15/12.
//
//

#import "Offer.h"

@implementation PriceInterval
@synthesize startTime = _startTime;
@synthesize endTime = _endTime;
@synthesize pricePerHour = _pricePerHour;


- (id) initFromDictionary:(NSDictionary*)dictIn
{
    if (self = [super init])
    {
        // Initialization code here
        self.startTime = [[dictIn objectForKey:@"start_time"] doubleValue];
        self.endTime = [[dictIn objectForKey:@"end_time"] doubleValue];
        self.pricePerHour = [[dictIn objectForKey:@"price_per_hour"] doubleValue];
        
    }
    return self;
}

@end

@implementation Offer
@synthesize startTime = _startTime;
@synthesize endTime = _endTime;
@synthesize priceList = _priceList;
@synthesize mId = _mId;
@synthesize spotId = _spotId;


- initFromDictionary:(NSDictionary*)dictIn;
{
    if (self = [super init])
    {
        // Initialization code here
        self.mId = [[dictIn objectForKey:@"id"] intValue];
        self.spotId = [[dictIn objectForKey:@"resource_id"] doubleValue];
        
        self.startTime = [[dictIn objectForKey:@"start_time"] doubleValue];
        self.endTime = [[dictIn objectForKey:@"end_time"] doubleValue];
        
        NSMutableArray* priceList = [[NSMutableArray alloc] init];
        for (NSDictionary* price_interval in [[dictIn objectForKey:@"price_plan"]  objectForKey:@"price_list"]) {
            [priceList addObject:[[PriceInterval alloc] initFromDictionary:price_interval]];
        }
        self.priceList = priceList;
    }
    return self;
}


//We assume that startTime and endTime are within this offer's interval of activeness.
- (double) findCostWithStartTime:(double)startTime endTime:(double)endTime {
    //ok, so find all price intervals.
    double toRtn = 0;
    for (PriceInterval* iterPrice in self.priceList) {
        double effectiveStartTime = MAX(startTime, iterPrice.startTime);
        double effectiveEndTime = MIN(endTime,iterPrice.endTime);
        if(effectiveEndTime > effectiveStartTime ) {
            toRtn += (effectiveEndTime - effectiveStartTime)*iterPrice.pricePerHour/3600;
        }
    }
    return toRtn;
}

- (BOOL) overlapsWithStartTime:(double)startTime endTime:(double)endTime {
    double i0 = MAX(startTime, self.startTime);
    double i1 = MIN(endTime, self.endTime);
    return i0 < i1;
}

//We assume that startTime and endTime are within this offer's interval of activeness.
- (NSArray*) findPricesInRange:(double)startTime endTime:(double)endTime {
    //ok, so find all price intervals.
    NSMutableArray* toRtn = [[NSMutableArray alloc] init];
    for (PriceInterval* iterPrice in self.priceList) {
        if(startTime >= iterPrice.startTime &&
            startTime <= iterPrice.endTime &&
            endTime >= iterPrice.startTime &&
            endTime <= iterPrice.endTime &&
            endTime >= startTime) {
            [toRtn addObject:[NSNumber numberWithDouble:iterPrice.pricePerHour]];
        }
    }
    return toRtn;
}

@end
