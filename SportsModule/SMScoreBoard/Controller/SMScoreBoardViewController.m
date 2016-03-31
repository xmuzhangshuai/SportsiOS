//
//  SMMyRecordViewController.m
//  SportsModule
//
//  Created by Hjf on 16/3/12.
//  Copyright © 2016年 xxn. All rights reserved.
//

#import "SMScoreBoardViewController.h"
#import "HJFSMTableViewCell.h"
#import "HJFSMRTTableViewCell.h"
#import "UISize.h"
#import "SMSize.h"
#import "HJFActivityIndicatorView.h"

/** leancloud */
#import "AVOSCloud/AVOSCloud.h"



#define TIMELABEL_X         0
#define TIMELABEL_Y         STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT
#define TIMELABEL_HEIGHT    0.03*SCREEN_HEIGHT

#define RANKLABEL_CENTER_Y  0.135*SCREEN_HEIGHT

#define TABLEVIEW_X         0.012*SCREEN_WIDTH
#define TABLEVIEW_Y         TIMELABEL_Y+TIMELABEL_HEIGHT*2
#define TABLEVIEW_WIDTH     0.976*SCREEN_WIDTH
#define TABLEVIEW_HEIGHT    0.86*SCREEN_HEIGHT

#define RIGHTBUTTONVIEW_X   0.75*SCREEN_WIDTH
#define RIGHTBUTTONVIEW_Y   0.3*NAVIGATIONBAR_HEIGHT
#define RIGHTBUTTONVIEW_WIDTH   0.2*SCREEN_WIDTH
#define RIGHTBUTTONVIEW_HEIGHT  0.5*NAVIGATIONBAR_HEIGHT

#define RTIMAGEVIEW_X       0.54*SCREEN_WIDTH
#define RTIMAGEVIEW_Y       STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT+10
#define RTIMAGEVIEW_WIDTH   0.389*SCREEN_WIDTH
#define RTIMAGEVIEW_HEIGHT  0.209*SCREEN_HEIGHT

#define RTTABLEVIEW_X       0*RTIMAGEVIEW_WIDTH
#define RTTABLEVIEW_Y       0.111*RTIMAGEVIEW_HEIGHT
#define RTTABLEVIEW_WIDTH   RTIMAGEVIEW_WIDTH
#define RTTABLEVIEW_HEIGHT  0.889*RTIMAGEVIEW_HEIGHT

@interface SMScoreBoardViewController() <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
@end

@implementation SMScoreBoardViewController {
    UILabel     *timeLabel;  // 最近统计时间标签
    UILabel     *rankLabel;  // 我的排名标签
    UITableView *scoreBoardTableView;   // 积分列表
    UIImageView *rankTimeImageView;     // 排行筛选菜单
    UITableView *rankTimeTableView;     // 排行筛选列表
    NSArray     *rankTimeArray;         // 排行筛选选项
    UIView      *cover;                 // 显示菜单时的覆盖层
    UIView      *rightButtonView;       // 日排行按钮
    NSString    *rankTimeStr;           // 记录当前是什么排行 如果选择当前排行则不需要请求缓存
    UIButton    *buttonL;               // 显示日排行按钮，设置成成员变量
    NSMutableArray *rankArray;          // 存储排名信息
    HJFActivityIndicatorView *activityIndicatorView;    // 等待动画
    BOOL        isShow;                 // 判断是否viewDidLoad过，不重复加载界面
    NSUInteger  myRank;                 // 记录当前用户排名
    NSUserDefaults  *userDefaults;
}

