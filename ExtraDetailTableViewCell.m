//
//  ExtraDetailTableViewCell.m
//  Parkify
//
//  Created by Me on 10/26/12.
//
//

#import "ExtraDetailTableViewCell.h"

@implementation ExtraDetailTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect origFrame = self.contentView.frame;
    
    self.textLabel.frame = CGRectMake(10, 2, origFrame.size.width-20, 22);
    self.detailTextLabel.frame = CGRectMake(10, 24, origFrame.size.width-20, origFrame.size.height - 26);
    self.detailTextLabel.numberOfLines = 0;
    
}

@end
