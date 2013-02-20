//
//  Acceptance.h
//  Parkify
//
//  Created by gnamit on 1/10/13.
//
//

#import <Foundation/Foundation.h>

@interface Acceptance : NSObject <NSCoding>
{
    NSNumber *spotid;
    NSString *lastPaymentInfo;
    NSNumber *starttime;
    NSNumber *endtime;
    BOOL active;
    NSMutableArray *offers;
    NSString *acceptid;

}

@property (nonatomic, strong) NSNumber *spotid;
@property (nonatomic, strong) NSString *lastPaymentInfo;
@property (nonatomic, strong) NSNumber *starttime;
@property (nonatomic, strong) NSNumber *endttime;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, strong) NSMutableArray *offers;
@property (nonatomic, strong) NSString *acceptid;
@property double needsPayment;
@property double payBy;

-(id)init:(NSMutableDictionary *)withInfo;

@end
