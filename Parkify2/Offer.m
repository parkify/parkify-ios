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
@synthesize flatPrices = _flatPrices;

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeDouble:self.startTime forKey:@"starttime"];
    [aCoder encodeDouble:self.endTime forKey:@"endtime"];
    [aCoder encodeDouble:self.pricePerHour forKey:@"priceperhour"];
    [aCoder encodeObject:self.flatPrices forKey:@"flatprices"];
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init])
    {
        self.startTime = [aDecoder decodeDoubleForKey:@"starttime"];
        self.endTime = [aDecoder decodeDoubleForKey:@"endtime"];
        self.pricePerHour = [aDecoder decodeDoubleForKey:@"priceperhour"];
        self.flatPrices = [aDecoder decodeObjectForKey:@"flatprices"];
    }
    
    return self;

}
- (id) initFromDictionary:(NSDictionary*)dictIn
{
    if (self = [super init])
    {
        // Initialization code here
        self.startTime = [[dictIn objectForKey:@"start_time"] doubleValue];
        self.endTime = [[dictIn objectForKey:@"end_time"] doubleValue];
        self.pricePerHour = [[dictIn objectForKey:@"price_per_hour"] doubleValue];
        self.flatPrices = [[NSMutableDictionary alloc] init];
        for (NSNumber* duration in [dictIn objectForKey:@"flat_prices"]) {
            NSNumber* price = [NSNumber numberWithDouble:[[[dictIn objectForKey:@"flat_prices"] objectForKey:duration] doubleValue]];
            NSNumber* newKey = [duration copy];
            [self.flatPrices setObject: price forKey:newKey];
        }
        //self.flatPrices = [[dictIn objectForKey:@"flat_prices"] mutableCopy];
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

-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]){
        self.startTime = [aDecoder decodeDoubleForKey:@"starttimer"];
        self.endTime = [aDecoder decodeDoubleForKey:@"endtimer"];
        self.priceList = [aDecoder decodeObjectForKey:@"pricelist"];
        self.mId = [aDecoder decodeIntForKey:@"mid"];
        self.spotId = [aDecoder decodeIntForKey:@"spotid"];
    }
    return self;
}
-(void) encodeWithCoder:(NSCoder *)aCoder   {
    [aCoder encodeDouble:self.startTime forKey:@"starttimer"];
    [aCoder encodeDouble:self.endTime forKey:@"endtimer"];
    [aCoder encodeObject:self.priceList forKey:@"pricelist"];
    [aCoder encodeInt:self.mId forKey:@"mid"];
    [aCoder encodeInt:self.spotId forKey:@"spotid"];
    
}
- (id) initFromDictionary:(NSDictionary*)dictIn;
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

- (double) findCostWithStartTime:(double)startTime endTime:(double)endTime flatDuration:(double)flatDuration {
    for (PriceInterval* iterPrice in self.priceList) {
        if (startTime >= iterPrice.startTime && startTime <= iterPrice.endTime) {
            NSString* key = [NSString stringWithFormat:@"%d", (int)flatDuration];
            NSNumber* flatPrice = [iterPrice.flatPrices objectForKey:key];
            if (flatPrice) {
                return [flatPrice doubleValue];
            }
        }
    }
    return 0;
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

- (NSMutableDictionary*) findFixedPricesForStartTime:(double)startTime {
    for (PriceInterval* iterPrice in self.priceList) {
        if(startTime >= iterPrice.startTime &&
           startTime <= iterPrice.endTime) {
            return iterPrice.flatPrices;
        }
    }
    return [[NSMutableDictionary alloc] init];
}

@end
