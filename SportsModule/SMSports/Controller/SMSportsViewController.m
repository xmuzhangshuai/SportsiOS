//
//  SMSportsViewController.m
//  SportsModule
//
//  Created by Hjf on 16/3/13.
//  Copyright © 2016年 xxn. All rights reserved.
//

#import "SMSportsViewController.h"
#import "UISize.h"
#import "SMSize.h"
#import "HJFActivityIndicatorView.h"
#import "AppDelegate.h"

/** 百度地图头文件 */
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>

/** Leancloud头文件 */
#import <AVOSCloud/AVOSCloud.h>

/** 数据库相关操作 */
#import "SaveDataToLocalDB.h"
#import "SaveDataToServer.h"
#import "FMDB/FMDB.h"

/** 讯飞语音 */
#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import "iflyMSC/IFlyMSC.h"

#define DETAILSVIEW_X   0
#define DETAILSVIEW_Y   NAVIGATIONBAR_HEIGHT
#define DETAILSVIEW_WIDTH   SCREEN_WIDTH
#define DETAILSVIEW_HEIGHT  0.2*SCREEN_HEIGHT-NAVIGATIONBAR_HEIGHT

#define STARTTIMEIMAGEVIEW_X    SCREEN_WIDTH/6-STARTTIMEIMAGEVIEW_WIDTH/2
#define STARTTIMEIMAGEVIEW_Y    0.023*SCREEN_HEIGHT
#define STARTTIMEIMAGEVIEW_WIDTH    0.054*SCREEN_WIDTH

#define STARTTIMELABEL_X    0.047*SCREEN_WIDTH
#define STARTTIMELABEL_Y    STARTTIMEIMAGEVIEW_Y*2+STARTTIMEIMAGEVIEW_WIDTH
#define STARTTIMELABEL_WIDTH    0.238*SCREEN_WIDTH
#define STARTTIMELABEL_HEIGHT   0.186*(DETAILSVIEW_HEIGHT)

#define CUTLINEVIEW_Y           (DETAILSVIEW_HEIGHT)/4
#define CUTLINEVIEW_WIDTH       1
#define CUTLINEVIEW_HEIGHT      (DETAILSVIEW_HEIGHT)/2

#define SWITCHBUTTON_CENTER_Y   0.8188*SCREEN_HEIGHT
#define SWITCHBUTTON_WIDTH      0.274*SCREEN_WIDTH

#define SPORTIMAGEVIEW_CENTER_Y 0.78*SCREEN_HEIGHT
#define SPORTIMAGEVIEW_WIDTH    0.116*SCREEN_WIDTH

#define STOPIMAGEVIEW_CENTER_Y 0.44*SCREEN_HEIGHT
#define STOPIMAGEVIEW_WIDTH    0.653*SCREEN_WIDTH
#define STOPIMAGEVIEW_HEIGHT   0.213*SCREEN_HEIGHT

#define BEENFINISHLABEL_CENTER_X    0.336*SCREEN_WIDTH
#define BEENFINISHLABEL_CENTER_Y    0.473*SCREEN_HEIGHT
#define BEENFINISHLABEL_WIDTH   0.653*SCREEN_WIDTH/2
#define BEENFINISHLABEL_HEIGHT  0.213*SCREEN_HEIGHT/3

#define SUCCESSFINISHLABEL_CENTER_X 0.662*SCREEN_WIDTH

#define CONFIRMBUTTON_CENTER_Y  0.623*SCREEN_HEIGHT
#define CONFIRMBUTTON_WIDTH     0.12*SCREEN_WIDTH

#define CONTINUEBUTTON_CENTER_Y 0.725*SCREEN_HEIGHT

@interface SMSportsViewController() <BMKMapViewDelegate, BMKLocationServiceDelegate, UIAlertViewDelegate, IFlySpeechSynthesizerDelegate>

/** 上一次的位置 */
@property (nonatomic, strong) CLLocation *preLocation;

/** 位置数组 */
@property (nonatomic, strong) NSMutableArray *locationArray;

/** 颜色索引数组 */
@property (nonatomic, strong) NSMutableArray *colorIndex;

/** 轨迹线 */
@property (nonatomic, strong) BMKPolyline *polyLine;

/** 百度地图View */
@property (nonatomic, strong) BMKMapView *mapView;

/** 百度定位地图服务 */
@property (nonatomic, strong) BMKLocationService *bmkLocationService;

/** 大头针 起点位置 */
@property (nonatomic, strong) BMKPointAnnotation *startPoint;

/** 大头针 终点位置 */
@property (nonatomic, strong) BMKPointAnnotation *endPoint;

@property (nonatomic, strong) AppDelegate *myAppDelegate;
@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

@implementation SMSportsViewController {
    UIView *titleView;  // 运行详情view
    UIImageView *detailsView;    // 运动详细时间距离容器
    
    UIImageView *startTimeImageView;   // 时间记录图标
    UIImageView *usedTimeImageView;     // 计时图标
    UIImageView *distanceImageView;     // 距离记录图标
    
    UILabel     *startTimeLabel;
    UILabel     *usedTimeLabel;
    UILabel     *distanceLabel;
    
    UIView      *cutLineViewL;          // 左分隔线
    UIView      *cutLineViewR;          // 右分隔线
    
    BOOL        switchMenu;             // 控制下滑菜单detailsView
    
    UIButton    *switchButton;       // 开始\暂停图标
    UIImageView *sportImageView;     // 运动方式图标
    
    UIView      *cover;                 // 遮盖层
    UIImageView *stopImageView;         // 暂停
    UILabel     *beenFinishLabel;       // 您已完成
    UILabel     *successFinishLabel;    // 成功完成
    UIButton    *confirmButton;         // 确定按钮
    UIButton    *continueButton;        // 继续按钮
    
    NSString    *sportMode;             // 记录运动方式
    
    BOOL        isBegin;               // 记录是否已经开始运动
    BOOL        isPause;                // 记录是否暂停
    BOOL        isContinue;             // 记录是否继续
    BOOL        isStopMenu;             // 判断暂停界面是否显示
    
    NSDate      *startTime;             // 开始时间
    NSDate      *endTime;               // 结束时间
    int         pauseTime;              // 暂停时长
    int         duration;               // 真实运动时间
    NSDate      *stopTime;              // 暂停时的时间
    NSString    *motionTrack;           // 运动轨迹
    CGFloat     TrackDistance;          // 运动里程
    CGFloat     currentDistance;        // 记录当前运动里程
    
    NSTimer     *countTimeTimer;        // 运动时间计时器
    NSTimer     *saveDataPer3MinTimer;  // 存储数据计时器
    
    /** 讯飞语音 */
    IFlySpeechSynthesizer   *_iFlySpeechSynthesizer;
}

