//
//  HJFSMTableViewCell.m
//  SportsModule
//
//  Created by Hjf on 16/3/12.
//  Copyright © 2016年 xxn. All rights reserved.
//

#import "HJFSMTableViewCell.h"
#import "UISize.h"
#import "SMSize.h"
/** sdwebimage */
#import "UIImageView+WebCache.h"

#define CELL_HEIGHT     0.14*SCREEN_HEIGHT
#define RANKLABEL_X     0.08*SCREEN_WIDTH
#define RANKLABEL_Y     0.063*SCREEN_HEIGHT
#define RANKLABEL_WIDTH 0.03*SCREEN_HEIGHT

#define USERIMAGEVIEW_X 2*RANKLABEL_X
#define USERIMAGEVIEW_Y 0.045*SCREEN_HEIGHT
#define USERIMAGEVIEW_WIDTH 0.065*SCREEN_HEIGHT

#define RANKIMAGEVIEW_X USERIMAGEVIEW_X+USERIMAGEVIEW_WIDTH/2-RANKIMAGEVIEW_WIDTH/3
#define RANKIMAGEVIEW_Y 0.021*SCREEN_HEIGHT
#define RANKIMAGEVIEW_WIDTH USERIMAGEVIEW_WIDTH
#define RANKIMAGEVIEW_HEIGHT    0.03*SCREEN_HEIGHT

#define USERNAMELABEL_CENTER_Y  0.49*CELL_HEIGHT
#define USERNAMELABEL_WIDTH     0.15*SCREEN_WIDTH
#define USERNAMELABEL_HEIGHT    0.9*CELL_HEIGHT

#define USERSCORELABEL_WIDTH    0.2*SCREEN_WIDTH
#define USERSCORELABEL_HEIGHT   USERNAMELABEL_HEIGHT*1.2
#define USERSCORELABEL_X        0.72*SCREEN_WIDTH
#define USERSCORELABEL_Y        0.9*CELL_HEIGHT

@interface HJFSMTableViewCell()



@end

@implementation HJFSMTableViewCell {
    UILabel     *userNameLabel;     // 用户名字
    UILabel     *userScoreLabel;    // 用户积分
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubView];
    }
    return self;
}

#pragma mark - 控件初始化
- (void)initSubView {
    _rankLabel = [[UILabel alloc] init];
    // 字体设置
    [self.contentView addSubview:_rankLabel];
    
    _rankImageView = [[UIImageView alloc] init];
    _rankImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_rankImageView];
    
    _userImageView = [[UIImageView alloc] init];
    _userImageView.clipsToBounds = YES;      // 将imageview设置成圆形
    _userImageView.layer.cornerRadius = USERIMAGEVIEW_WIDTH/2;
    _userImageView.backgroundColor = [UIColor grayColor];
    [self.contentView addSubview:_userImageView];
    
    userNameLabel = [[UILabel alloc] init];
    userNameLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:userNameLabel];
    
    userScoreLabel = [[UILabel alloc] init];
    userScoreLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:userScoreLabel];
}

#pragma mark - 设置空间布局以及赋值
- (void)setScore:(HJFSMScore *)score {
    _rankLabel.frame = CGRectMake(RANKLABEL_X, RANKLABEL_Y, RANKLABEL_WIDTH, RANKLABEL_WIDTH);
    
    _rankImageView.frame = CGRectMake(RANKIMAGEVIEW_X, RANKIMAGEVIEW_Y, RANKIMAGEVIEW_WIDTH, RANKIMAGEVIEW_HEIGHT);
    _rankImageView.contentMode = UIViewContentModeLeft;
    
    _userImageView.frame = CGRectMake(USERIMAGEVIEW_X, USERIMAGEVIEW_Y, USERIMAGEVIEW_WIDTH, USERIMAGEVIEW_WIDTH);
    [_userImageView sd_setImageWithURL:[NSURL URLWithString:score.userPicUrl]];

    
    userNameLabel.frame = CGRectMake(0, 0, USERNAMELABEL_WIDTH, USERNAMELABEL_HEIGHT);
    userNameLabel.center = CGPointMake(CENTER_X, USERNAMELABEL_CENTER_Y);
    userNameLabel.text = score.userName;
    
    userScoreLabel.frame = CGRectMake(USERSCORELABEL_X, USERSCORELABEL_Y, USERSCORELABEL_WIDTH, USERSCORELABEL_HEIGHT);
    userScoreLabel.center = CGPointMake(USERSCORELABEL_X+USERSCORELABEL_WIDTH/2, USERNAMELABEL_CENTER_Y);
    userScoreLabel.font = [UIFont systemFontOfSize:16];
    userScoreLabel.text = score.userScore;
    
    // 修改cell样式
    self.height = CELL_HEIGHT;
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"积分榜分割线"]];
    self.backgroundView.contentMode = UIViewContentModeBottom;
}

@end
