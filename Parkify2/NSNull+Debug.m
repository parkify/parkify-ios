#import "NSNull+Debug.h"

@implementation NSNull (Debug)

- (int) intValue {
    NSLog(@"Caught in NSNull::intValue");
    return 0;
}

@end