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
#import "AppDelegate.h"

#import <AVOSCloud/AVOSCloud.h>
#import <FMDB/FMDB.h>
#import "HJFActivityIndicatorView.h"

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
    int         sportType;          // 运动类型
    UIImageView *arrowImageView;     // 箭头图片

    HJFActivityIndicatorView *activityIndicatorView;
    
    AppDelegate *myAppDelegate;
    
    NSUserDefaults  *userDefaults;
    
    BOOL        isShow;             // 判断是否已经加载过视图
    NSTimeInterval totalTime;       // 总运动时间
    CGFloat     totalDistance;      // 总运动里程
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
        isShow          = NO;
        totalTime       = 0;
        totalDistance   = 0;
        
        // 判断是否正在运动
        myAppDelegate   = [[UIApplication sharedApplication] delegate];
        
        userDefaults    = [NSUserDefaults standardUserDefaults];
        if ([userDefaults boolForKey:@"isSport"] == YES) {
            [userDefaults setBool:[self IsSport] forKey:@"isSport"];
        }
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
    detailsTime.text = @"0小时0分钟";
    detailsTime.textAlignment = NSTextAlignmentCenter;
    
    detailsDistance.frame = CGRectMake(0, 0, DETAILSTIME_WIDTH, DETAILSTIME_HEIFHT);
    detailsDistance.center = CGPointMake(CENTER_X, DETAILSDISTANCE_CENTER_Y);
    detailsDistance.text = @"0公里";
    detailsDistance.textAlignment = NSTextAlignmentCenter;
    
    KButton.frame = CGRectMake(0, 0, KBUTTON_WIDTH, KBUTTON_WIDTH);
    KButton.center = CGPointMake(CENTER_X, KBUTTON_CENTER_Y);
    if (![userDefaults boolForKey:@"isSport"]) {
        [KButton setImage:[UIImage imageNamed:@"K图标"] forState:UIControlStateNormal];
        [KButton addTarget:self action:@selector(toSportChoice) forControlEvents:UIControlEventTouchUpInside];
    }else {
        [KButton setImage:[UIImage imageNamed:@"运动中图标"] forState:UIControlStateNormal];
        [KButton addTarget:self action:@selector(toMapView) forControlEvents:UIControlEventTouchUpInside];
    }
    
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
    [runButton addTarget:self action:@selector(gotosport2) forControlEvents:UIControlEventTouchUpInside];
    
    walkButton.frame = CGRectMake(0, 0, 1, 1);
    walkButton.center = CGPointMake(CENTER_X, WALKBUTTON_CENTER_Y);
    [walkButton setImage:[UIImage imageNamed:@"走图标"] forState:UIControlStateNormal];
    [walkButton setImage:[UIImage imageNamed:@"走图标(点击状态)"] forState:UIControlStateHighlighted];
    [walkButton addTarget:self action:@selector(gotosport1) forControlEvents:UIControlEventTouchUpInside];
    
    bikeButton.frame = CGRectMake(0, 0, 1, 1);
    bikeButton.center = CGPointMake(CENTER_X, BIKEBUTTON_CENTER_Y);
    [bikeButton setImage:[UIImage imageNamed:@"骑图标"] forState:UIControlStateNormal];
    [bikeButton setImage:[UIImage imageNamed:@"骑图标(点击状态)"] forState:UIControlStateHighlighted];
    [bikeButton addTarget:self action:@selector(gotosport3) forControlEvents:UIControlEventTouchUpInside];
    
    arrowImageView.frame = CGRectMake(0, 0, 1, 1);
    arrowImageView.center = CGPointMake(CENTER_X, ARROW_CENTER_Y);
    arrowImageView.image = [UIImage imageNamed:@"展开图标"];
    
    [cover addSubview:runButton];
    [cover addSubview:walkButton];
    [cover addSubview:bikeButton];
    [cover addSubview:arrowImageView];
    [self.view addSubview:cover];
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

