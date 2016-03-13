//
//  HJFSMTableViewCell.h
//  SportsModule
//
//  Created by Hjf on 16/3/12.
//  Copyright © 2016年 xxn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HJFSMScore.h"

@interface HJFSMTableViewCell : UITableViewCell

@property (nonatomic, strong) HJFSMScore *score;
@property (nonatomic, assign) CGFloat     height;
@property (nonatomic, strong) UILabel       *rankLabel;     // 名字标签
@property (nonatomic, strong) UIImageView   *rankImageView; // 名次图像
@property (nonatomic, strong) UIImageView   *userImageView;     // 用户头像

@end
