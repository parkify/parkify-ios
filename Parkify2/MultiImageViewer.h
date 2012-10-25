//
//  MultiImageViewer.h
//  Parkify
//
//  Created by Me on 10/23/12.
//
//

#import <UIKit/UIKit.h>

@interface MultiImageViewer : UIControl <UIScrollViewDelegate>

- (id)initWithFrame:(CGRect)frame withImageIds:(NSArray*)imageIds;
@end
