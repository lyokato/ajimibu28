//
//  MetadataCell.m
//  PhyWebDemo
//
//  Created by Lyo Kato on 2015/06/12.
//  Copyright (c) 2015年 Lyo Kato. All rights reserved.
//

#import "MetadataCell.h"
#import "SDWebImageOperation.h"
#import "SDWebImageManager.h"

#import <QuartzCore/QuartzCore.h>

#define IMAGE_HEIGHT 70
#define IMAGE_WIDTH 70

@interface MetadataCell ()
@property (nonatomic, weak) id<SDWebImageOperation> imageOperation;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UIImageView *thumbnailView;
@end

@implementation MetadataCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self setupTitleLabel];
        [self setupDescriptionLabel];
        [self setupThumbnail];
    }
    return self;
}

- (void)setupTitleLabel
{
    CGRect r = CGRectMake(IMAGE_WIDTH + 10, 5, 250, 30);
    UILabel *v = [[UILabel alloc] initWithFrame:r];
    v.numberOfLines = 1;
    v.textAlignment = NSTextAlignmentLeft;
    v.textColor = UIColor.grayColor;
    v.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:14];
    [self addSubview:v];
    self.titleLabel = v;
}

- (void)setupDescriptionLabel
{
    CGRect r = CGRectMake(IMAGE_WIDTH + 10, 30, 250, 30);
    UILabel *v = [[UILabel alloc] initWithFrame:r];
    v.numberOfLines = 1;
    v.textAlignment = NSTextAlignmentLeft;
    v.textColor = UIColor.grayColor;
    v.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:14];
    [self addSubview:v];
    self.descriptionLabel = v;
}

- (void)setupThumbnail
{
    UIImage *image = [UIImage imageNamed:@"demo"];
    UIImageView *iv = [[UIImageView alloc] initWithImage:image];
    iv.frame = CGRectMake(5, 5, IMAGE_WIDTH, IMAGE_HEIGHT);
    [self addSubview:iv];
    self.thumbnailView = iv;
    iv.clipsToBounds = YES;
    iv.contentMode = UIViewContentModeScaleAspectFill;
    iv.layer.cornerRadius = 6.0;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    if (self.imageOperation) {
        [self.imageOperation cancel];
    }
    self.imageOperation = nil;
}

- (void)configure
{
    self.titleLabel.text = self.metadata.title;
    self.descriptionLabel.text = self.metadata.desc;
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    self.imageOperation = [manager downloadImageWithURL:[NSURL URLWithString:self.metadata.iconUrl]
                                                options:SDWebImageRetryFailed
                                               progress:nil
                                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished  , NSURL *imageURL) {
                                                  //self.thumbnailView.hidden = NO;
                                                  self.thumbnailView.image = image;
                                                  
                                              }];
}

@end