/** 运动中初始化函数 */
- (id)init {
    if (self = [super init]) {
        titleView           = [[UIView alloc] init];
        detailsView         = [[UIImageView alloc] init];
        startTimeImageView  = [[UIImageView alloc] init];
        usedTimeImageView   = [[UIImageView alloc] init];
        distanceImageView   = [[UIImageView alloc] init];
        startTimeLabel      = [[UILabel alloc] init];
        usedTimeLabel       = [[UILabel alloc] init];
        distanceLabel       = [[UILabel alloc] init];
        cutLineViewL        = [[UIView alloc] init];
        cutLineViewR        = [[UIView alloc] init];
        switchButton        = [[UIButton alloc] init];
        sportImageView      = [[UIImageView alloc] init];
        switchMenu          = YES;
        
        cover               = [[UIView alloc] init];
        stopImageView       = [[UIImageView alloc] init];
        beenFinishLabel     = [[UILabel alloc] init];
        successFinishLabel  = [[UILabel alloc] init];
        confirmButton       = [[UIButton alloc] init];
        continueButton      = [[UIButton alloc] init];
        isBegin             = NO;
        isPause             = NO;
        isContinue          = YES;
        isStopMenu          = NO;
        motionTrack         = @"";
        
        self.userDefaults   = [NSUserDefaults standardUserDefaults];
        self.myAppDelegate  = [[UIApplication sharedApplication] delegate];
    }
    
    return self;
}

- (instancetype)initWithSport:(NSString *)sportmode {
    if (self = [super init]) {
        titleView           = [[UIView alloc] init];
        detailsView         = [[UIImageView alloc] init];
        startTimeImageView  = [[UIImageView alloc] init];
        usedTimeImageView   = [[UIImageView alloc] init];
        distanceImageView   = [[UIImageView alloc] init];
        startTimeLabel      = [[UILabel alloc] init];
        usedTimeLabel       = [[UILabel alloc] init];
        distanceLabel       = [[UILabel alloc] init];
        cutLineViewL        = [[UIView alloc] init];
        cutLineViewR        = [[UIView alloc] init];
        switchButton        = [[UIButton alloc] init];
        sportImageView      = [[UIImageView alloc] init];
        switchMenu          = YES;
        
        cover               = [[UIView alloc] init];
        stopImageView       = [[UIImageView alloc] init];
        beenFinishLabel     = [[UILabel alloc] init];
        successFinishLabel  = [[UILabel alloc] init];
        confirmButton       = [[UIButton alloc] init];
        continueButton      = [[UIButton alloc] init];
        isBegin             = NO;
        isPause             = NO;
        isContinue          = YES;
        isStopMenu          = NO;
        motionTrack         = @"";
        
        sportMode           = sportmode;
        
        self.userDefaults   = [NSUserDefaults standardUserDefaults];
        
        self.myAppDelegate  = [[UIApplication sharedApplication] delegate];
    }
    return self;
}

#pragma mark - 导航栏设置
- (void)NavigationInit {
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回图标"] style:UIBarButtonItemStylePlain target:self action:@selector(backToMainView)];
    leftButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneSport)];
    rightButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    // 运动详情
    titleView.frame = CGRectMake(0, 0, 90, 5);
    UIButton *sportDetailsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 0)];
    [sportDetailsButton setTitle:@"运动详情" forState:UIControlStateNormal];
    
    UIButton *arrowButton = [[UIButton alloc] initWithFrame:CGRectMake(85, 0, 10, 5)];
    [arrowButton setImage:[UIImage imageNamed:@"下拉展开图标"] forState:UIControlStateNormal];
    
    [titleView addSubview:sportDetailsButton];
    [titleView addSubview:arrowButton];
    self.navigationItem.titleView = titleView;
    
    UITapGestureRecognizer *showMenuTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu)];
    [self.navigationItem.titleView addGestureRecognizer:showMenuTap];
    
    // 设置半透明图
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"半透明"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = YES;
    
    // 去掉navigationbar底部黑线
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
}

