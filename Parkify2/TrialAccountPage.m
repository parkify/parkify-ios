//
//  DarkTextCell.m
//  Parkify
//
//  Created by Me on 2/1/13.
//
//

#import "TrialAccountPage.h"
#import "Api.h"
#import "ErrorTransformer.h"
#import "WaitingMask.h"
#import "UIView+FindFirstResponder.h"
@interface TrialAccountPage()
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *promoCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *unFirstResponderButton;
@property (weak, nonatomic) IBOutlet UILabel *prizeLabel;

@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *promoCodeActivityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *promoCodeImageView;
@property (strong, nonatomic) WaitingMask* waitingMask;

@property (strong, nonatomic) NSString* promoShortText;

- (IBAction)shouldContinue:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *trialAccountView;
@property (weak, nonatomic) IBOutlet UIView *passThroughView;

@end

@implementation TrialAccountPage
@synthesize keyboardAvoidingScrollView = _keyboardAvoidingScrollView;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        /*
        NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"TrialAccountPage_NoAutoLayout" owner:self options:nil];
        self = (TrialAccountPage*) [nib objectAtIndex:0];
         
        */
        UINib* nib;
    
        
        nib = [UINib nibWithNibName:@"TrialAccountPage" bundle:[NSBundle mainBundle]];
        
        UIView* mainView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
        
        mainView.frame = frame;
        
        [self addSubview: mainView];
        
        self.phoneNumberTextField.delegate = self;
        self.promoCodeTextField.delegate = self;
        [self.promoCodeImageView setContentMode:UIViewContentModeScaleAspectFit];
        
        [self.registerButton addTarget:self action:@selector(registerButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.unFirstResponderButton setUserInteractionEnabled:false];
        [self.unFirstResponderButton addTarget:self action:@selector(unFirstResponderButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

- (void)moreToLeft:(BOOL)isMore {
    
}
- (void)moreToRight:(BOOL)isMore {
    
}

- (IBAction)registerButtonTapped:(id)sender {
    /*
    if(!self.tosCheckbox.selected) {
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please view our Terms of Service." delegate:self cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [error show];
        return;
    }
    */
    
    if(self.phoneNumberTextField.text.length != 14) {
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please give a valid phone number." delegate:self cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [error show];
        return;
    }
    CGRect waitingMaskFrame = self.frame;
    waitingMaskFrame.origin.x = 0;
    waitingMaskFrame.origin.y = 0;
    
    self.waitingMask = [[WaitingMask alloc] initWithFrame:waitingMaskFrame];
    [self addSubview:self.waitingMask];
    self.registerButton.enabled = false;
    
    [Api signUpWithPhoneNumber:self.phoneNumberTextField.text withPromoCode:self.promoCodeTextField.text
     
                   withSuccess:^(NSDictionary * result) {
                       [self handleRegistrationSuccess:result];
                   } withFailure:^(NSError * result) {
                       [self handleRegistrationFailure:result];
                   } ];
     
     



}

- (IBAction)unFirstResponderButtonTapped:(id)sender {
    [self textFieldShouldReturn:(UITextField*)[self findFirstResponder]];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.keyboardAvoidingScrollView adjustOffsetToIdealIfNeeded];
    [self.unFirstResponderButton setUserInteractionEnabled:true];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

-(void)promoCodeSuccess {
    self.promoCodeImageView.image = [UIImage imageNamed:@"glyphicons_circle_ok.png"];
    [UIView animateWithDuration:0.2 animations:^{
        self.promoCodeImageView.alpha = 1;
        self.promoCodeActivityIndicator.alpha = 0;
    }];
    self.prizeLabel.text = [NSString stringWithFormat:@". . . and you'll get %@ from your promotion code.",self.promoShortText];
}
-(void)promoCodeFailure {
    self.promoCodeImageView.image = [UIImage imageNamed:@"glyphicons_circle_remove.png"];
    [UIView animateWithDuration:0.2 animations:^{
        self.promoCodeImageView.alpha = 1;
        self.promoCodeActivityIndicator.alpha = 0;
    }];
    self.prizeLabel.text = @". . . and we'll start you out with $5 credits free.";
}
-(void)promoCodeNone {
    self.promoCodeImageView.alpha = 0;
    self.promoCodeActivityIndicator.alpha = 0;
    self.prizeLabel.text = @". . . and we'll start you out with $5 credits free.";
}
-(void)promoCodeWaiting {
    [UIView animateWithDuration:0.2 animations:^{
        self.promoCodeImageView.alpha = 0;
        self.promoCodeActivityIndicator.alpha = 1;
        [self.promoCodeActivityIndicator startAnimating];
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    [self.unFirstResponderButton setUserInteractionEnabled:false];
    
    if(textField == self.promoCodeTextField) {
        if([textField.text length] == 0) {
            [self promoCodeNone];
            
        } else {
            [self promoCodeWaiting];
            //check for code validity
            [Api checkPromoCode:self.promoCodeTextField.text withSuccess:^(NSDictionary * result) {
                self.promoShortText = [result objectForKey:@"display_string"];
                [self promoCodeSuccess];
            } withFailure:^(NSError * result) {
                [self promoCodeFailure];
            }];
        }
        
    }
    
    return NO; // We do not want UITextField to insert line-breaks.
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if(textField != self.phoneNumberTextField) {
        return YES;
    }
    
    
    int length = [self getLength:textField.text];
    //NSLog(@"Length  =  %d ",length);
    
    if(length == 10)
    {
        if(range.length == 0)
            return NO;
    }
    
    if(length == 3)
    {
        NSString *num = [self formatNumber:textField.text];
        textField.text = [NSString stringWithFormat:@"(%@) ",num];
        if(range.length > 0)
            textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
    }
    else if(length == 6)
    {
        NSString *num = [self formatNumber:textField.text];
        //NSLog(@"%@",[num  substringToIndex:3]);
        //NSLog(@"%@",[num substringFromIndex:3]);
        textField.text = [NSString stringWithFormat:@"(%@) %@-",[num  substringToIndex:3],[num substringFromIndex:3]];
        if(range.length > 0)
            textField.text = [NSString stringWithFormat:@"(%@) %@",[num substringToIndex:3],[num substringFromIndex:3]];
    }
    
    return YES;
    
}

-(NSString*)formatNumber:(NSString*)mobileNumber
{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    NSLog(@"%@", mobileNumber);
    
    int length = [mobileNumber length];
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
        NSLog(@"%@", mobileNumber);
        
    }
    
    
    return mobileNumber;
}


-(int)getLength:(NSString*)mobileNumber
{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = [mobileNumber length];
    
    return length;
    
    
}

- (IBAction)shouldContinue:(id)sender {
    [self sendActionsForControlEvents:
     ShouldContinueActionEvent];
}

-(void)handleRegistrationSuccess:(NSDictionary*)result {
    if(self.waitingMask) {
        [self.waitingMask removeFromSuperview];
        self.waitingMask = nil;
    }
    self.registerButton.enabled = true;
    
    [self sendActionsForControlEvents:
     ShouldContinueActionEvent];
}

-(void)handleRegistrationFailure:(NSError*)result {
    if(self.waitingMask) {
        [self.waitingMask removeFromSuperview];
        self.waitingMask = nil;
    }
    NSLog(@"Error: %@; %@", result.localizedDescription, [result.userInfo objectForKey:@"message"]);
    
    self.registerButton.enabled = true;
    
    if (result.domain && [result.domain isEqualToString:API_ERROR_DOMAIN]) {
        /* Handle user registratin error here */
        
        [ErrorTransformer errorToAlert:result withDelegate:self];
        
    } else {
        /* Handle network error here */
        
        //TODO: standard Network-error-maker in ErrorTransformer.h
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not reach server" delegate:self cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [error show];
    }
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    /*
    NSArray* views = [NSArray arrayWithObjects:self.phoneNumberTextField, self.promoCodeTextField, nil];
    for (UIView *view in views) {
        if ([view pointInside:[self convertPoint:point toView:view] withEvent:event])
            return YES;
    }
    UIView* firstResponder = [self findFirstResponder];
    if(firstResponder) {
        [self textFieldShouldReturn:(UITextField *) firstResponder];
    }
     */
    return YES;
}


- (void) setStateTrialAccount {
    if(self.waitingMask) {
        [self.waitingMask removeFromSuperview];
        self.waitingMask = nil;
    }
self.trialAccountView.alpha = 1;
self.passThroughView.alpha = 0;

}
- (void) setStateWaiting {
    if (!self.waitingMask) {
        
        CGRect waitingMaskFrame = self.frame;
        waitingMaskFrame.origin.x = 0;
        waitingMaskFrame.origin.y = 0;
        
        self.waitingMask = [[WaitingMask alloc] initWithFrame:waitingMaskFrame];
        [self addSubview:self.waitingMask];
        
        
    }
    self.trialAccountView.alpha = 0;
    self.passThroughView.alpha = 0;
}
- (void) setStatePassThrough {
    if(self.waitingMask) {
        [self.waitingMask removeFromSuperview];
        self.waitingMask = nil;
    }
    self.trialAccountView.alpha = 0;
    self.passThroughView.alpha = 1;
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
