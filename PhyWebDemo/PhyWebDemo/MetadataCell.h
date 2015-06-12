//
//  MetadataCell.h
//  PhyWebDemo
//
//  Created by Lyo Kato on 2015/06/12.
//  Copyright (c) 2015年 Lyo Kato. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Metadata.h"

@interface MetadataCell : UITableViewCell
@property (nonatomic, strong) Metadata *metadata;
- (void)configure;
@end
