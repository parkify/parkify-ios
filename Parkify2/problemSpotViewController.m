//
//  problemSpotViewController.m
//  Parkify
//
//  Created by gnamit on 11/4/12.
//
//

#import "problemSpotViewController.h"
#import "Api.h"
#import "WaitingMask.h"
#import "NSObject+SBJson.h"
#import "Persistance.h"
#import "ErrorTransformer.h"
#import "ExtraTypes.h"
@interface problemSpotViewController ()
@property (strong, nonatomic) WaitingMask* waitingMask;

@end
static void *AVCamFocusModeObserverContext = &AVCamFocusModeObserverContext;

@implementation problemSpotViewController
@synthesize captureOutput= _captureOutput;
@synthesize stillImageOutput = _stillImageOutput;
@synthesize videoPreviewView = _videoPreviewView;
@synthesize isLicensePlateProblem = _isLicensePlateProblem;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.isLicensePlateProblem=FALSE;
        // Custom initialization
    }
    return self;
}
- (NSString *)stringForFocusMode:(AVCaptureFocusMode)focusMode
{
	NSString *focusString = @"";
	
	switch (focusMode) {
		case AVCaptureFocusModeLocked:
			focusString = @"locked";
			break;
		case AVCaptureFocusModeAutoFocus:
			focusString = @"auto";
			break;
		case AVCaptureFocusModeContinuousAutoFocus:
			focusString = @"continuous";
			break;
	}
	
	return focusString;
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.captureOutput setSampleBufferDelegate:nil queue:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //setup Navbar apperance
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];

    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    [titleView setFont:[UIFont fontWithName:@"Helvetica Light" size:36.0f]];
    [titleView setTextColor:[UIColor colorWithRed:197.0f/255.0f green:211.0f/255.0f blue:247.0f/255.0f alpha:1.0f]];
    [titleView setText:@"Problem!"];
    [titleView sizeToFit];
    [titleView setBackgroundColor:[UIColor clearColor]];
    [self.navigationItem setTitleView:titleView];
    
    //check if its for licnese plates or generic problems
    if (!self.isLicensePlateProblem){
        licensePlateProblemInfoView.hidden=YES;
        genericProblemView.hidden=NO;
        [[genericProblemTextView layer] setCornerRadius:10.0f];
        [genericProblemTextView setClipsToBounds:YES];
        UIAlertView* alerter = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Please let us know your problem with this spot" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"It is too small", @"There is some obstruction", @"Other (please describe below)", nil];
        [alerter show];
        alerter.tag = kAlertViewChoicesForProblems;
    }
    
    //setup camera
	AVCaptureSession *session = [[AVCaptureSession alloc] init];
	session.sessionPreset = AVCaptureSessionPresetMedium;
    
	CALayer *viewLayer = self.videoPreviewView.layer;
	NSLog(@"viewLayer = %@", viewLayer);
    
	AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    if ([captureVideoPreviewLayer isOrientationSupported]) {
        [captureVideoPreviewLayer setOrientation:AVCaptureVideoOrientationPortrait];
    }

	captureVideoPreviewLayer.frame = self.videoPreviewView.bounds;
	[self.videoPreviewView.layer addSublayer:captureVideoPreviewLayer];
    CGRect bounds = [self.videoPreviewView bounds];
    [captureVideoPreviewLayer setFrame:bounds];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [viewLayer insertSublayer:captureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];

	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
	NSError *error = nil;
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
	if (!input) {
		// Handle the error appropriately.
		NSLog(@"ERROR: trying to open camera: %@", error);
        [txtLabelTakePic setText:@"Sorry! We can't access your camera."];
	}
    else{
        [session addInput:input];
    }
    
    /////////////////////////////////////////////////////////////
    // OUTPUT #1: Still Image
    /////////////////////////////////////////////////////////////
    // Add an output object to our session so we can get a still image
	// We retain a handle to the still image output and use this when we capture an image.
	self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
	NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
	[self.stillImageOutput setOutputSettings:outputSettings];
	[session addOutput:self.stillImageOutput];
    
    
    /////////////////////////////////////////////////////////////
    // OUTPUT #2: Video Frames
    /////////////////////////////////////////////////////////////
    // Create Video Frame Outlet that will send each frame to our delegate
    self.captureOutput = [[AVCaptureVideoDataOutput alloc] init];
	self.captureOutput.alwaysDiscardsLateVideoFrames = YES;
	//captureOutput.minFrameDuration = CMTimeMake(1, 3); // deprecated in IOS5
	
	// We need to create a queue to funnel the frames to our delegate
	dispatch_queue_t queue;
	queue = dispatch_queue_create("cameraQueue", NULL);
	[self.captureOutput setSampleBufferDelegate:self queue:queue];
	dispatch_release(queue);
	
	// Set the video output to store frame in BGRA (It is supposed to be faster)
	NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
	// let's try some different keys,
	NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
	
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
	[self.captureOutput setVideoSettings:videoSettings];
    
    [session addOutput:self.captureOutput];
    /////////////////////////////////////////////////////////////
    
    
	// start the capture session
	[session startRunning];
    
    /////////////////////////////////////////////////////////////////////////////
    
    // initialize frame counter
    

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex   {
    if (alertView.tag == kGenericErrorAlertTag){
        
    }
    else if (alertView.tag == kAlertViewErrorInProblemUpload){
        
        
    }
    
    else if (alertView.tag == kAlertViewSuccessProblemUpload){
        if(buttonIndex==alertView.cancelButtonIndex){
            [self closeButtonTapped:nil];
            
        }
        else{
            //Find nearest spot
        }
    }
    else if(alertView.tag==kAlertViewChoicesForProblems){
    //    UIAlertView* alerter = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Please let us know your problem with this spot" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"It is too small",@"There is someone parked here", @"There is some obstruction", @"Other (please describe below", nil];
        if(buttonIndex==1)
            [genericProblemTextView setText:@"Spot too small"];
        else if(buttonIndex==2){
            [genericProblemTextView setText:@"There is an obstruction: "];
            
        }

    }
}
- (void)requestFinished:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];
    NSDictionary * root = [responseString JSONValue];
    if([[root objectForKey:@"success"] boolValue]) {
        //Needs to happen on success
        
        //[self performSegueWithIdentifier:@"ViewConfirmation" sender:self];
        //NSLog(@"TEST");
        UIAlertView* success = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your message has successfully been uploaded and your account has been refunded." delegate:self cancelButtonTitle:@"Maps"
                                                otherButtonTitles:@"New Spot", nil];
        success.tag=kAlertViewSuccessProblemUpload;
        [success show];
        
    } else {
        NSError* error = [ErrorTransformer apiErrorToNSError:[root objectForKey:@"error"]];
       //CHANGE CODE BACK GAURAV
        //UIAlertView* alerter = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not contact server" delegate:self cancelButtonTitle:@"Refund spot" otherButtonTitles:@"New Spot", nil];
        //[alerter show];
        //alerter.tag = kAlertViewSuccessProblemUpload;
         [ErrorTransformer errorToAlert:error withDelegate:self];
        
        [self.waitingMask removeFromSuperview];
        self.waitingMask = nil;
    }
    

}
- (void)requestFailed:(ASIHTTPRequest *)request{
    [self.waitingMask removeFromSuperview];
    self.waitingMask = nil;
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSError *error = [request error];
    NSLog(@"Error: %@", error.localizedDescription);
    if(request.responseStatusCode == 401) {
        [Api authenticateModallyFrom:self withSuccess:^(NSDictionary * result){}];
    }
    else {
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not contact server" delegate:self cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        error.tag=kAlertViewErrorInProblemUpload;
        [error show];
        //self.errorLabel.text = @"Could not contact server";
        //self.errorLabel.hidden = false;
    }

}
- (IBAction)discardImage:(id)sender {
    self.theProblemImage = nil;
    imagePreviewHolder.hidden=YES;
}

- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:true completion:^{}];
    
}

- (IBAction)sendParkingSpotProblem:(id)sender {
    
    [Api sendProblemSpotWithText:[licensePlateTextField text] andImage:self.theProblemImage withASIHTTPDelegate:self ];
    
    CGRect waitingMaskFrame = self.view.frame;
    waitingMaskFrame.origin.x = 0;
    waitingMaskFrame.origin.y = 0;
    
    self.waitingMask = [[WaitingMask alloc] initWithFrame:waitingMaskFrame];
    [self.view addSubview:self.waitingMask];
    

}
-(void)imageCaptured:(UIImage*)thenewimage{
    
    self.theProblemImage=thenewimage;
    imagePreviewHolder.hidden=FALSE;
    [imagePreviewView setImage:thenewimage];
}
- (IBAction)captureStillImage:(id)sender
{
        AVCaptureConnection *videoConnection = nil;
        for (AVCaptureConnection *connection in self.stillImageOutput.connections)
        {
            for (AVCaptureInputPort *port in [connection inputPorts])
            {
                if ([[port mediaType] isEqual:AVMediaTypeVideo] )
                {
                    videoConnection = connection;
                    break;
                }
            }
            if (videoConnection) { break; }
        }
        
        NSLog(@"about to request a capture from: %@", self.stillImageOutput);
        [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
         {
             CFDictionaryRef exifAttachments = CMGetAttachment( imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
             if (exifAttachments)
             {
                 // Do something with the attachments.
                 NSLog(@"attachements: %@", exifAttachments);
             }
             else
                 NSLog(@"no attachments");
             
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             UIImage *image = [[UIImage alloc] initWithData:imageData];
             [self performSelectorOnMainThread:@selector(imageCaptured:) withObject:image waitUntilDone:NO];
             
         }];
    // Flash the screen white and fade it out to give UI feedback that a still image was taken
    UIView *flashView = [[UIView alloc] initWithFrame:[[self view] frame]];
    [flashView setBackgroundColor:[UIColor whiteColor]];
    [[[self view] window] addSubview:flashView];
    
    [UIView animateWithDuration:.4f
                     animations:^{
                         [flashView setAlpha:0.f];
                     }
                     completion:^(BOOL finished){
                         [flashView removeFromSuperview];
                     }
     ];
    
}
    
    
    
    /////////////////////////////////////////////////////////////////////
#pragma mark - Video Frame Delegate
    /////////////////////////////////////////////////////////////////////
    - (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
fromConnection:(AVCaptureConnection *)connection
    {
    }
    
    

- (void)viewDidUnload {
    licensePlateTextField = nil;
    imagePreviewHolder = nil;
    imagePreviewView = nil;
    licensePlateProblemInfoView = nil;
    genericProblemView = nil;
    genericProblemTextView = nil;
    txtLabelTakePic = nil;

    [super viewDidUnload];
}
@end
