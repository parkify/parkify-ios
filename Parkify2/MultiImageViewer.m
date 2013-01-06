//
//  MultiImageViewer.m
//  Parkify
//
//  Created by Me on 10/23/12.
//
//

#import "MultiImageViewer.h"
#import "Api.h"

#define PAGE_CONTROL_VERT_OFFSET (-20)
#define PAGE_CONTROL_HORIZ_OFFSET 0

@interface MultiImageViewer()
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIScrollView *pictureScrollView;
@property (strong, nonatomic) NSArray* imageIDs;

@end


@implementation MultiImageViewer


//I RECCOMMEND YOU DONT USE THIS
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame withImageIds:(NSArray*)imageIds
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    self.imageIDs = imageIds;
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    CGRect relRect = frame;
    relRect.origin = CGPointMake(0,0);
    
    self.pictureScrollView = [[UIScrollView alloc] initWithFrame:relRect];
    [self.pictureScrollView setPagingEnabled:true];
    [self.pictureScrollView setShowsHorizontalScrollIndicator:false ];
    [self.pictureScrollView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.pictureScrollView];
    
    

    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.center = CGPointMake( PAGE_CONTROL_HORIZ_OFFSET + frame.size.width/2.0, frame.size.height + PAGE_CONTROL_VERT_OFFSET);
    
    [self addSubview:self.pageControl];
    
    [self addAllPictures];
    
    return self;
}


- (void)addAllPictures {
    int marginHoriz = 0;//5;
    int marginVert = 0;//2;
    
    if (self.imageIDs != NULL) {
        int imgCount = [self.imageIDs count];
        if (imgCount != 0) {
            
            if(imgCount == 1) {
                [self.pageControl setHidden:true];
            }
            
            self.pageControl.numberOfPages = imgCount;
            self.pageControl.currentPage = 0;
            //Now generate each image.
            for (int i=0; i<imgCount; i++) {
                UIView* sub=[[UIView alloc]initWithFrame:CGRectMake(self.pictureScrollView.frame.size.width*i, 0, self.pictureScrollView.frame.size.width, self.pictureScrollView.frame.size.height)];
                
                //UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(10, 200, 100, 100)];
                
                //lab.text=@"scrollview";
                
                UIImageView *imagev=[[UIImageView alloc]initWithFrame:CGRectMake(marginHoriz, marginVert, sub.frame.size.width-2*marginHoriz, sub.frame.size.height-2*marginVert)];
                [imagev setContentMode:UIViewContentModeScaleAspectFit];
                
                
                int imageID = [[self.imageIDs objectAtIndex:i] intValue];
                
                UIActivityIndicatorView* pictureActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                
                pictureActivityView.center = sub.center;
                //CGRect frame = pictureActivityView.frame;
                //frame.origin.x = sub.frame.origin.x + 0.5* sub.frame.size.width
                
                [sub addSubview:imagev];
                [sub addSubview:pictureActivityView];
                [pictureActivityView startAnimating];
                
                [self addPictureWithID:imageID withImageView:imagev withActivityView:pictureActivityView];
                
                [self.pictureScrollView addSubview:sub];
                
            }
            
            [self.pictureScrollView setContentSize:CGSizeMake(self.pictureScrollView.frame.size.width*imgCount, self.pictureScrollView.frame.size.height)];
            
            self.pictureScrollView.delegate=self;
            
            
            
        }
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    if (sender == self.pictureScrollView) {
        CGFloat pageWidth = self.pictureScrollView.frame.size.width;
        int page = floor((self.pictureScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        self.pageControl.currentPage = page;
    }
}

-  (void)addPictureWithID:(int)imageID withImageView:(UIImageView*)imageView withActivityView:(UIActivityIndicatorView*)pictureActivityView {
    [pictureActivityView startAnimating];
    [Api downloadImageDataAsynchronouslyWithId:imageID withStyle:@"original" withSuccess:^(NSDictionary * result) {
        imageView.image = [UIImage imageWithData:[result objectForKey:@"image"]];
        [pictureActivityView stopAnimating];
        [pictureActivityView setHidden:true];
    } withFailure:^(NSError * err) {
        imageView.image = [UIImage imageNamed:@"NoPic.png"];
        [pictureActivityView stopAnimating];
        [pictureActivityView setHidden:true];
    }];
    
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
