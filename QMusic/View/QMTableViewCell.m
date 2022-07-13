//
//  QMTableViewCell.m
//  QMusic
//
//  Created by JiangNan on 2022/4/3.
//  Copyright © 2022 NanJiang. All rights reserved.
//

#import "QMTableViewCell.h"

@implementation QMTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// 将图片调整到合适的大小和位置
- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, 58, 58);
    self.imageView.center = CGPointMake(60, 40);
}

@end
