//
//  Offer.h
//  Parkify
//
//  Created by Me on 8/15/12.
//
//

#import <Foundation/Foundation.h>

@interface PriceInterval : NSObject <NSCoding>
@property double startTime;
@property double endTime;
@property double pricePerHour;
- (id) initFromDictionary:(NSDictionary*)dictIn;
@property (nonatomic, strong) NSMutableDictionary* flatPrices;
@end

@interface Offer : NSObject <NSCoding>


@property double startTime;
@property double endTime;
@property (strong, nonatomic) NSArray* priceList;
@property int mId;
@property int spotId;

- (id) initFromDictionary:(NSDictionary*)dictIn;

- (double) findCostWithStartTime:(double)startTime endTime:(double)endTime flatRateName:(NSString*)flatRateName;

- (double) findCostWithStartTime:(double)startTime endTime:(double)endTime;

- (BOOL) overlapsWithStartTime:(double)startTime endTime:(double)endTime;

- (NSArray*) findPricesInRange:(double)startTime endTime:(double)endTime;

- (NSMutableDictionary*) findFixedPricesForStartTime:(double)startTime;

@end
