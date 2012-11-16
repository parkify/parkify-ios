//
//  mapDirectionsViewController.h
//  Parkify
//
//  Created by gnamit on 11/12/12.
//
//

#import <UIKit/UIKit.h>
#import "MyWebView.h"
@interface mapDirectionsViewController : UIViewController <webViewCustomDelegate, UIWebViewDelegate>
{
    double currLat;
    double currLong;
    double spotLat;
    double spotLong;
    UIWebView *currWebView;
    BOOL textDirs;
}

@property (nonatomic, assign) double currLat;
@property (nonatomic, assign) double currLong;
@property (nonatomic, assign) double spotLat;
@property (nonatomic, assign) double spotLong;

@end
