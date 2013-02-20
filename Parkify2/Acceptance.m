//
//  Acceptance.m
//  Parkify
//
//  Created by gnamit on 1/10/13.
//
//

#import "Acceptance.h"

@implementation Acceptance
@synthesize spotid = _spotid;
@synthesize starttime = _starttime;
@synthesize endttime=_endttime;
@synthesize lastPaymentInfo= _lastPaymentInfo;
@synthesize active = _active;
@synthesize acceptid=_acceptid;
@synthesize offers=_offers;

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.starttime forKey:@"starttime"];
    [aCoder encodeObject:self.endttime forKey:@"endtime"];
    [aCoder encodeObject:self.spotid forKey:@"spotid"];
    [aCoder encodeObject:self.lastPaymentInfo forKey:@"lastpayment"];
    [aCoder encodeObject:self.acceptid forKey:@"acceptid"];
    [aCoder encodeObject:self.offers forKey:@"offers"];
    [aCoder encodeBool:self.active forKey:@"active"];
    [aCoder encodeDouble:self.payBy forKey:@"pay_by"];
    [aCoder encodeDouble:self.needsPayment forKey:@"needs_payment"];
    
    
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init])
    {
        self.starttime = [aDecoder decodeObjectForKey:@"starttime"];
        self.endttime = [aDecoder decodeObjectForKey:@"endtime"];
        self.spotid = [aDecoder decodeObjectForKey:@"spotid"];
        self.lastPaymentInfo = [aDecoder decodeObjectForKey:@"lastpayment"];
        self.acceptid = [aDecoder decodeObjectForKey:@"acceptid"];
        self.offers = [aDecoder decodeObjectForKey:@"offers"];
        self.active = [aDecoder decodeBoolForKey:@"active"];
        self.payBy = [aDecoder decodeDoubleForKey:@"pay_by"];
        self.needsPayment = [aDecoder decodeDoubleForKey:@"needs_payment"];
    }
    return self;
}
-(id)init:(NSMutableDictionary *)withInfo{
    self = [super init];
    if (self){
        self.spotid = [withInfo objectForKey:@"spotid"];
        self.starttime = [[withInfo objectForKey:@"starttime"] copy];
        self.endttime = [[withInfo objectForKey:@"endtime"] copy];
        NSLog(@"Storing acceptance with start time %@ and end time %@", self.starttime, self.endttime);
        self.lastPaymentInfo = [withInfo objectForKey:@"lastpayment"];
        self.active = [[withInfo objectForKey:@"active"] boolValue];
        self.acceptid = [withInfo objectForKey:@"acceptanceid"];
        self.offers = [withInfo objectForKey:@"offers"];
        
        self.payBy = [[withInfo objectForKey:@"pay_by"] doubleValue];
        self.needsPayment = [[withInfo objectForKey:@"needs_payment"] doubleValue];
    }
    return self;
}

@end
