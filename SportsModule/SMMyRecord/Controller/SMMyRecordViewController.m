//
//  SMMyRecordViewController.m
//  SportsModule
//
//  Created by Hjf on 16/3/12.
//  Copyright © 2016年 xxn. All rights reserved.
//

#import "SMMyRecordViewController.h"
#import "UISize.h"
#import "SMSize.h"
#import "AppDelegate.h"
#import "SportRecord.h"
#import "IntegralGainedHistory.h"
#import "HJFActivityIndicatorView.h"

/** 数据库 */
#import "FMDB/FMDB.h"

#define SCOREVIEW_X             0.225*SCREEN_WIDTH
#define SCOREVIEW_Y             STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT+10
#define SCOREVIEW_WIDTH         0.55*SCREEN_WIDTH
#define SCOREVIEW_HEIGHT        0.1*SCREEN_HEIGHT

#define SCOREIMAGEVIEW_X        0.1*SCOREVIEW_WIDTH
#define SCOREIMAGEVIEW_Y        SCOREIMAGEVIEW_X*1.1
#define SCOREIMAGEVIEW_WIDTH    0.056*SCREEN_WIDTH

#define SCORELABEL_WIDTH        0.66*SCOREVIEW_WIDTH
#define SCORELABEL_HEIGHT       0.3*SCOREVIEW_HEIGHT
#define SCORELABEL_X            0.25*SCOREVIEW_WIDTH
#define SCORELABEL_Y            0.35*SCOREVIEW_HEIGHT

#define SWITCHVIEW_Y            0.27*SCREEN_HEIGHT
#define SWITCHVIEW_HEIGHT       0.068*SCREEN_HEIGHT

#define CUTLINEVIEW_WIDTH       1
#define CUTLINEVIEW_HEIGHT      0.5*SWITCHVIEW_HEIGHT

#define HREDPOINT_WIDTH         0.027*SCREEN_WIDTH
#define HREDPOINT_X             0.117*SCREEN_WIDTH
#define HREDPOINT_Y             0.4*SWITCHVIEW_HEIGHT

#define HBUTTON_X               HREDPOINT_X+0.053*SCREEN_WIDTH
#define HBUTTON_WIDTH           0.16*SCREEN_WIDTH
#define HBUTTON_HEIGHT          0.4*SWITCHVIEW_HEIGHT

#define RREDPOINT_X             HREDPOINT_X+SCREEN_WIDTH/2
#define RBUTTON_X               HBUTTON_X+SCREEN_WIDTH/2

#define TABLEVIEW_Y             0.33*SCREEN_HEIGHT
#define TABLEVIEW_HEIGHT        0.67*SCREEN_HEIGHT

#define CELL_HEIGHT             0.068*SCREEN_HEIGHT

@interface SMMyRecordViewController() <UITableViewDataSource, UITableViewDelegate>

@end

@implementation SMMyRecordViewController{
    UIView      *scoreView;  // 当前积分view
    UIImageView *scoreImageView;    // 积分图标
    UILabel     *scoreLabel;        // 积分标签
    
    UIView      *switchView;        // 选择view
    UIView      *cutLineView;       // 分割线view
    UIButton    *historyButton;      // 选择历史按钮
    UIButton    *recordButton;      // 我的记录按钮
    UIImageView *historyRedPoint;   // 选择历史红色图标
    UIImageView *recordRedPoint;    // 我的记录红色图标
    UITableView *myTableView;  // 列表
    BOOL        tableViewSwitch;    // 列表选择判断变量 1：history   0：record
    NSUserDefaults *userDefaults;
    AppDelegate *myAppDelegate;
    NSMutableArray  *integralArray; //获取记录
    NSMutableArray  *sportArray;    //运动记录
    BOOL        isShow;             // 记录是否加载过视图
    HJFActivityIndicatorView    *activityIndicatorView;
}

- (id)init {
    if (self = [super init]) {
        // 初始化控件
        scoreView       = [[UIView alloc] init];
        scoreImageView  = [[UIImageView alloc] init];
        scoreLabel      = [[UILabel alloc] init];
        
        switchView      = [[UIView alloc] init];
        cutLineView     = [[UIView alloc] init];
        historyButton   = [[UIButton alloc] init];
        recordButton    = [[UIButton alloc] init];
        historyRedPoint = [[UIImageView alloc] init];
        recordRedPoint  = [[UIImageView alloc] init];
        myTableView     = [[UITableView alloc] init];
        tableViewSwitch = YES;
        userDefaults    = [NSUserDefaults standardUserDefaults];
        myAppDelegate   = [[UIApplication sharedApplication] delegate];
        integralArray   = [[NSMutableArray alloc] init];
        sportArray      = [[NSMutableArray alloc] init];
        isShow          = NO;
    }
    return self;
}