- (void)toMapView {
    SMSportsViewController *sportViewController = [[SMSportsViewController alloc] init];
    [self.navigationController pushViewController:sportViewController animated:YES];
}

- (void)gotosport1 {
    sportType = 1;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"是否开始运动" delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
    alertView.tag = 0;
    [alertView show];
}

- (void)gotosport2 {
    sportType = 2;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"是否开始运动" delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
    alertView.tag = 1;
    [alertView show];
}

- (void)gotosport3 {
    sportType = 3;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"是否开始运动" delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
    alertView.tag = 2;
    [alertView show];
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
    if ([userDefaults boolForKey:@"isSport"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您正在运动中，是否退出" delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
        alertView.tag = 3;
        [alertView show];
    }else {
        [userDefaults setObject:@"" forKey:@"userId"];
        [userDefaults setBool:NO forKey:@"isLogin"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)toMyRecord {
    SMMyRecordViewController *myRecordViewController = [[SMMyRecordViewController alloc] init];
    [self.navigationController pushViewController:myRecordViewController animated:YES];
}

- (void)toScoreBoard {
    SMScoreBoardViewController *scoreBoardViewController = [[SMScoreBoardViewController alloc] init];
    [self.navigationController pushViewController:scoreBoardViewController animated:YES];
}

/**
 *  判断是否在运动
 */
- (BOOL)IsSport {
    FMDatabase *db = [FMDatabase databaseWithPath:myAppDelegate.dataBasePath];
    [db open];
    FMResultSet *resultSet = [db executeQuery:@"select * from sportrecordtemp"];
    while ([resultSet next]) {
        NSArray *startTimeStr = [[resultSet stringForColumn:@"starttime"] componentsSeparatedByString:@" "];
        if ([self isToday:startTimeStr[0]]) {
            [db close];
            return  YES;
        }
    }
    [db close];
    return NO;
}

/**
 *  判断当前日期是否是今天
 */
- (BOOL)isToday:(NSString *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *today = [formatter stringFromDate:[NSDate date]];
    if ([today isEqualToString:date]) {
        return YES;
    }else {
        return NO;
    }
}

/**
 *  同步服务器数据库
 **/
- (void)downloadServerDataBase {
    AVQuery *integralQuery = [AVQuery queryWithClassName:@"IntegralGained"];
    [integralQuery whereKey:@"useId" hasPrefix:[userDefaults objectForKey:@"userId"]];
    [integralQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        // 同步积分表
        /** 先删除原先的数据 */
        FMDatabase *db = [FMDatabase databaseWithPath:myAppDelegate.dataBasePath];
        if ([db open]) {
            [db executeUpdate:@"delete from integralgained"];
            for (AVObject *temp in objects) {
                NSString *uid = temp[@"uid"];
                NSString *userid = temp[@"useId"];
                NSDate *gaintime = temp[@"gainTime"];
                NSString *gaintime1 = temp[@"gainTime"];
                int integral = [temp[@"integral"] intValue];
                int gainreason = [temp[@"gainReason"] intValue];
                [db executeUpdate:[NSString stringWithFormat:@"insert into integralgained (uid, useid, gaintime, integral, gainreason) values ('%@', '%@', '%@', %d, %d)", uid, userid, gaintime, integral, gainreason]];
            }
            [activityIndicatorView removeFromSuperview];
            if (!isShow) {
                [self UILayout];
                isShow = YES;
            }
        }
        [db close];
    }];
    
    FMDatabase *db = [FMDatabase databaseWithPath:myAppDelegate.dataBasePath];
    AVQuery *sportQuery = [AVQuery queryWithClassName:@"SportRecord"];
    [sportQuery whereKey:@"userID" containsString:[userDefaults objectForKey:@"userId"]];
    [sportQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        // 同步运动记录表
        /** 先删除原先的数据 */
        if ([db open]) {
            if ([db executeUpdate:@"delete from sportrecord"]) {
                for (AVObject *temp in objects) {
                    NSString *uid = temp[@"uid"];
                    NSString *userid = temp[@"userID"];
                    int sporttype = [temp[@"sportType"] intValue];
                    NSDate *starttime = temp[@"startTime"];
                    NSDate *endtime = temp[@"endTime"];
                    int pausetime = [temp[@"pauseTime"] intValue];
                    NSString *motiontrack = temp[@"motionTrack"];
                    CGFloat distance = [temp[@"distance"] floatValue];
                    [db executeUpdate:[NSString stringWithFormat:@"insert into sportrecord (uid, userid, sporttype, starttime, endtime, pausetime, motiontrack, distance) values ('%@', '%@', %d, '%@', '%@', %d, '%@', %f)", uid, userid, sporttype, starttime, endtime, pausetime, motiontrack, distance]];
//                    NSLog(@"服务器数据：%@\n\n\n", temp);
                    totalTime += [self intervalFrom:starttime to:endtime];
                    totalDistance += distance;
                }
            }
            [activityIndicatorView removeFromSuperview];
            if (!isShow) {
                [self UILayout];
                isShow = YES;
            }
            detailsTime.text = [self intervalToTime:totalTime];
            detailsDistance.text = [NSString stringWithFormat:@"%.1f公里", totalDistance/1000];
            myAppDelegate.totalTrackDistance = totalDistance/1000;
        }
        [db close];
    }];
}

/**
 *  两个时间差
 **/
- (NSTimeInterval)intervalFrom:(NSDate *)earlyDate to:(NSDate *)lateDate
{
    
    NSTimeInterval early = [earlyDate timeIntervalSince1970]*1;
    NSTimeInterval late = [lateDate timeIntervalSince1970]*1;
    
    NSTimeInterval cha=late-early;
    
    return cha;
}

/**
 *  秒转小时
 **/
- (NSString *)intervalToTime:(NSTimeInterval)timeInterval {
    int min = [[NSString stringWithFormat:@"%d", (int)timeInterval/60%60] intValue];
    
    int house = [[NSString stringWithFormat:@"%d", (int)timeInterval/3600] intValue];
    
    NSString *timeString=[NSString stringWithFormat:@"%d时%d分钟",house,min];
    return timeString;
}

#pragma mark - uialertviewdelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 3) {
        [userDefaults setBool:NO forKey:@"isLogin"];
        if (buttonIndex == 0) {
            [userDefaults setObject:@"" forKey:@"userId"];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else {
        if (buttonIndex == 0) {
            if (sportType == 1) {
                [self chooseWalk];
            }else if(sportType == 2) {
                [self chooseRun];
            }else {
                [self chooseBike];
            }
        }
    }
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    /** 同步数据库动画效果 */
    activityIndicatorView = [[HJFActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 0.3*SCREEN_WIDTH, 0.8*0.3*SCREEN_WIDTH) andViewAlpha:0.8 andCornerRadius:8];
    activityIndicatorView.center = self.view.center;
    [self.view addSubview:activityIndicatorView];
    [self NavigationInit];
    [self downloadServerDataBase];
    self.extendedLayoutIncludesOpaqueBars = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UINavigationBar appearance].translucent = NO;
    if (![userDefaults boolForKey:@"isSport"]) {
        [KButton setImage:[UIImage imageNamed:@"K图标"] forState:UIControlStateNormal];
        [KButton removeTarget:self action:@selector(toMapView) forControlEvents:UIControlEventTouchUpInside];
        [KButton addTarget:self action:@selector(toSportChoice) forControlEvents:UIControlEventTouchUpInside];
    }else {
        [KButton setImage:[UIImage imageNamed:@"运动中图标"] forState:UIControlStateNormal];
        [KButton removeTarget:self action:@selector(toSportChoice) forControlEvents:UIControlEventTouchUpInside];
        [KButton addTarget:self action:@selector(toMapView) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hiddenMenu];
}
@end