- (id)init {
    if (self = [super init]) {
        timeLabel           = [[UILabel alloc] init];
        rankLabel           = [[UILabel alloc] init];
        scoreBoardTableView = [[UITableView alloc] init];
        rankTimeImageView   = [[UIImageView alloc] init];
        rankTimeTableView   = [[UITableView alloc] init];
        rankTimeArray       = @[@"日排行", @"周排行", @"月排行", @"年排行"];
        cover               = [[UIView alloc] init];
        rankArray           = [[NSMutableArray alloc] init];
        rankTimeStr         = @"日排行";
        isShow              = NO;
        userDefaults        = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

#pragma mark - 导航栏初始化
- (void)NavigationInit {
    self.navigationItem.title = @"积分榜";
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回图标"] style:UIBarButtonItemStylePlain target:self action:@selector(backToMainView)];
    leftButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = leftButton;
    
//    UIBarButtonItem *rightButtonL = [[UIBarButtonItem alloc] initWithTitle:@"日排行" style:UIBarButtonItemStylePlain target:self action:@selector(choiceRankTime)];
//    rightButtonL.tintColor = [UIColor whiteColor];
//    UIBarButtonItem *rightButtonR = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"下拉菜单图标"] style:UIBarButtonItemStylePlain target:self action:@selector(choiceRankTime)];
//    NSArray *buttonArray = @[rightButtonR, rightButtonL];
//    self.navigationItem.rightBarButtonItems = buttonArray;
    rightButtonView = [[UIView alloc] initWithFrame:CGRectMake(RIGHTBUTTONVIEW_X, RIGHTBUTTONVIEW_Y, RIGHTBUTTONVIEW_WIDTH, RIGHTBUTTONVIEW_HEIGHT)];
    buttonL = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0.8*RIGHTBUTTONVIEW_WIDTH, RIGHTBUTTONVIEW_HEIGHT)];
    [buttonL setTitle:@"日排行" forState:UIControlStateNormal];
    buttonL.titleLabel.font = [UIFont systemFontOfSize:15];
    [buttonL addTarget:self action:@selector(choiceRankTime) forControlEvents:UIControlEventTouchUpInside];
    [rightButtonView addSubview:buttonL];
    
    UIButton *buttonR = [[UIButton alloc] initWithFrame:CGRectMake(0.816*RIGHTBUTTONVIEW_WIDTH, 0, 0.184*RIGHTBUTTONVIEW_WIDTH, RIGHTBUTTONVIEW_HEIGHT)];
    [buttonR setImage:[UIImage imageNamed:@"下拉菜单图标"] forState:UIControlStateNormal];
    [buttonR addTarget:self action:@selector(choiceRankTime) forControlEvents:UIControlEventTouchUpInside];
    [rightButtonView addSubview:buttonR];
    
    [self.navigationController.navigationBar addSubview:rightButtonView];
}

#pragma mark - 控件布局
- (void)UILayout {
    timeLabel.frame = CGRectMake(TIMELABEL_X, TIMELABEL_Y, SCREEN_WIDTH, TIMELABEL_HEIGHT);
    timeLabel.text = @"最近统计时间：";
    timeLabel.font = [UIFont systemFontOfSize:10];
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    
    rankLabel.frame = CGRectMake(TIMELABEL_X, TIMELABEL_Y+TIMELABEL_HEIGHT, SCREEN_WIDTH, TIMELABEL_HEIGHT);
    rankLabel.text = @"我的排名：";
    rankLabel.font = [UIFont systemFontOfSize:10];
    rankLabel.textColor = [UIColor whiteColor];
    rankLabel.textAlignment = NSTextAlignmentCenter;
    
    scoreBoardTableView.frame = CGRectMake(TABLEVIEW_X, TABLEVIEW_Y, TABLEVIEW_WIDTH, TABLEVIEW_HEIGHT);
    scoreBoardTableView.tag = 0;
    scoreBoardTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    scoreBoardTableView.delegate = self;
    scoreBoardTableView.dataSource = self;
    scoreBoardTableView.clipsToBounds = YES;
    scoreBoardTableView.layer.cornerRadius = 8;
    
    [self.view addSubview:timeLabel];
    [self.view addSubview:rankLabel];
    [self.view addSubview:scoreBoardTableView];
    
    // 菜单模块
    cover.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    cover.backgroundColor = [UIColor blackColor];
    cover.alpha = 0;
    cover.hidden = YES;
    UITapGestureRecognizer *menuDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenRankTimeMenu)];
    menuDismiss.delegate = self;
    [cover addGestureRecognizer:menuDismiss];
    
    rankTimeImageView.frame = CGRectMake(RTIMAGEVIEW_X, RTIMAGEVIEW_Y, RTIMAGEVIEW_WIDTH, 0);
    rankTimeImageView.userInteractionEnabled = YES;
    rankTimeImageView.image = [UIImage imageNamed:@"下拉菜单"];
    
    rankTimeTableView.frame = CGRectMake(RTTABLEVIEW_X, RTTABLEVIEW_Y, RTTABLEVIEW_WIDTH, RTTABLEVIEW_HEIGHT);
    rankTimeTableView.tag = 1;
    rankTimeTableView.backgroundColor = [UIColor clearColor];
    rankTimeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    rankTimeTableView.hidden = YES;
    rankTimeTableView.delegate = self;
    rankTimeTableView.dataSource = self;
    [rankTimeImageView addSubview:rankTimeTableView];
    
    [cover addSubview:rankTimeImageView];
    [self.view addSubview:cover];
    

}

