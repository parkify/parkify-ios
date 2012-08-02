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

@end