#pragma mark - 控件布局
- (void)UILayout {
    // 外层view
    detailsView.frame = CGRectMake(DETAILSVIEW_X, DETAILSVIEW_Y, DETAILSVIEW_WIDTH, 0);
    detailsView.image = [UIImage imageNamed:@"半透明"];
//    detailsView.backgroundColor = [UIColor greenColor];
    [self hiddenUI];
    
    // 时间记录标签
    startTimeImageView.frame = CGRectMake(STARTTIMEIMAGEVIEW_X, STARTTIMEIMAGEVIEW_Y, STARTTIMEIMAGEVIEW_WIDTH, STARTTIMEIMAGEVIEW_WIDTH);
    startTimeImageView.image = [UIImage imageNamed:@"时间记录图标"];
    [detailsView addSubview:startTimeImageView];
    
    // 时间记录标签具体值
    startTimeLabel.frame = CGRectMake(STARTTIMELABEL_X, STARTTIMELABEL_Y, STARTTIMELABEL_WIDTH, STARTTIMELABEL_HEIGHT);
    startTimeLabel.clipsToBounds = YES;
    startTimeLabel.layer.cornerRadius = 6;
    startTimeLabel.backgroundColor = [UIColor whiteColor];
    startTimeLabel.textAlignment = NSTextAlignmentCenter;
    startTimeLabel.font = [UIFont systemFontOfSize:12];
    [detailsView addSubview:startTimeLabel];
    
    // 左边分隔线
    cutLineViewL.frame = CGRectMake(SCREEN_WIDTH/3, CUTLINEVIEW_Y, CUTLINEVIEW_WIDTH, CUTLINEVIEW_HEIGHT);
    cutLineViewL.backgroundColor = [UIColor whiteColor];
    [detailsView addSubview:cutLineViewL];
    
    // 计时图标
    usedTimeImageView.frame = CGRectMake(STARTTIMEIMAGEVIEW_X+SCREEN_WIDTH/3, STARTTIMEIMAGEVIEW_Y, STARTTIMEIMAGEVIEW_WIDTH, STARTTIMEIMAGEVIEW_WIDTH);
    usedTimeImageView.image = [UIImage imageNamed:@"计时图标"];
    [detailsView addSubview:usedTimeImageView];
    
    // 计时图标标签具体值
    usedTimeLabel.frame = CGRectMake(STARTTIMELABEL_X+SCREEN_WIDTH/3, STARTTIMELABEL_Y, STARTTIMELABEL_WIDTH, STARTTIMELABEL_HEIGHT);
    usedTimeLabel.clipsToBounds = YES;
    usedTimeLabel.layer.cornerRadius = 6;
    usedTimeLabel.backgroundColor = [UIColor whiteColor];
    usedTimeLabel.textAlignment = NSTextAlignmentCenter;
    usedTimeLabel.font = [UIFont systemFontOfSize:12];
    [detailsView addSubview:usedTimeLabel];
    
    // 右边分隔线
    cutLineViewR.frame = CGRectMake(2*SCREEN_WIDTH/3, CUTLINEVIEW_Y, CUTLINEVIEW_WIDTH, CUTLINEVIEW_HEIGHT);
    cutLineViewR.backgroundColor = [UIColor whiteColor];
    [detailsView addSubview:cutLineViewR];
    
    // 距离图标
    distanceImageView.frame = CGRectMake(STARTTIMEIMAGEVIEW_X+2*SCREEN_WIDTH/3, STARTTIMEIMAGEVIEW_Y, STARTTIMEIMAGEVIEW_WIDTH, STARTTIMEIMAGEVIEW_WIDTH);
    distanceImageView.image = [UIImage imageNamed:@"长度记录图标"];
    [detailsView addSubview:distanceImageView];
    
    // 距离图标标签具体值
    distanceLabel.frame = CGRectMake(STARTTIMELABEL_X+2*SCREEN_WIDTH/3, STARTTIMELABEL_Y, STARTTIMELABEL_WIDTH, STARTTIMELABEL_HEIGHT);
    distanceLabel.clipsToBounds = YES;
    distanceLabel.layer.cornerRadius = 6;
    distanceLabel.backgroundColor = [UIColor whiteColor];
    distanceLabel.textAlignment = NSTextAlignmentCenter;
    distanceLabel.font = [UIFont systemFontOfSize:12];
    [detailsView addSubview:distanceLabel];
    
    [self.navigationController.navigationBar addSubview:detailsView];
    
    // 开始\暂停按钮
    switchButton.frame = CGRectMake(0, 0, SWITCHBUTTON_WIDTH, SWITCHBUTTON_WIDTH);
    switchButton.center = CGPointMake(CENTER_X, SWITCHBUTTON_CENTER_Y);
    if (![self.userDefaults boolForKey:@"isSport"]) {
        [switchButton setImage:[UIImage imageNamed:@"开始图标"] forState:UIControlStateNormal];
        [switchButton addTarget:self action:@selector(stopSport) forControlEvents:UIControlEventTouchUpInside];
    }else {
        [switchButton setImage:[UIImage imageNamed:@"暂停图标"] forState:UIControlStateNormal];
        [switchButton addTarget:self action:@selector(stopSport) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.view addSubview:switchButton];
    
    // 运动类型标签
    sportImageView.frame = CGRectMake(0, 0, SPORTIMAGEVIEW_WIDTH, SPORTIMAGEVIEW_WIDTH);
    sportImageView.center = CGPointMake(CENTER_X, SPORTIMAGEVIEW_CENTER_Y);
    if ([sportMode isEqualToString:@"跑"]) {
        sportImageView.image = [UIImage imageNamed:@"跑步类型图标"];
    }else if ([sportMode isEqualToString:@"走"]) {
        sportImageView.image = [UIImage imageNamed:@"步行类型图标"];
    }else {
        sportImageView.image = [UIImage imageNamed:@"骑行类型图标"];
    }
    [self.view addSubview:sportImageView];
    
    // 暂停界面
    cover.frame = [UIScreen mainScreen].bounds;
    cover.alpha = 0;
    cover.backgroundColor = [UIColor blackColor];
    cover.hidden = YES;
    UITapGestureRecognizer *continueSportMenu = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(continueSport)];
    [cover addGestureRecognizer:continueSportMenu];
    [self.view addSubview:cover];
    
    stopImageView.frame = CGRectMake(0, 0, 1, 1);
    stopImageView.center = CGPointMake(CENTER_X, STOPIMAGEVIEW_CENTER_Y);
    [stopImageView setImage:[UIImage imageNamed:@"背景底图"]];
    [cover addSubview:stopImageView];
    
    beenFinishLabel.frame = CGRectMake(0, 0, BEENFINISHLABEL_WIDTH, BEENFINISHLABEL_HEIGHT);
    beenFinishLabel.center = CGPointMake(BEENFINISHLABEL_CENTER_X, BEENFINISHLABEL_CENTER_Y);
    beenFinishLabel.textAlignment = NSTextAlignmentCenter;
    beenFinishLabel.hidden = YES;
    [cover addSubview:beenFinishLabel];
    
    successFinishLabel.frame = CGRectMake(0, 0, BEENFINISHLABEL_WIDTH, BEENFINISHLABEL_HEIGHT);
    successFinishLabel.center = CGPointMake(SUCCESSFINISHLABEL_CENTER_X, BEENFINISHLABEL_CENTER_Y);
    successFinishLabel.text = @"1300";
    successFinishLabel.textAlignment = NSTextAlignmentCenter;
    successFinishLabel.hidden = YES;
    [cover addSubview:successFinishLabel];
    
    confirmButton.frame = CGRectMake(0, 0, 1, 1);
    confirmButton.center = CGPointMake(CENTER_X, CONFIRMBUTTON_CENTER_Y);
    [confirmButton setImage:[UIImage imageNamed:@"确定图标"] forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(doneSport) forControlEvents:UIControlEventTouchUpInside];
    [cover addSubview:confirmButton];
    
    continueButton.frame = CGRectMake(0, 0, 1, 1);
    continueButton.center = CGPointMake(CENTER_X, CONTINUEBUTTON_CENTER_Y);
    [continueButton setImage:[UIImage imageNamed:@"继续图标"] forState:UIControlStateNormal];
    [continueButton addTarget:self action:@selector(continueSport) forControlEvents:UIControlEventTouchUpInside];
    [cover addSubview:continueButton];
    
    [self NavigationInit];
    
}

