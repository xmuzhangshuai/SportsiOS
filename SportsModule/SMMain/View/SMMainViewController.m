//
//  SMMainViewController.m
//  SportsModule
//
//  Created by Hjf on 16/3/11.
//  Copyright © 2016年 xxn. All rights reserved.
//

#import "SMMainViewController.h"
#import "UISize.h"
#import "SMSize.h"
#import "SMScoreBoardViewController.h"
#import "SMMyRecordViewController.h"
#import "SMSportsViewController.h"

#define SPORTTIME_CENTER_Y      0.23*SCREEN_HEIGHT
#define SPORTDISTANCE_CENTER_Y  0.4*SCREEN_HEIGHT

#define DETAILSTIME_CENTER_Y    0.3*SCREEN_HEIGHT
#define DETAILSTIME_WIDTH       SCREEN_WIDTH
#define DETAILSTIME_HEIFHT      BLACKBUTTON_HEIGHT*1.1

#define DETAILSDISTANCE_CENTER_Y    0.47*SCREEN_HEIGHT

#define KBUTTON_CENTER_Y        0.82*SCREEN_HEIGHT
#define KBUTTON_WIDTH           0.274*SCREEN_WIDTH

#define LOGOUTBUTTON_HEIGHT     0.07*SCREEN_HEIGHT

#pragma mark - 运动方式选择模块
#define BUTTON_WIDTH            0.66*KBUTTON_WIDTH
#define ARROW_WIDTH             0.05*SCREEN_HEIGHT
#define RUNBUTTON_CENTER_Y      0.288*SCREEN_HEIGHT
#define WALKBUTTON_CENTER_Y     0.45*SCREEN_HEIGHT
#define BIKEBUTTON_CENTER_Y     0.61*SCREEN_HEIGHT
#define ARROW_CENTER_Y          0.705*SCREEN_HEIGHT
#define SCALE                   0.185*SCREEN_WIDTH
#define ARROW_SCALE             0.065*SCREEN_WIDTH

@implementation SMMainViewController {
    UILabel     *sportTime;         //  总运动时间
    UILabel     *sportDistance;     //  总运动里程
    UILabel     *detailsTime;       //  具体时间
    UILabel     *detailsDistance;   //  具体里程
    UIButton    *KButton;           //  k按钮
    UIButton    *logoutButton;      //  登出按钮
    
    // 选择运动方式模块
    UIView      *cover;             //  覆盖半透明层
    UIButton    *runButton;
    UIButton    *walkButton;
    UIButton    *bikeButton;
    UIImageView *arrowImageView;     // 箭头图片
}

- (id)init {
    if (self = [super init]) {
        sportTime       = [[UILabel alloc] init];
        sportDistance   = [[UILabel alloc] init];
        detailsTime     = [[UILabel alloc] init];
        detailsDistance = [[UILabel alloc] init];
        KButton         = [[UIButton alloc] init];
        logoutButton    = [[UIButton alloc] init];
        
        cover           = [[UIView alloc] init];
        runButton       = [[UIButton alloc] init];
        walkButton      = [[UIButton alloc] init];
        bikeButton      = [[UIButton alloc] init];
        arrowImageView  = [[UIImageView alloc] init];
    }
    return self;
}



#pragma mark - 导航栏初始化
- (void)NavigationInit {
    self.navigationItem.title = @"主界面";
    // 我的记录按钮
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"我的记录图标"] style:UIBarButtonItemStylePlain target:self action:@selector(toMyRecord)];
    leftButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = leftButton;
    // 积分榜按钮
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"积分榜图标"] style:UIBarButtonItemStylePlain target:self action:@selector(toScoreBoard)];
    rightButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = rightButton;
}

