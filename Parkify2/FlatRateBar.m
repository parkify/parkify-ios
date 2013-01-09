//
//  FlatRateBar.m
//  Parkify
//
//  Created by Me on 1/3/13.
//
//

//for now, just position the max number of bubbles.
#define MAX_BUBBLE_COUNT 6
#define SUBLABEL_FONT [UIFont fontWithName:@"HelveticaNeue"

#import "FlatRateBar.h"
#import "FlatRateBubble.h"
#import "ExtraTypes.h"
#import "TextFormatter.h"

@implementation FlatRateBar

@synthesize flatPrices = _flatPrices;
@synthesize flatRateBubbles = _flatRateBubbles;
@synthesize flatRateSubLabels = _flatRateSubLabels;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withPrices:(NSMutableDictionary*)flatPricesIn {
    self = [super initWithFrame:frame];
    if (self) {
        self.flatPrices = [flatPricesIn mutableCopy];
        self.flatRateBubbles = [[NSMutableArray alloc] init];
        self.flatRateSubLabels = [[NSMutableArray alloc] init];
        
        NSMutableArray* orderedKeys = [[NSMutableArray alloc] init];
        for (NSNumber* flatTime in self.flatPrices) {
            [orderedKeys addObject:flatTime];
        }
        [orderedKeys sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            if ([obj1 doubleValue] < [obj2 doubleValue])
                return NSOrderedAscending;
            if ([obj1 doubleValue] > [obj2 doubleValue])
                return NSOrderedDescending;
            return NSOrderedSame;
        }];
        
        
        int i=0;
        //form bubbles.
        for (NSNumber* flatTime in orderedKeys) {
            if (i >= MAX_BUBBLE_COUNT) {
                break;
            }
            
            FlatRateBubble* bubble = [[FlatRateBubble alloc] initWithFrame:CGRectZero];
            [self.flatRateBubbles addObject:bubble];
            
            bubble.tag = [flatTime intValue];
            NSString* durationString = [TextFormatter formatCompactDurationString:[flatTime doubleValue]];
            
            [bubble setTitle:durationString forState:UIControlStateSelected];
            [bubble setTitle:durationString forState:UIControlStateNormal];
            
            [bubble addTarget:self action:@selector(bubbleWasTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            [bubble setSelected:(i==0)];
            
            NSString* priceString = [TextFormatter formatPriceString: [[self.flatPrices objectForKey:flatTime] doubleValue]];
            
            CGSize labelSize = [priceString sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:12]];
            UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width, labelSize.height)];
            label.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:12];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = PARKIFY_CYAN;
            
            label.text = priceString;
            
            [self.flatRateSubLabels addObject:label];
            
            i++;
        }
        
        [self positionBubbles]; //and sublabels
        
        
        for (int i=0; i<self.flatRateBubbles.count; i++) {
            FlatRateBubble* bubble = [self.flatRateBubbles objectAtIndex:i];
            UILabel* label = [self.flatRateSubLabels objectAtIndex:i];
            
            
            [self addSubview:bubble];
            [self addSubview:label];
        }
        
    }
    return self;
}

//for now, just position the max number of bubbles.
- (void)positionBubbles {
    double width = ([FlatRateBubble width] + 2*[FlatRateBubble padding])*self.flatRateBubbles.count;
    double iterX = (self.frame.size.width - width)/2.0;
    for (int i=0; i<self.flatRateBubbles.count; i++) {
        FlatRateBubble* bubble = [self.flatRateBubbles objectAtIndex:i];
        UILabel* label = [self.flatRateSubLabels objectAtIndex:i];
        
        
        CGRect frame = bubble.frame;
        frame.origin.x = iterX+[FlatRateBubble padding];
        frame.origin.y = (self.frame.size.height - [FlatRateBubble height] - label.frame.size.height - [FlatRateBubble padding])/2.0;
        frame.size.width = [FlatRateBubble width];
        frame.size.height = [FlatRateBubble height];
        bubble.frame = frame;
        
        CGPoint center = bubble.center;
        center.y += (label.frame.size.height/2.0 + frame.size.height/2.0) + [FlatRateBubble padding];
        label.center = center;
        
        iterX += [FlatRateBubble width] + 2*[FlatRateBubble padding];
    }
}

- (UIButton*)selectedBubble {
    for (UIButton* bubbleIter in self.flatRateBubbles) {
        if(bubbleIter.selected) {
            return bubbleIter;
        }
    }
    return [[UIButton alloc] init];
}

- (IBAction)bubbleWasTapped:(id)sender {
    UIButton* bubble = (UIButton*) sender;
    for (UIButton* bubbleIter in self.flatRateBubbles) {
        [bubbleIter setSelected:[bubbleIter isEqual:bubble]];
    }
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (double)selectedDuration {
    return [self selectedBubble].tag;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end