#pragma mark - 显示信息初始化
- (void)sportDataInit {
    if ([self.userDefaults boolForKey:@"isSport"]) {
        // 继续上一次运动
        /** 从本地数据库获取数据 */
        FMDatabase *db = [FMDatabase databaseWithPath:self.myAppDelegate.dataBasePath];
        [db open];
        FMResultSet *resultSet = [db executeQuery:@"select * from sportrecordtemp"];
        NSArray *startTimeStr;  // 用来获得日期
        NSString *startTimeString;  // 用来获得时间
        while ([resultSet next]) {
            startTimeString = [resultSet stringForColumn:@"starttime"];
            startTimeStr = [startTimeString componentsSeparatedByString:@" "];
            NSLog(@"%@", startTimeStr[0]);
            TrackDistance = [resultSet doubleForColumn:@"distance"];
            int sportType = [resultSet intForColumn:@"sporttype"];
            motionTrack = [resultSet stringForColumn:@"motionTrack"];
            switch (sportType) {
                case 0:{
                    sportMode = @"走";
                    [sportImageView setImage:[UIImage imageNamed:@"步行类型图标"]];
                }
                    break;
                case 1:{
                    sportMode = @"跑";
                    [sportImageView setImage:[UIImage imageNamed:@"跑步类型图标"]];
                }
                    break;
                case 2:{
                    sportMode = @"骑";
                    [sportImageView setImage:[UIImage imageNamed:@"骑行类型图标"]];
                }
                    break;
                default:
                    break;
            }
        }
        /** 开始时间 */
        startTimeLabel.text = [NSString stringWithFormat:@"%@", startTimeStr[1]];
        countTimeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countTime) userInfo:nil repeats:YES];
        /** 开启计时器，每三分钟写一次数据 */
        saveDataPer3MinTimer = [NSTimer scheduledTimerWithTimeInterval:180 target:self selector:@selector(saveRecordToTempPer3Min) userInfo:nil repeats:YES];
        /** 运动时间 */
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss +0000"];
        startTime = [df dateFromString:startTimeString];
        usedTimeLabel.text = [NSString stringWithFormat:@"%@", [self intervalSinceNow:startTime]];
        /** 运动距离 */
        distanceLabel.text = [NSString stringWithFormat:@"%.2fkm", TrackDistance/1000];
        [db close];
        /** 之前的运动轨迹 */
        NSLog(@"motionTrack:%@", motionTrack);
        NSArray *motionTrackArray = [motionTrack componentsSeparatedByString:@";"];
        /** 轨迹点个数 */
        NSUInteger count = motionTrackArray.count;
        BMKMapPoint *tempPoints = new BMKMapPoint[count];
        int number = 0;
        for (NSString *temp = motionTrackArray[number]; number < count;) {
            NSArray *motionArray = [temp componentsSeparatedByString:@"Lat"];
            /** 取出数字 */
            NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z]" options:0 error:NULL];
            NSString *result = [regular stringByReplacingMatchesInString:motionArray[0] options:0 range:NSMakeRange(0, [motionArray[0] length]) withTemplate:@""];
            CLLocationCoordinate2D point = CLLocationCoordinate2DMake([motionArray[1] floatValue], [result floatValue]);
            if (number == 0) {
                self.startPoint = [[BMKPointAnnotation alloc] init];
                self.startPoint.coordinate = point;
                [self.mapView addAnnotation:self.startPoint];
            }
            BMKMapPoint locationPoint = BMKMapPointForCoordinate(point);
            CLLocation *Point = [[CLLocation alloc] initWithLatitude:point.latitude longitude:point.longitude];
            [self.locationArray addObject:Point];
            tempPoints[number] = locationPoint;
            if ([motionArray[0] rangeOfString:@"stop"].location != NSNotFound && number > 0) {
                [self.colorIndex addObject:[NSNumber numberWithInt:0]];
            }else if (number > 0){
                [self.colorIndex addObject:[NSNumber numberWithInt:1]];
            }
            number++;
        }
        [self.polyLine setPolylineWithPoints:tempPoints count:count textureIndex:self.colorIndex];
        [self.mapView addOverlay:self.polyLine];
        delete []tempPoints;
        [self.bmkLocationService startUserLocationService];
        isBegin = YES;
    }else {
        // 开始一次新的运动
        /** 开始时间 */
        startTime = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm:ss"];
        startTimeLabel.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:startTime]];
        /** 运动时间 */
        usedTimeLabel.text = @"00:00:00";
        /** 运动距离 */
        distanceLabel.text = [NSString stringWithFormat:@"%.2fkm", TrackDistance/1000];
    }
}

