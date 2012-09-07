//
//  Formatter.m
//  Parkify2
//
//  Created by Me on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TextFormatter.h"

@implementation TextFormatter

+ (CGAffineTransform) transformForSpotViewText {
    CGAffineTransform squish;
    squish.a = 0.9;
    squish.b = 0;
    squish.c = 0;
    squish.d = 1.15;
    squish.tx = 0;
    squish.ty = 0;
    return squish;
}

+ (CGAffineTransform) transformForSignupViewText {
    CGAffineTransform squish;
    squish.a = 0.8;
    squish.b = 0;
    squish.c = 0;
    squish.d = 1;
    squish.tx = 0;
    squish.ty = 0;
    return squish;
}

+ (NSString*) formatDistanceClose:(double)distanceInMiles {
    if(distanceInMiles < 0.25) {
        return [NSString stringWithFormat:@"%0.0f feet", distanceInMiles*5280.0];
    } else {
        return [NSString stringWithFormat:@"%0.1f miles", distanceInMiles];
    }
}

+ (NSString*) formatIdString:(int)idIn {
    return [[NSString stringWithFormat:@"%d", idIn + 10000] capitalizedString];
    //return [[NSString stringWithFormat:@"%x", idIn + 10000] capitalizedString];
}


@end
