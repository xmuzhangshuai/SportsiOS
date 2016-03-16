//
//  HJFSMRTTableViewCell.m
//  SportsModule
//
//  Created by Hjf on 16/3/14.
//  Copyright © 2016年 xxn. All rights reserved.
//

#import "HJFSMRTTableViewCell.h"

@implementation HJFSMRTTableViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat imageViewWidth = self.imageView.frame.size.width;
    CGFloat imageViewX = self.imageView.frame.origin.x;
    CGFloat imageViewY = self.imageView.frame.origin.y;
    CGFloat imageViewHeight = self.imageView.frame.size.height;
    self.imageView.frame = CGRectMake(imageViewX+imageViewWidth, imageViewY, imageViewWidth, imageViewHeight);
    
    CGFloat textLabelWidth = self.textLabel.frame.size.width;
    CGFloat textLabelHeight = self.textLabel.frame.size.height;
    CGFloat textLabelX  = self.textLabel.frame.origin.x;
    CGFloat textLabelY = self.textLabel.frame.origin.y;
    self.textLabel.frame = CGRectMake(textLabelX*1.5, textLabelY, textLabelWidth, textLabelHeight);
}

@end