#pragma mark - 讯飞语音初始化
- (void)IFlyInit {
    _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    _iFlySpeechSynthesizer.delegate = self;
    /** 语音合成参数 */
    // 语速
    [_iFlySpeechSynthesizer setParameter:@"50" forKey:[IFlySpeechConstant SPEED]];
    //音量;取值范围 0~100
    [_iFlySpeechSynthesizer setParameter:@"50" forKey: [IFlySpeechConstant VOLUME]];
    //发音人,默认为”xiaoyan”;可以设置的参数列表可参考个 性化发音人列表
    [_iFlySpeechSynthesizer setParameter:@" xiaoyan " forKey: [IFlySpeechConstant VOICE_NAME]];
    //音频采样率,目前支持的采样率有 16000 和 8000
    [_iFlySpeechSynthesizer setParameter:@"8000" forKey: [IFlySpeechConstant SAMPLE_RATE]];
    //asr_audio_path保存录音文件路径，如不再需要，设置value为nil表示取消，默认目录是documents
    [_iFlySpeechSynthesizer setParameter:@" tts.pcm" forKey: [IFlySpeechConstant TTS_AUDIO_PATH]];
    
    currentDistance = 0;
}

#pragma mark - 百度地图
/**
 *  百度地图设置
 */
- (void)BMKMapViewInit {
    // 地图
    self.mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.showMapScaleBar = YES;
    //设置当前地图的显示范围，直接显示到用户位置
    BMKCoordinateRegion adjustRegion = [self.mapView regionThatFits:BMKCoordinateRegionMake(self.bmkLocationService.userLocation.location.coordinate, BMKCoordinateSpanMake(0.02f,0.02f))];
    [self.mapView setRegion:adjustRegion animated:YES];
    self.mapView.delegate = self;
    [self.view insertSubview:self.mapView atIndex:0];
    // 定位
    self.bmkLocationService = [[BMKLocationService alloc] init];
    if ([sportMode isEqualToString:@"跑"]) {
        self.bmkLocationService.distanceFilter = 3;
    }else if([sportMode isEqualToString:@"走"]) {
        self.bmkLocationService.distanceFilter = 1;
    }else if([sportMode isEqualToString:@"骑"]){
        self.bmkLocationService.distanceFilter = 5;
    }
    self.bmkLocationService.desiredAccuracy = kCLLocationAccuracyBest;
    self.bmkLocationService.delegate = self;
    [self.bmkLocationService startUserLocationService];
    // 定位点数组
    self.locationArray = [[NSMutableArray alloc] init];
    // 颜色索引数组
    self.colorIndex = [[NSMutableArray alloc] init];
    // 折线
    self.polyLine = [[BMKPolyline alloc] init];
        //运动中的的状态，需要绘制出先前的路线
}

#pragma mark - 百度地图代理
#pragma mark -- 百度地图定位代理
/**
 *  用户改变位置调用
 **/
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    self.mapView.showsUserLocation = YES;
    [self.mapView updateLocationData:userLocation];
    self.mapView.centerCoordinate = userLocation.location.coordinate;
    if (!isBegin) {
        // 起点图标
        self.startPoint = [[BMKPointAnnotation alloc] init];
        self.startPoint.coordinate = userLocation.location.coordinate;
        [self.mapView addAnnotation:self.startPoint];
        [self.bmkLocationService stopUserLocationService];
    }
    if (isContinue) {
        NSString *temp = [MARK stringByAppendingString:[NSString stringWithFormat:@"Lon%fLat%f;", userLocation.location.coordinate.longitude, userLocation.location.coordinate.latitude]];
        NSString *temp1 = [motionTrack stringByAppendingString:temp];
        motionTrack = temp1;
        isContinue = NO;
    }else {
        NSString *temp = [motionTrack stringByAppendingString:[NSString stringWithFormat:@"Lon%fLat%f;", userLocation.location.coordinate.longitude, userLocation.location.coordinate.latitude]];
        motionTrack = temp;
    }
    [self TrailRouteWithUserLocation:userLocation];
    NSLog(@"motiontrack:%@", motionTrack);
}

/**
 *  用户改变方向
 **/
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation {
    [self.mapView updateLocationData:userLocation];
}

/**
 *  定位失败
 **/
- (void)didFailToLocateUserWithError:(NSError *)error {
    
}

#pragma mark -- 百度地图图层代理
/**
 *  添加折现等调用
 **/
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay{
    if ([overlay isKindOfClass:[BMKPolyline class]]){
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
//        polylineView.strokeColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:1] colorWithAlphaComponent:1];
        polylineView.colors = [NSArray arrayWithObjects:[UIColor colorWithRed:0 green:0 blue:0 alpha:0], [UIColor colorWithRed:0 green:0 blue:0 alpha:1], nil];
        polylineView.lineWidth = 5.0;
        return polylineView;
    }
    
    return nil;
}

/**
 *  添加图标等调用
 **/
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorGreen;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        return newAnnotationView;
    }
    return nil;
}

#pragma mark - 记录运动轨迹以及绘轨迹
/**
 *  记录运动轨迹
 **/
