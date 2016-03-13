//
//  SMMyRecordViewController.m
//  SportsModule
//
//  Created by Hjf on 16/3/12.
//  Copyright © 2016年 xxn. All rights reserved.
//

#import "SMScoreBoardViewController.h"
#import "HJFSMTableViewCell.h"
#import "UISize.h"
#import "SMSize.h"

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
#define RTIMAGEVIEW_WIDTH   0.43*SCREEN_WIDTH
#define RTIMAGEVIEW_HEIGHT  0.43*SCREEN_WIDTH

@interface SMScoreBoardViewController() <UITableViewDataSource, UITableViewDelegate>
@end

@implementation SMScoreBoardViewController {
    UILabel     *timeLabel;  // 最近统计时间标签
    UILabel     *rankLabel;  // 我的排名标签
    UITableView *scoreBoardTableView;   // 积分列表
    UIImageView *rankTimeImageView;     // 排行筛选菜单
    UIView      *cover;                 // 显示菜单时的覆盖层
    UIView      *rightButtonView;       // 日排行按钮
    NSMutableArray *array;  //测试
}

- (id)init {
    if (self = [super init]) {
        timeLabel           = [[UILabel alloc] init];
        rankLabel           = [[UILabel alloc] init];
        scoreBoardTableView = [[UITableView alloc] init];
        rankTimeImageView   = [[UIImageView alloc] init];
        cover               = [[UIView alloc] init];
        array = [[NSMutableArray alloc] init];
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
    UIButton *buttonL = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0.8*RIGHTBUTTONVIEW_WIDTH, RIGHTBUTTONVIEW_HEIGHT)];
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
    [cover addGestureRecognizer:menuDismiss];
    
    rankTimeImageView.frame = CGRectMake(RTIMAGEVIEW_X, RTIMAGEVIEW_Y, RTIMAGEVIEW_WIDTH, 0);
//    rankTimeImageView.image = [UIImage imageNamed:@"下拉菜单"];
    rankTimeImageView.backgroundColor = [UIColor whiteColor];
    
    [cover addSubview:rankTimeImageView];
    [self.view addSubview:cover];
    
    [self NavigationInit];
}

#pragma mark - TableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier=@"UITableViewCellIdentifierKey1";
    HJFSMTableViewCell *cell;
    cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell){
        cell=[[HJFSMTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.score = [array objectAtIndex:indexPath.row];
    cell.rankLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
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
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    HJFSMTableViewCell *cell = [[HJFSMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    cell.score = [[HJFSMScore alloc] init];
    NSLog(@"%f", cell.height);
    return cell.height;
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
    [UIView animateWithDuration:1.0f
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
                     }];
    [UIView commitAnimations];
}

- (void)hiddenRankTimeMenu {
    CGRect imageRect = rankTimeImageView.frame;
    imageRect.size.width = RTIMAGEVIEW_WIDTH;
    imageRect.size.height = 0;
    [UIView animateWithDuration:1.0f
                          delay:0.05f
         usingSpringWithDamping:1.0
          initialSpringVelocity:4.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         rankTimeImageView.frame = imageRect;
                         cover.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         cover.hidden = YES;
                     }];
    [UIView commitAnimations];
}

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor grayColor];
    [self UILayout];
    for (int i = 0; i < 7; i++) {
        NSDictionary *dic = @{@"userName":@"张三",@"userScore":@"1234"};
        HJFSMScore *score = [[HJFSMScore alloc] initWithDict:dic];
        [array addObject:score];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [rightButtonView removeFromSuperview];
}

@end