#pragma mark - TableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 0) {
        return rankArray.count;
    }else {
        return 4;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 0) {
        static NSString *cellIdentifier=@"UITableViewCellIdentifierKey1";
        HJFSMTableViewCell *cell;
        cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(!cell){
            cell=[[HJFSMTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.score = [rankArray objectAtIndex:indexPath.row];
        cell.rankLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
        cell.rankLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row+1];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row == 0) {
            cell.rankImageView.image = [UIImage imageNamed:@"第一名图标"];
        }else if (indexPath.row == 1) {
            cell.rankImageView.image = [UIImage imageNamed:@"第二名图标"];
        }else if (indexPath.row == 2) {
            cell.rankImageView.image = [UIImage imageNamed:@"第三名图标"];
        }
        
        return cell;
    }else {
        static NSString *cellIdentifier = @"UITableViewCellIdentifierKey2";
        HJFSMRTTableViewCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[HJFSMRTTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        if (!(indexPath.row == 3)) {
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"下拉菜单分割线"]];
        }
        cell.backgroundView.contentMode = UIViewContentModeBottom;
        cell.textLabel.text = [rankTimeArray objectAtIndex:indexPath.row];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row == 0) {
            cell.imageView.image = [UIImage imageNamed:@"选中状态图标"];
        }else {
            cell.imageView.image = [UIImage imageNamed:@"未选中状态图标"];
        }
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 0) {
        HJFSMTableViewCell *cell = [[HJFSMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
        cell.score = [[HJFSMScore alloc] init];
        return cell.height;
    }else {
        return 0.045*SCREEN_HEIGHT;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 1) {
        if (indexPath.row == 0) {
            if (![rankTimeStr isEqualToString:@"日排行"]) {
                // 更新积分榜 日排行
                HJFSMRTTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                cell.imageView.image = [UIImage imageNamed:@"选中状态图标"];
                [buttonL setTitle:@"日排行" forState:UIControlStateNormal];
                rankTimeStr = @"日排行";
                // 设置其他图标为未选中图标
                for (int i = 0; i < 4; i++) {
                    NSIndexPath *myIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    if (!(myIndexPath.row == indexPath.row)) {
                        HJFSMRTTableViewCell *cell = [tableView cellForRowAtIndexPath:myIndexPath];
                        cell.imageView.image = [UIImage imageNamed:@"未选中状态图标"];
                    }
                }
                [self loadRankData:1];
            }
        }else if (indexPath.row == 1) {
            if (![rankTimeStr isEqualToString:@"周排行"]) {
                // 更新积分榜 周排行
                HJFSMRTTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                cell.imageView.image = [UIImage imageNamed:@"选中状态图标"];
                [buttonL setTitle:@"周排行" forState:UIControlStateNormal];
                rankTimeStr = @"周排行";
                // 设置其他图标为未选中图标
                for (int i = 0; i < 4; i++) {
                    NSIndexPath *myIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    if (!(myIndexPath.row == indexPath.row)) {
                        HJFSMRTTableViewCell *cell = [tableView cellForRowAtIndexPath:myIndexPath];
                        cell.imageView.image = [UIImage imageNamed:@"未选中状态图标"];
                    }
                }
                [self loadRankData:2];
            }
        }else if (indexPath.row == 2) {
            if (![rankTimeStr isEqualToString:@"月排行"]) {
                // 更新积分榜 月排行
                HJFSMRTTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                cell.imageView.image = [UIImage imageNamed:@"选中状态图标"];
                [buttonL setTitle:@"月排行" forState:UIControlStateNormal];
                rankTimeStr = @"月排行";
                // 设置其他图标为未选中图标
                for (int i = 0; i < 4; i++) {
                    NSIndexPath *myIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    if (!(myIndexPath.row == indexPath.row)) {
                        HJFSMRTTableViewCell *cell = [tableView cellForRowAtIndexPath:myIndexPath];
                        cell.imageView.image = [UIImage imageNamed:@"未选中状态图标"];
                    }
                }
                [self loadRankData:3];
            }
        }else if (indexPath.row == 3) {
            if (![rankTimeStr isEqualToString:@"年排行"]) {
                // 更新积分榜 年排行
                HJFSMRTTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                cell.imageView.image = [UIImage imageNamed:@"选中状态图标"];
                [buttonL setTitle:@"年排行" forState:UIControlStateNormal];
                rankTimeStr = @"年排行";
                // 设置其他图标为未选中图标
                for (int i = 0; i < 4; i++) {
                    NSIndexPath *myIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    if (!(myIndexPath.row == indexPath.row)) {
                        HJFSMRTTableViewCell *cell = [tableView cellForRowAtIndexPath:myIndexPath];
                        cell.imageView.image = [UIImage imageNamed:@"未选中状态图标"];
                    }
                }
            }
            [self loadRankData:4];
        }
        [self hiddenRankTimeMenu];
    }
}

#pragma mark - UIGesture代理
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}