- (void)TrailRouteWithUserLocation:(BMKUserLocation *)userLocation {
    if (self.preLocation) {
        CGFloat distance = [userLocation.location distanceFromLocation:self.preLocation];
        NSLog(@"distance:%f", distance);
        if ([sportMode isEqualToString:@"跑"]) {
            if (distance < 3) {
                return;
            }
        }else if([sportMode isEqualToString:@"走"]) {
            if (distance < 1) {
                return;
            }
        }else if([sportMode isEqualToString:@"骑"]){
            if (distance < 5) {
                return;
            }
        }
        TrackDistance += distance;
        if (isPause) {
            TrackDistance -= distance;
        }
        distanceLabel.text = [NSString stringWithFormat:@"%.2fkm", TrackDistance/1000];
        NSLog(@"运动距离：%f", TrackDistance/1000);
    }
    [self.locationArray addObject:userLocation.location];
    self.preLocation = userLocation.location;
    if (self.locationArray.count > 1) {
        [self drawPolyLine];
    }
}

/**
 *  绘制轨迹路线
 **/
- (void)drawPolyLine {
    NSUInteger count = self.locationArray.count;
    BMKMapPoint *tempPoints = new BMKMapPoint[count];
    [self.locationArray enumerateObjectsUsingBlock:^(CLLocation *location, NSUInteger idx, BOOL *stop){
        BMKMapPoint locationPoint = BMKMapPointForCoordinate(location.coordinate);
        tempPoints[idx] = locationPoint;
//        NSLog(@"idx = %ld,tempPoints X = %f Y = %f",(unsigned long)idx,tempPoints[idx].x,tempPoints[idx].y);
    }];
    if (isPause) {
        [self.colorIndex addObject:[NSNumber numberWithInt:0]];
        isPause = NO;
    }else {
        [self.colorIndex addObject:[NSNumber numberWithInt:1]];
    }
    [self.polyLine setPolylineWithPoints:tempPoints count:count textureIndex:self.colorIndex];
    
    if (self.polyLine) {
        [self.mapView addOverlay:self.polyLine];
    }
    delete []tempPoints;
//    self.polyLine = nil;
}

/**
 *  根据polyline设置地图范围
 *
 *  @param polyLine
 */
- (void)mapViewFitPolyLine:(BMKPolyline *) polyLine {
    CGFloat ltX, ltY, rbX, rbY;
    if (polyLine.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyLine.points[0];
    ltX = pt.x, ltY = pt.y;
    rbX = pt.x, rbY = pt.y;
    for (int i = 1; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];
        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX , ltY);
    rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY);
    [self.mapView setVisibleMapRect:rect];
    self.mapView.zoomLevel = self.mapView.zoomLevel - 0.3;
}

#pragma mark - alertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 讯飞语音代理方法
//合成结束，此代理必须要实现
- (void) onCompleted:(IFlySpeechError *) error{}
//合成开始
- (void) onSpeakBegin{}
//合成缓冲进度
- (void) onBufferProgress:(int) progress message:(NSString *)msg{}
//合成播放进度
- (void) onSpeakProgress:(int) progress{}

#pragma mark - 私有方法
- (void)backToMainView {
    // 是否要关闭百度地图的一些设置
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showMenu {
    CGRect viewRect = detailsView.frame;
    if (switchMenu) {
        viewRect.size.height = DETAILSVIEW_HEIGHT;
        [UIView animateWithDuration:0.5
                              delay:0.0
             usingSpringWithDamping:1.0
              initialSpringVelocity:4.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             detailsView.frame = viewRect;
                         }
                         completion:^(BOOL finished){
                             switchMenu = NO;
                             [self showUI];
                         }];
        [UIView commitAnimations];
    }else if (!switchMenu) {
        viewRect.size.height = 0;
        [self hiddenUI];
        [UIView animateWithDuration:0.5
                              delay:0.0
             usingSpringWithDamping:1.0
              initialSpringVelocity:4.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             detailsView.frame = viewRect;
                         }
                         completion:^(BOOL finished){
                             switchMenu = YES;
                         }];
        [UIView commitAnimations];
    }
}

- (void)showUI {
    startTimeImageView.hidden = NO;
    startTimeLabel.hidden = NO;
    usedTimeImageView.hidden = NO;
    usedTimeLabel.hidden = NO;
    distanceImageView.hidden = NO;
    distanceLabel.hidden = NO;
    cutLineViewL.hidden = NO;
    cutLineViewR.hidden = NO;
}

- (void)hiddenUI {
    startTimeImageView.hidden = YES;
    startTimeLabel.hidden = YES;
    usedTimeImageView.hidden = YES;
    usedTimeLabel.hidden = YES;
    distanceImageView.hidden = YES;
    distanceLabel.hidden = YES;
    cutLineViewL.hidden = YES;
    cutLineViewR.hidden = YES;
}