#pragma mark - 控件布局
- (void)UILayout {
    sportTime.frame = CGRectMake(0, 0, BLACKBUTTON_WIDTH, BLACKBUTTON_HEIGHT);
    sportTime.center = CGPointMake(CENTER_X, SPORTTIME_CENTER_Y);
    sportTime.backgroundColor = [UIColor blackColor];
    sportTime.text = @"总运动时间";
    sportTime.textAlignment = NSTextAlignmentCenter;
    sportTime.textColor = [UIColor whiteColor];
    sportTime.clipsToBounds = YES;
    sportTime.layer.cornerRadius = CORNER_REDIUS;
    
    sportDistance.frame = CGRectMake(0, 0, BLACKBUTTON_WIDTH, BLACKBUTTON_HEIGHT);
    sportDistance.center = CGPointMake(CENTER_X, SPORTDISTANCE_CENTER_Y);
    sportDistance.backgroundColor = [UIColor blackColor];
    sportDistance.text = @"总运动里程";
    sportDistance.textAlignment = NSTextAlignmentCenter;
    sportDistance.textColor = [UIColor whiteColor];
    sportDistance.clipsToBounds = YES;
    sportDistance.layer.cornerRadius = CORNER_REDIUS;
    
    detailsTime.frame = CGRectMake(0, 0, DETAILSTIME_WIDTH, DETAILSTIME_HEIFHT);
    detailsTime.center = CGPointMake(CENTER_X, DETAILSTIME_CENTER_Y);
    detailsTime.text = @"8小时23分钟";
    detailsTime.textAlignment = NSTextAlignmentCenter;
    
    detailsDistance.frame = CGRectMake(0, 0, DETAILSTIME_WIDTH, DETAILSTIME_HEIFHT);
    detailsDistance.center = CGPointMake(CENTER_X, DETAILSDISTANCE_CENTER_Y);
    detailsDistance.text = @"62.8公里";
    detailsDistance.textAlignment = NSTextAlignmentCenter;
    
    KButton.frame = CGRectMake(0, 0, KBUTTON_WIDTH, KBUTTON_WIDTH);
    KButton.center = CGPointMake(CENTER_X, KBUTTON_CENTER_Y);
    [KButton setImage:[UIImage imageNamed:@"K图标"] forState:UIControlStateNormal];
    [KButton addTarget:self action:@selector(toSportChoice) forControlEvents:UIControlEventTouchUpInside];
    
    logoutButton.frame = CGRectMake(0, SCREEN_HEIGHT-LOGOUTBUTTON_HEIGHT, SCREEN_WIDTH, LOGOUTBUTTON_HEIGHT);
    logoutButton.backgroundColor = [UIColor colorWithRed:230/255.0 green:0 blue:18/255.0 alpha:1.0];
    [logoutButton setTitle:@"登出" forState:UIControlStateNormal];
    [logoutButton addTarget:self action:@selector(toLoginView) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:sportTime];
    [self.view addSubview:sportDistance];
    [self.view addSubview:detailsTime];
    [self.view addSubview:detailsDistance];
    [self.view addSubview:KButton];
    [self.view addSubview:logoutButton];
    
    // 选择运动方式模块
    cover.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    cover.backgroundColor = [UIColor blackColor];
    cover.alpha = 0;
    cover.hidden = YES;
    UITapGestureRecognizer *choiceViewDismissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(choiceViewDismiss)];
    [cover addGestureRecognizer:choiceViewDismissTap];
    
    runButton.frame = CGRectMake(0, 0, 1, 1);
    runButton.center = CGPointMake(CENTER_X, RUNBUTTON_CENTER_Y);
    [runButton setImage:[UIImage imageNamed:@"跑图标"] forState:UIControlStateNormal];
    [runButton setImage:[UIImage imageNamed:@"跑图标(点击状态)"] forState:UIControlStateHighlighted];
    runButton.backgroundColor = [UIColor clearColor];
    [runButton addTarget:self action:@selector(chooseRun) forControlEvents:UIControlEventTouchUpInside];
    
    walkButton.frame = CGRectMake(0, 0, 1, 1);
    walkButton.center = CGPointMake(CENTER_X, WALKBUTTON_CENTER_Y);
    [walkButton setImage:[UIImage imageNamed:@"走图标"] forState:UIControlStateNormal];
    [walkButton setImage:[UIImage imageNamed:@"走图标(点击状态)"] forState:UIControlStateHighlighted];
    [walkButton addTarget:self action:@selector(chooseWalk) forControlEvents:UIControlEventTouchUpInside];
    
    bikeButton.frame = CGRectMake(0, 0, 1, 1);
    bikeButton.center = CGPointMake(CENTER_X, BIKEBUTTON_CENTER_Y);
    [bikeButton setImage:[UIImage imageNamed:@"骑图标"] forState:UIControlStateNormal];
    [bikeButton setImage:[UIImage imageNamed:@"骑图标(点击状态)"] forState:UIControlStateHighlighted];
    [bikeButton addTarget:self action:@selector(chooseBike) forControlEvents:UIControlEventTouchUpInside];
    
    arrowImageView.frame = CGRectMake(0, 0, 1, 1);
    arrowImageView.center = CGPointMake(CENTER_X, ARROW_CENTER_Y);
    arrowImageView.image = [UIImage imageNamed:@"展开图标"];
    
    [cover addSubview:runButton];
    [cover addSubview:walkButton];
    [cover addSubview:bikeButton];
    [cover addSubview:arrowImageView];
    [self.view addSubview:cover];
    
    [self NavigationInit];
}