#pragma mark - 控件布局
- (void)UILayout {
    scoreView.frame = CGRectMake(SCOREVIEW_X, SCOREVIEW_Y, SCOREVIEW_WIDTH, SCOREVIEW_HEIGHT);
    scoreView.backgroundColor = [UIColor clearColor];
    scoreView.layer.borderWidth = 1;
    scoreView.layer.borderColor = [UIColor whiteColor].CGColor;
    scoreView.layer.cornerRadius = 8;
    
    scoreImageView.frame = CGRectMake(SCOREIMAGEVIEW_X, SCOREIMAGEVIEW_Y, SCOREIMAGEVIEW_WIDTH, SCOREIMAGEVIEW_WIDTH);
    scoreImageView.image = [UIImage imageNamed:@"积分图标"];
    [scoreView addSubview:scoreImageView];
    
    scoreLabel.frame = CGRectMake(SCORELABEL_X, SCORELABEL_Y, SCORELABEL_WIDTH, SCORELABEL_HEIGHT);
    NSNumber *totalIntegral = [userDefaults objectForKey:@"currentIntegral"];
    scoreLabel.text = [NSString stringWithFormat:@"当前积分%d分", [totalIntegral intValue]];
    scoreLabel.font = [UIFont systemFontOfSize:15];
    scoreLabel.textAlignment = NSTextAlignmentCenter;
    scoreLabel.textColor = [UIColor whiteColor];
    [scoreView addSubview:scoreLabel];
    
    switchView.frame = CGRectMake(0, SWITCHVIEW_Y, SCREEN_WIDTH, SWITCHVIEW_HEIGHT);
    switchView.backgroundColor = [UIColor whiteColor];
    
    historyRedPoint.frame = CGRectMake(HREDPOINT_X, HREDPOINT_Y, HREDPOINT_WIDTH, HREDPOINT_WIDTH);
    historyRedPoint.image = [UIImage imageNamed:@"红点图标"];
    historyRedPoint.hidden = NO;
    [switchView addSubview:historyRedPoint];
    
    historyButton.frame = CGRectMake(HBUTTON_X, HREDPOINT_Y*0.8, HBUTTON_WIDTH, HBUTTON_HEIGHT);
    [historyButton setTitle:@"获取历史" forState:UIControlStateNormal];
    historyButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [historyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [historyButton addTarget:self action:@selector(history) forControlEvents:UIControlEventTouchUpInside];
    [historyButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [switchView addSubview:historyButton];
    
    cutLineView.frame = CGRectMake(0, 0, CUTLINEVIEW_WIDTH, CUTLINEVIEW_HEIGHT);
    cutLineView.center = switchView.center;
    cutLineView.backgroundColor = [UIColor blackColor];

    
    recordRedPoint.frame = CGRectMake(RREDPOINT_X, HREDPOINT_Y, HREDPOINT_WIDTH, HREDPOINT_WIDTH);
    recordRedPoint.image = [UIImage imageNamed:@"红点图标"];
    recordRedPoint.hidden = YES;
    [switchView addSubview:recordRedPoint];
    
    recordButton.frame = CGRectMake(RBUTTON_X, HREDPOINT_Y*0.8, HBUTTON_WIDTH, HBUTTON_HEIGHT);
    [recordButton setTitle:@"运动记录" forState:UIControlStateNormal];
    recordButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [recordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [recordButton addTarget:self action:@selector(record) forControlEvents:UIControlEventTouchUpInside];
    [switchView addSubview:recordButton];
    
    myTableView.frame = CGRectMake(0, TABLEVIEW_Y, SCREEN_WIDTH, TABLEVIEW_HEIGHT);
    myTableView.delegate = self;
    myTableView.dataSource = self;
    myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:scoreView];
    [self.view addSubview:switchView];
    [self.view addSubview:cutLineView];
    [self.view addSubview:myTableView];
}

#pragma mark - 导航栏设置
- (void)NavigationInit {
    self.navigationItem.title = @"我的记录";
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回图标"] style:UIBarButtonItemStylePlain target:self action:@selector(backToMainView)];
    leftButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = leftButton;
}

#pragma mark - TableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableViewSwitch) {
        return integralArray.count;
    }else {
        return sportArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier=@"UITableViewCellIdentifierKey1";
    UITableViewCell *cell;
    cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imageView.image = [UIImage imageNamed:@"时间图标"];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"我的记录分割线"]];
    cell.backgroundView.contentMode = UIViewContentModeTop;
    if (tableViewSwitch) {
        IntegralGainedHistory *integralGainedHistory = integralArray[integralArray.count-1-indexPath.row];
        cell.textLabel.text = integralGainedHistory.gainedDate;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)integralGainedHistory.integral];
    }else {
        SportRecord *record = sportArray[sportArray.count-indexPath.row-1];
        cell.textLabel.text = record.sportDate;
        cell.detailTextLabel.text = record.distanceAndTime;
    }
    cell.detailTextLabel.textColor = [UIColor blackColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

#pragma mark - 私有方法
- (void)backToMainView {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)history {
    if (!tableViewSwitch) {
        tableViewSwitch = YES;
        if (tableViewSwitch) {
            historyRedPoint.hidden = NO;
            [historyButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            recordRedPoint.hidden = YES;
            [recordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [myTableView reloadData];
        }
    }
}

- (void)record {
    if (tableViewSwitch) {
        tableViewSwitch = NO;
        if (!tableViewSwitch) {
            recordRedPoint.hidden = NO;
            [recordButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            historyRedPoint.hidden = YES;
            [historyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [myTableView reloadData];
        }
    }
}

/**
 *  加载数据
 **/
- (void)loadDate {
    activityIndicatorView = [[HJFActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 0.3*SCREEN_WIDTH, 0.8*0.3*SCREEN_WIDTH) andViewAlpha:0.8 andCornerRadius:8];
    activityIndicatorView.center = self.view.center;
    [self.view addSubview:activityIndicatorView];
    FMDatabase *db = [FMDatabase databaseWithPath:myAppDelegate.dataBasePath];
    if ([db open]) {
        FMResultSet *resultSet = [db executeQuery:@"select * from sportrecord"];
        while ([resultSet next]) {
            NSString *starttimeStr = resultSet[@"startTime"];
            NSString *endtimeStr = resultSet[@"endTime"];
            NSArray *starttimeArray = [starttimeStr componentsSeparatedByString:@" "];
            CGFloat distance = [resultSet[@"distance"] floatValue];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            SportRecord *record = [[SportRecord alloc] init];
            record.sportDate = starttimeArray[0];
            [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            [df setDateFormat:@"yyyy-MM-dd HH:mm:ss +0000"];
            NSTimeInterval secondTime = [self intervalFrom:[df dateFromString:starttimeStr] to:[df dateFromString:endtimeStr]];
            NSString *time = [self intervalToTime:secondTime];
            record.distanceAndTime = [NSString stringWithFormat:@"%.2f公里 - %@", distance/1000, time];
            [sportArray addObject:record];
        }
        FMResultSet *temp = [db executeQuery:@"select * from integralgained"];
        while ([temp next]) {
            NSString *gaintimeStr = temp[@"gaintime"];
//            NSArray *gaintimeArray = [gaintimeStr componentsSeparatedByString:@" "];
            NSString *gaintime;
            gaintime = [gaintimeStr substringToIndex:16];
            int integral = [temp[@"integral"] intValue];
            IntegralGainedHistory *integralGainedHistory = [[IntegralGainedHistory alloc] init];
            integralGainedHistory.gainedDate = gaintime;
            integralGainedHistory.integral = integral;
            [integralArray addObject:integralGainedHistory];
        }
        [activityIndicatorView removeFromSuperview];
        if (!isShow) {
            [self UILayout];
            isShow = YES;
        }
    }
    [db close];
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
    int sec = [[NSString stringWithFormat:@"%d", (int)timeInterval%60] intValue];
    int min = [[NSString stringWithFormat:@"%d", (int)timeInterval/60%60] intValue];
    int house = [[NSString stringWithFormat:@"%d", (int)timeInterval/3600] intValue];
    NSString *timeString;
    if (house > 0) {
        timeString=[NSString stringWithFormat:@"%d时%d分钟",house,min];
    }else if (min > 0) {
        timeString = [NSString stringWithFormat:@"%d分钟", min];
    }else {
        timeString = [NSString stringWithFormat:@"%d秒钟", sec];
    }
    
    return timeString;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor colorWithRed:88/255.0 green:89/255.0 blue:91/255.0 alpha:1.0];
    self.extendedLayoutIncludesOpaqueBars = YES;
    [self NavigationInit];
    [self loadDate];
}


@end