// 暂停运动 显示暂停菜单
- (void)stopSport {
    if (isBegin) {
        [self showStopMenu];
        [switchButton setImage:[UIImage imageNamed:@"开始图标"] forState:UIControlStateNormal];
        // 关闭定位
        [self.bmkLocationService stopUserLocationService];
        // 关闭语音
        [_iFlySpeechSynthesizer stopSpeaking];
        isPause = YES;
        // 记录暂停时间点
        stopTime = [NSDate date];
        // 暂停后的那个点
        NSString *temp = [STOPMARK stringByAppendingString:[NSString stringWithFormat:@"Lon%fLat%f;", self.preLocation.coordinate.longitude, self.preLocation.coordinate.latitude]];
        NSString *temp1 = [motionTrack stringByAppendingString:temp];
        motionTrack = temp1;
        // 已完成公里数
        beenFinishLabel.text = [NSString stringWithFormat:@"%.2f", TrackDistance/1000];
        NSLog(@"暂停后的那个点：%@", self.preLocation);
    }else {
        [switchButton setImage:[UIImage imageNamed:@"暂停图标"] forState:UIControlStateNormal];
        isBegin = YES;
        // 开启
        [self.bmkLocationService startUserLocationService];
        // 开始运动 将当前运动记录写入
        /** 新的一条运动记录，需要创建一个新的UUID类型的uid */
        NSUUID *uuid = [NSUUID UUID];
        self.myAppDelegate.currentUUID = [uuid UUIDString];
        /** 将新纪录写到本地数据库，并且同步到服务器数据库 */
        [self saveRecordToTempFirst];
        /** 开启计时器，每三分钟写一次数据 */
        saveDataPer3MinTimer = [NSTimer scheduledTimerWithTimeInterval:180 target:self selector:@selector(saveRecordToTempPer3Min) userInfo:nil repeats:YES];
        countTimeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countTime) userInfo:nil repeats:YES];
        // 运动中
        [self.userDefaults setBool:YES forKey:@"isSport"];
        NSLog(@"%d", [self.userDefaults boolForKey:@"isSport"]);
    }
}

// 继续运动 隐藏暂停菜单
- (void)continueSport {
    [self hiddenStopMenu];
    [switchButton setImage:[UIImage imageNamed:@"暂停图标"] forState:UIControlStateNormal];
    [self.bmkLocationService startUserLocationService];
    isContinue = YES;
    // 计算当前时间与暂停时时间相差多少毫秒
    pauseTime += [[NSDate date] timeIntervalSinceDate:stopTime]*1000;
    NSLog(@"暂停时长：%d", pauseTime);
}

// 完成运动
- (void)doneSport {
    /** 将运动记录保存到本地数据库临时表 */
    [self saveRecordToTempFinally];
    /** 将运动记录保存到服务器 */
    HJFActivityIndicatorView *waitView = [[HJFActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 0.3*SCREEN_WIDTH, 0.8*0.3*SCREEN_WIDTH) andViewAlpha:0.8 andCornerRadius:8];
    waitView.center = self.view.center;
    [self.view addSubview:waitView];
    if ([SaveDataToServer saveDateToSportScore]) {
        [self.userDefaults setBool:NO forKey:@"isSport"];
        NSLog(@"存入服务器成功");
        
        // 显示整条运动轨迹 设置地图显示范围
        [self.bmkLocationService stopUserLocationService];
        [self mapViewFitPolyLine:self.polyLine];
        /** 关闭计时器 */
        [countTimeTimer invalidate];
        countTimeTimer = nil;
        [saveDataPer3MinTimer invalidate];
        saveDataPer3MinTimer = nil;
        
        
        /** 将暂停界面去掉后截图 */
        if (isStopMenu) {
            [self hiddenStopMenu];
        }
        UIImage *screenView = [self screenView];
        /** 沙盒目录 */
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"screenView.png"]];   // 保存文件的名称
        [UIImagePNGRepresentation(screenView)writeToFile:filePath atomically:YES]; // 保存成功会返回YES
        

        // 计算出多少积分并且提醒用户 还要往本地数据库积分表写入数据
        NSNumber *sportType;
        if ([sportMode isEqualToString:@"走"]) {
            sportType = [NSNumber numberWithInt:0];
        }else if ([sportMode isEqualToString:@"跑"]){
            sportType = [NSNumber numberWithInt:1];
        }else if ([sportMode isEqualToString:@"骑"]){
            sportType = [NSNumber numberWithInt:2];
        }
        NSTimeInterval endTimestamp = [endTime timeIntervalSince1970];
        NSString *userId = [self.userDefaults objectForKey:@"userId"];
        [self intervalSinceNow:endTime];
        NSLog(@"userid:%@, sporttype:%@, trackdistance:%@, duration:%@, endtimes:%@", userId, sportType, [NSNumber numberWithFloat:TrackDistance], [NSNumber numberWithInt:duration], [NSNumber numberWithFloat:endTimestamp]);
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              userId, @"userId",
                              sportType, @"sportType",
                              [NSNumber numberWithFloat:TrackDistance/1000], @"distance",
                              [NSNumber numberWithInt:duration], @"duration",
                              [NSNumber numberWithLong:endTimestamp], @"endTimestamp",
                              nil];
        /** 请求服务器接口 */
        [AVCloud callFunctionInBackground:@"GainIntegralByPersonalSport" withParameters:dict block:^(id object, NSError *error) {
            NSNumber *resultCode = object[@"resultCode"];
            if ([resultCode intValue] == 200) {
                [waitView removeFromSuperview];
                NSNumber *integral = object[@"integralGained"];
                int integralNumber = [integral intValue];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"您已运动%.2f公里，成功兑换%d个积分！", TrackDistance/1000, integralNumber] delegate:self cancelButtonTitle:@"再运动一次" otherButtonTitles:nil, nil];
                alertView.tag = 0;
                [alertView show];
                /** 将获得积分结果写入本地数据库 */
                [SaveDataToLocalDB saveDataToIntegralGained:self.myAppDelegate.currentUUID UserId:userId GainTime:endTime Integral:integralNumber GainReason:1];
            }else {
                NSString *errorMessage = object[@"errorMessage"];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:errorMessage delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                alertView.tag = 1;
                [alertView show];
            }
        }];
        
    }else {
        // 提示保存失败
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"保存数据失败，请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)showStopMenu {
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:1.0
          initialSpringVelocity:4.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         cover.hidden = NO;
                         cover.alpha = 0.8;
                         stopImageView.transform = CGAffineTransformMakeScale(STOPIMAGEVIEW_WIDTH, STOPIMAGEVIEW_HEIGHT);
                         confirmButton.transform = CGAffineTransformMakeScale(CONFIRMBUTTON_WIDTH, CONFIRMBUTTON_WIDTH);
                         continueButton.transform = CGAffineTransformMakeScale(CONFIRMBUTTON_WIDTH, CONFIRMBUTTON_WIDTH);
                     }
                     completion:^(BOOL isfinish) {
                         beenFinishLabel.hidden = NO;
                         successFinishLabel.hidden = NO;
                         isStopMenu = YES;
                     }];
    [UIView commitAnimations];
}