#pragma mark - 私有方法
- (void)backToMainView {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)choiceRankTime {
    [self showRankTimeMenu];
}

- (void)showRankTimeMenu {
    CGRect imageRect = rankTimeImageView.frame;
    imageRect.size.height = RTIMAGEVIEW_HEIGHT;
    imageRect.size.width = RTIMAGEVIEW_WIDTH;
    [UIView animateWithDuration:0.5f
                          delay:0.05f
         usingSpringWithDamping:1.0
          initialSpringVelocity:4.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         cover.alpha = 0.8;
                         cover.hidden = NO;
                         rankTimeImageView.frame = imageRect;
                     }
                     completion:^(BOOL finished){
                         rankTimeTableView.hidden = NO;
                     }];
    [UIView commitAnimations];
}

- (void)hiddenRankTimeMenu {
    CGRect imageRect = rankTimeImageView.frame;
    imageRect.size.width = RTIMAGEVIEW_WIDTH;
    imageRect.size.height = 0;
    [UIView animateWithDuration:0.5f
                          delay:0.05f
         usingSpringWithDamping:1.0
          initialSpringVelocity:4.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         rankTimeTableView.hidden = YES;
                         rankTimeImageView.frame = imageRect;
                         cover.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         cover.hidden = YES;
                     }];
    [UIView commitAnimations];
}

- (void)loadRankData:(int)filter {
    activityIndicatorView = [[HJFActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 0.3*SCREEN_WIDTH, 0.8*0.3*SCREEN_WIDTH) andViewAlpha:0.8 andCornerRadius:8];
    activityIndicatorView.center = self.view.center;
    [self.view addSubview:activityIndicatorView];
    NSNumber *typeNumber = [[NSNumber alloc] initWithInt:1];
    NSNumber *unitNumber = [[NSNumber alloc] initWithInt:filter];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:typeNumber, @"type", unitNumber, @"unit" , nil];
    [AVCloud callFunctionInBackground:@"GetUserTopList" withParameters:dict block:^(id object, NSError *error) {
        NSNumber *resultCode = object[@"resultCode"];
        if ([resultCode intValue] == 200) {
            // 获取成功
            NSArray *infoArray = object[@"info"];
            if (rankArray.count != 0) {
                [rankArray removeAllObjects];
            }
            [infoArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *userId = obj[@"userId"];
                if ([userId isEqualToString:[userDefaults objectForKey:@"userId"]]) {
                    myRank = idx;
                }
                NSNumber *integral = obj[@"integral"];
                NSString *userScore = [NSString stringWithFormat:@"%d", [integral intValue]];
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      obj[@"userName"],@"userName",
                                      userScore, @"userScore",
                                      obj[@"portrait"], @"userPicUrl", nil];
                HJFSMScore *score = [HJFSMScore scoreWithDict:dict];
                [rankArray addObject:score];
            }];
            [activityIndicatorView removeFromSuperview];
            if (!isShow) {
                [self UILayout];
                isShow = YES;
            }
            [scoreBoardTableView reloadData];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *time = [df stringFromDate:[NSDate date]];
            timeLabel.text = [NSString stringWithFormat:@"最近统计时间：%@", time];
            if (myRank > 100) {
                rankLabel.text = [NSString stringWithFormat:@"我的排名：榜外"];
            }else {
                rankLabel.text = [NSString stringWithFormat:@"我的排名：%lu", (unsigned long)myRank+1];
            }
        }else {
            [activityIndicatorView removeFromSuperview];
            if (!isShow) {
                [self UILayout];
                isShow = YES;
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:object[@"errorMessage"] delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor colorWithRed:88/255.0 green:89/255.0 blue:91/255.0 alpha:1.0];
    self.extendedLayoutIncludesOpaqueBars = YES;
    [self NavigationInit];
    [self loadRankData:1];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [rightButtonView removeFromSuperview];
}

@end
