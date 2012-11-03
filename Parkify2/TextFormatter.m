//
//  Formatter.m
//  Parkify2
//
//  Created by Me on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TextFormatter.h"
#import <Foundation/Foundation.h>

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
        if(distanceInMiles >= 100) {
            return [NSString stringWithFormat:@"%0.0f miles", distanceInMiles];
        } else {
            return [NSString stringWithFormat:@"%0.1f miles", distanceInMiles];
        }
    }
}

+ (NSString*) formatIdString:(int)idIn {
    return [[NSString stringWithFormat:@"%d", idIn + 10000] capitalizedString];
    //return [[NSString stringWithFormat:@"%x", idIn + 10000] capitalizedString];
}

+ (NSString*) formatSecuredAddressString:(NSString*)address {
    //find the street address part.
    NSMutableArray* addressComponents = [[address componentsSeparatedByString:@","] mutableCopy];
    if(addressComponents.count == 0) {
        return address;
    }
    NSString* first = [addressComponents objectAtIndex:0];
    
    //find the number of the street address part.
    NSMutableArray* firstComponents = [[first componentsSeparatedByString:@" "] mutableCopy];
    if(firstComponents.count == 0) {
        return address;
    }
    NSString* numericalPart = [firstComponents objectAtIndex:0];
    
    //check if first part is a number
    NSLocale *l_en = [[NSLocale alloc] initWithLocaleIdentifier: @"en_US"];
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setLocale: l_en];
    if(![f numberFromString: numericalPart]) {
        return address;
    }
    
    //now replace the last 3 digits with asterisks.
    if(numericalPart.length <= 3) {
        numericalPart = @"***";
    } else {
        numericalPart = [[numericalPart substringToIndex:numericalPart.length-3] stringByAppendingString:@"***"];
    }
    
    //now stitch back together.
    
    [firstComponents setObject:numericalPart atIndexedSubscript:0];
    
    first = [firstComponents componentsJoinedByString:@" "];
    
    [addressComponents setObject:first atIndexedSubscript:0];
    
    address = [addressComponents componentsJoinedByString:@","];

    return address;
    
}

@end
