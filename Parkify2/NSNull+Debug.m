#import "NSNull+Debug.h"

@implementation NSNull (Debug)

- (id)objectForKey:(id)key {
    NSLog(@"Caught in NSNull debug");
    return 0;
}

@end