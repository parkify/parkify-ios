//
//  ParkingSpot.m
//  Parkify2
//
//  Created by Me on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ParkingSpot.h"

@implementation ParkingSpot
@synthesize mID = _mID;
@synthesize mLat = _mLat;
@synthesize mLong = _mLong;
@synthesize mCompanyName = _mCompanyName;
@synthesize mLocalID = _mLocalID;
@synthesize mPrice = _mPrice;
@synthesize mPhoneNumber= _mPhoneNumber;
@synthesize mDesc = _mDesc;
@synthesize mFree = _mFree;
@synthesize mRemove = _mRemove;
//@synthesize coordinate = _coordinate;

- (id)initWithID:(int)idIn lat:(double)latIn
             lng:(double)lngIn companyName:(NSString*)companyNameIn
         localID:(int)localIDIn price:(double)priceIn
     phoneNumber:(NSString*)phoneNumberIn desc:(NSString*)descIn
            free:(Boolean)freeIn {	
    if ((self = [super init])) {
        self.mID = idIn;
        self.mLat = latIn;
        self.mLong = lngIn;
        self.mCompanyName = [companyNameIn copy];
        self.mLocalID = localIDIn;
        self.mPrice = priceIn;
        self.mPhoneNumber = [phoneNumberIn copy];
        self.mDesc = [descIn copy];
        self.mFree = freeIn;
        self.mRemove = false;
        //_coordinate.latitude = latIn;
        //_coordinate.longitude = lngIn;
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    coordinate.latitude = self.mLat;
    coordinate.longitude = self.mLong;
    return coordinate;
}

- (NSString *)title {
    return [NSString stringWithFormat:@"%@ %d | %0.2f/hr", 
    self.mCompanyName, self.mLocalID, self.mPrice];
}

- (NSString *)subtitle {
    return [NSString stringWithFormat:@"%@ to Book", self.mPhoneNumber];
}

@end