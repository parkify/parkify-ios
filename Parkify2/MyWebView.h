//
//  MyWebView.h
//  UIWebView-Call-ObjC
//
//  Created by NativeBridge on 02/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
@protocol webViewCustomDelegate<NSObject>;
@optional
-(void)getCenterCoord:(NSNumber *)ider;
-(void)finishedLoading;

@end

@interface MyWebView : UIWebView <UIWebViewDelegate> {
  
  int alertCallbackId;
}
@property (nonatomic, assign) id <webViewCustomDelegate> customdelegate;
-(void)reloadPage;
- (void)handleCall:(NSString*)functionName callbackId:(int)callbackId args:(NSArray*)args;
- (void)returnResult:(int)callbackId args:(id)firstObj, ...;

@end
