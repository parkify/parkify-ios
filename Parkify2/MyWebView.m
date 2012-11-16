//
//  MyWebView.m
//  UIWebView-Call-ObjC
//
//  Created by NativeBridge on 02/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MyWebView.h"


@implementation MyWebView
@synthesize customdelegate;
-(void)reloadPage{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"googmaps" ofType:@"html"];
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];

}
- (id)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    
    // Set delegate in order to "shouldStartLoadWithRequest" to be called
    self.delegate = self;
    
    // Set non-opaque in order to make "body{background-color:transparent}" working!
    self.opaque = NO;
    
    // Instanciate JSON parser library
    
    // load our html file
      [self reloadPage];
    
  }
  return self;
}


// This selector is called when something is loaded in our webview
// By something I don't mean anything but just "some" :
//  - main html document
//  - sub iframes document
//
// But all images, xmlhttprequest, css, ... files/requests doesn't generate such events :/
- (BOOL)webView:(UIWebView *)webView2 
	      shouldStartLoadWithRequest:(NSURLRequest *)request 
	      navigationType:(UIWebViewNavigationType)navigationType {

	NSString *requestString = [[request URL] absoluteString];
  
  NSLog(@"request : %@",requestString);
  
  if ([requestString hasPrefix:@"js-frame:"]) {
    
    NSArray *components = [requestString componentsSeparatedByString:@":"];
    
    NSString *function = (NSString*)[components objectAtIndex:1];
		int callbackId = [((NSString*)[components objectAtIndex:2]) intValue];
    NSString *argsAsString = [(NSString*)[components objectAtIndex:3] 
                                stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
   //   NSData *maindata = [NSJSONSerialization dataWithJSONObject:[argsAsString dataUsingEncoding:NSUTF8StringEncoding]  options:NSJSONWritingPrettyPrinted error:nil];
      
      NSArray *args = nil;//[NSKeyedUnarchiver unarchiveObjectWithData:maindata];
      
      ///objectWithString:argsAsString error:nil];
    
    [self handleCall:function callbackId:callbackId args:args];
    
    return NO;
  }
  else if ([requestString hasPrefix:@"ios-log:"]) {
       // NSString* logString = [[requestString componentsSeparatedByString:@":#iOS#"] objectAtIndex:1];
        NSLog(@"UIWebView console: %@", requestString);
      
      return NO;
  }
  
  return YES;
}

// Call this function when you have results to send back to javascript callbacks
// callbackId : int comes from handleCall function
// args: list of objects to send to the javascript callback
- (void)returnResult:(int)callbackId args:(id)arg, ...;
{
  if (callbackId==0) return;
  
  va_list argsList;
  NSMutableArray *resultArray = [[NSMutableArray alloc] init];
  
  if(arg != nil){
    [resultArray addObject:arg];
    va_start(argsList, arg);
    while((arg = va_arg(argsList, id)) != nil)
      [resultArray addObject:arg];
    va_end(argsList);
  }
    NSString *resultArrayString = [NSString stringWithFormat:@"[%@]",[resultArray componentsJoinedByString:@","]];// [NSJSONSerialization JSONObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:resultArray] options:NSJSONReadingAllowFragments error:nil];
  //[NSJSONSerialization jsonobjectw)#> stringWithObject:resultArray allowScalar:YES error:nil];
  
  // We need to perform selector with afterDelay 0 in order to avoid weird recursion stop
  // when calling NativeBridge in a recursion more then 200 times :s (fails ont 201th calls!!!)
    NSLog(@"Result sarray is %@", resultArrayString);
  [self performSelector:@selector(returnResultAfterDelay:) withObject:[NSString stringWithFormat:@"NativeBridge.resultForCallback(%d,%@);",callbackId,resultArrayString] afterDelay:0];
}

-(void)returnResultAfterDelay:(NSString*)str {
  // Now perform this selector with waitUntilDone:NO in order to get a huge speed boost! (about 3x faster on simulator!!!)
    NSLog(@"String is: %@", str);
  [self performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:str waitUntilDone:NO];
}

// Implements all you native function in this one, by matching 'functionName' and parsing 'args'
// Use 'callbackId' with 'returnResult' selector when you get some results to send back to javascript
- (void)handleCall:(NSString*)functionName callbackId:(int)callbackId args:(NSArray*)args
{
  if ([functionName isEqualToString:@"setBackgroundColor"]) {
    
    if ([args count]!=3) {
      NSLog(@"setBackgroundColor wait exactly 3 arguments!");
      return;
    }
    NSNumber *red = (NSNumber*)[args objectAtIndex:0];
    NSNumber *green = (NSNumber*)[args objectAtIndex:1];
    NSNumber *blue = (NSNumber*)[args objectAtIndex:2];
    NSLog(@"setBackgroundColor(%@,%@,%@)",red,green,blue);
    self.backgroundColor = [UIColor colorWithRed:[red floatValue] green:[green floatValue] blue:[blue floatValue] alpha:1.0];
    [self returnResult:callbackId args:nil];
    
  }   else if ([functionName isEqualToString:@"getCenterCoord"]){
      if ([customdelegate respondsToSelector:NSSelectorFromString([NSString stringWithFormat:@"%@:", functionName])]){
          [customdelegate performSelector:NSSelectorFromString([NSString stringWithFormat:@"%@:", functionName]) withObject:[NSNumber numberWithInt:callbackId]];
      }
  }
  else{
      if ([customdelegate respondsToSelector:NSSelectorFromString(functionName)]){
          [customdelegate performSelector:NSSelectorFromString(functionName) withObject:[NSNumber numberWithInt:callbackId]];
      }

    //  [self returnResult:callbackId args:[NSNumber numberWithDouble:currLat], [NSNumber numberWithDouble:currLong], [NSNumber numberWithDouble:spotLat], [NSNumber numberWithDouble:spotLong], nil];
      
  }/*else {
    NSLog(@"Unimplemented method '%@'",functionName);
  }*/
}

// Just one example with AlertView that show how to return asynchronous results

@end