- (void)hiddenStopMenu {
    beenFinishLabel.hidden = YES;
    successFinishLabel.hidden = YES;
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:1.0
          initialSpringVelocity:4.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         cover.alpha = 0;
                         stopImageView.transform = CGAffineTransformIdentity;
                         confirmButton.transform = CGAffineTransformIdentity;
                         continueButton.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL isfinish) {
                         cover.hidden = YES;
                         isStopMenu = NO;
                     }];
    [UIView commitAnimations];
}

- (void)addPreviousPoints {
    
}

/**
 *  新运动记录，往本地数据库写入初始数据
 **/
- (void)saveRecordToTempFirst {
    /** 用户id */
    NSString *userId = [self.userDefaults objectForKey:@"userId"];
    /** 开始时间 */
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:[NSDate date]];
    startTime = [[NSDate date]  dateByAddingTimeInterval: interval];
    NSLog(@"starttime:%@", startTime);
    /** 运动类型 */
    int sportType;
    if ([sportMode isEqualToString:@"走"]) {
        sportType = 0;
    }else if ([sportMode isEqualToString:@"跑"]) {
        sportType = 1;
    }else if ([sportMode isEqualToString:@"骑"]) {
        sportType = 2;
    }
    [SaveDataToLocalDB saveDataToSportScoreTempFirstWithUId:self.myAppDelegate.currentUUID UserId:userId SportType:sportType StartTime:startTime EndTime:nil PauseTime:0 MotionTrack:motionTrack Distance:0];
    [SaveDataToServer saveDateToSportScoreTemp];
}

/**
 *  每隔三分钟往数据库写入运动数据
 **/
- (void)saveRecordToTempPer3Min {
    [SaveDataToLocalDB saveDataToSportScoreTempPer3MinWithPauseTime:pauseTime MotionTrack:motionTrack Distance:TrackDistance];
    [SaveDataToServer saveDateToSportScoreTemp];
}

/**
 *  结束运动，往本地数据库写入完整数据
 **/
- (void)saveRecordToTempFinally {
    /** 结束时间 */
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:[NSDate date]];
    endTime = [[NSDate date]  dateByAddingTimeInterval: interval];
    NSLog(@"完成时间：%@", endTime);
    [SaveDataToLocalDB saveDataToSportScoreTempFinallyWithEndTime:endTime PauseTime:pauseTime MotionTrack:motionTrack Distance:TrackDistance];
}

/** 运动时间计时 */
- (void)countTime {
    NSArray *array = [usedTimeLabel.text componentsSeparatedByString:@":"];
    int second = [[array objectAtIndex:2] intValue];
    int minute = [[array objectAtIndex:1] intValue];
    int hour = [[array objectAtIndex:0] intValue];
    second++;
    second %= 60;
    if ((second %= 60) == 0) {
        minute++;
        minute %= 60;
        if ((minute %= 60) == 0) {
            hour++;
            hour %= 24;
        }
    }
    NSString *finallyTime = [NSString stringWithFormat:@"%d:%d:%d", hour, minute, second];
    usedTimeLabel.text = finallyTime;
    // 语音合成
    if ((minute % 15 == 0 && minute > 15) || TrackDistance-currentDistance > 1000) {
        // 计算平局速度
        currentDistance = TrackDistance;
        int totalSeconod = 3600*hour+minute*60+second;
        CGFloat averageSpeed = (TrackDistance/1000/totalSeconod)*3600; // 平均速度，公里/小时
        [_iFlySpeechSynthesizer startSpeaking:[NSString stringWithFormat:@"您当前跑了%.1f公里, 平均速度%.1f公里每小时", TrackDistance/1000, averageSpeed]];
    }
}

/**
 *  一个时间与现在时间的时间差
 **/
- (NSString *)intervalSinceNow:(NSDate *)theDate
{
    NSLog(@"%@", theDate);
    NSDate *nowDate = [NSDate date];
    NSTimeInterval now = [nowDate timeIntervalSince1970]*1;
    NSTimeInterval late=[theDate timeIntervalSince1970]*1;
    
    NSTimeInterval cha=now-late;
    
    /** 真实的运动时间 */
    duration = cha-pauseTime;
    
    int sen = [[NSString stringWithFormat:@"%d", (int)cha%60] intValue];
    
    int min = [[NSString stringWithFormat:@"%d", (int)cha/60%60] intValue];
    
    int house = [[NSString stringWithFormat:@"%d", (int)cha/3600] intValue];
    
    NSString *timeString=[NSString stringWithFormat:@"%d:%d:%d",house,min,sen];

    return timeString;
}

/**
 *  截取屏幕图片
 **/
- (UIImage*)screenView{
    CGRect rect = self.navigationController.view.frame;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.navigationController.view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


#pragma mark - Life Cycle
- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor grayColor];
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || kCLAuthorizationStatusRestricted == [CLLocationManager authorizationStatus]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"未开启定位空能。设置->隐私->定位" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alertView show];
        }else {
            //定位功能可用，开始定位
            [self UILayout];
            [self BMKMapViewInit];
            [self sportDataInit];
            [self IFlyInit];
        };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [detailsView removeFromSuperview];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"黑色背景"] forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.mapView.delegate = nil;
    self.bmkLocationService.delegate = nil;
}

@end