#pragma mark - 私有方法
- (void)toSportChoice {
    [self showMenu];
}

- (void)showMenu {
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:1.0
          initialSpringVelocity:4.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         cover.hidden = NO;
                         cover.alpha = 0.8;
                         runButton.transform = CGAffineTransformMakeScale(SCALE, SCALE);
                         walkButton.transform = CGAffineTransformMakeScale(SCALE, SCALE);
                         bikeButton.transform = CGAffineTransformMakeScale(SCALE, SCALE);
                         arrowImageView.transform = CGAffineTransformMakeScale(ARROW_SCALE, ARROW_SCALE);
                     } completion:^(BOOL finished){
                     }];
    [UIView commitAnimations];
}

- (void)hiddenMenu {
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:1.0
          initialSpringVelocity:4.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         cover.alpha = 0;
                         runButton.transform = CGAffineTransformIdentity;
                         walkButton.transform = CGAffineTransformIdentity;
                         bikeButton.transform = CGAffineTransformIdentity;
                         arrowImageView.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished){
                         cover.hidden = YES;
                     }];
    [UIView commitAnimations];
}

- (void)choiceViewDismiss {
    [self hiddenMenu];
}

- (void)chooseRun {
    SMSportsViewController *sportsViewController = [[SMSportsViewController alloc] initWithSport:@"跑"];
    [self.navigationController pushViewController:sportsViewController animated:YES];
}

- (void)chooseWalk {
    SMSportsViewController *sportViewController = [[SMSportsViewController alloc] initWithSport:@"走"];
    [self.navigationController pushViewController:sportViewController animated:YES];
}

- (void)chooseBike {
    SMSportsViewController *sportViewController = [[SMSportsViewController alloc] initWithSport:@"骑"];
    [self.navigationController pushViewController:sportViewController animated:YES];
}

- (void)toLoginView {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)toMyRecord {
    SMMyRecordViewController *myRecordViewController = [[SMMyRecordViewController alloc] init];
    [self.navigationController pushViewController:myRecordViewController animated:YES];
}

- (void)toScoreBoard {
    SMScoreBoardViewController *scoreBoardViewController = [[SMScoreBoardViewController alloc] init];
    [self.navigationController pushViewController:scoreBoardViewController animated:YES];
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    [self UILayout];
    self.extendedLayoutIncludesOpaqueBars = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UINavigationBar appearance].translucent = NO;
}
@end
