//
//  problemSpotViewController.h
//  Parkify
//
//  Created by gnamit on 11/4/12.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreFoundation/CFData.h>
#import <CoreFoundation/CFSocket.h>
#import <ImageIO/CGImageProperties.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequestDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "ParkingSpot.h"
@interface problemSpotViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate, UIAlertViewDelegate, ASIHTTPRequestDelegate>
{
    
    __weak IBOutlet UITextField *licensePlateTextField;
    __weak IBOutlet UIView *imagePreviewHolder;
    __weak IBOutlet UIImageView *imagePreviewView;
    __weak IBOutlet UILabel *txtLabelTakePic;
    
    __weak IBOutlet UITextView *genericProblemTextView;
    __weak IBOutlet UIView *genericProblemView;
    __weak IBOutlet UIView *licensePlateProblemInfoView;
}
@property (nonatomic, strong)NSMutableDictionary *transactionInfo;
@property(nonatomic, strong)ParkingSpot *theSpot;
@property (nonatomic, strong)AVCaptureVideoDataOutput *captureOutput;
@property (nonatomic, assign) BOOL isLicensePlateProblem;
@property(nonatomic, retain) UIImage *theProblemImage;
@property(nonatomic, retain) IBOutlet UIView *          videoPreviewView;
@property(nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;

- (IBAction)discardImage:(id)sender;
- (IBAction)closeButtonTapped:(id)sender;
- (IBAction)sendParkingSpotProblem:(id)sender;
- (IBAction)captureStillImage:(id)sender;

@end

