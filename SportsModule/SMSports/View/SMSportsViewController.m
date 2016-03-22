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

#pragma mark - 百度地图
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>

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

@interface SMSportsViewController() <BMKMapViewDelegate, BMKLocationServiceDelegate>

/** 上一次的位置 */
@property (nonatomic, strong) CLLocation *preLocation;

/** 位置数组 */
@property (nonatomic, strong) NSMutableArray *locationArray;

/** 轨迹线 */
@property (nonatomic, strong) BMKPolyline *polyLine;

/** 百度地图View */
@property (nonatomic, strong) BMKMapView *mapView;

/** 百度定位地图服务 */
@property (nonatomic, strong) BMKLocationService *bmkLocationService;

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
}

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
        
        sportMode           = sportmode;
    }
    return self;
}

#pragma mark - 导航栏设置
- (void)NavigationInit {
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回图标"] style:UIBarButtonItemStylePlain target:self action:@selector(backToMainView)];
    leftButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] init];
    [rightButton setTitle:@"完成"];
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
    startTimeLabel.text = @"09:00:00";
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
    usedTimeLabel.text = @"00:22:22";
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
    distanceLabel.text = @"10km";
    distanceLabel.textAlignment = NSTextAlignmentCenter;
    distanceLabel.font = [UIFont systemFontOfSize:12];
    [detailsView addSubview:distanceLabel];
    
    [self.navigationController.navigationBar addSubview:detailsView];
    
    // 开始\暂停按钮
    switchButton.frame = CGRectMake(0, 0, SWITCHBUTTON_WIDTH, SWITCHBUTTON_WIDTH);
    switchButton.center = CGPointMake(CENTER_X, SWITCHBUTTON_CENTER_Y);
    [switchButton setImage:[UIImage imageNamed:@"暂停图标"] forState:UIControlStateNormal];
    [switchButton addTarget:self action:@selector(stopSport) forControlEvents:UIControlEventTouchUpInside];
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
    beenFinishLabel.text = @"12.00";
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
    
    // 百度地图模块
    [self BMKMapInit];
    [_bmkLocationService startUserLocationService];
    BMKCoordinateRegion adjustRegion = [self.mapView regionThatFits:BMKCoordinateRegionMake(self.bmkLocationService.userLocation.location.coordinate, BMKCoordinateSpanMake(0.02f,0.02f))];
    [self.mapView setRegion:adjustRegion animated:YES];
}

#pragma mark - 百度地图设置
/*
 *  百度地图初始化
 */
- (void)BMKMapInit {
    // 初始化百度位置服务
    [self BMKLocationServiceInit];
    self.mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    [self setMapViewProperty];
    [self.view insertSubview:self.mapView atIndex:0];
}

/**
 *  设置百度mapview的一些属性
 */
- (void)setMapViewProperty {
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = BMKUserTrackingModeNone;
    self.mapView.rotateEnabled = YES;
    self.mapView.showMapScaleBar = YES;
    self.mapView.mapScaleBarPosition = CGPointMake(self.view.frame.size.width-50, self.view.frame.size.height-50);
    
    // 定位图层自定义样式参数
    BMKLocationViewDisplayParam *displayParam = [[BMKLocationViewDisplayParam alloc] init];
    displayParam.isRotateAngleValid = NO;   //  跟随态旋转角度是否生效
    displayParam.isAccuracyCircleShow = NO; //  精度圈显示
    displayParam.locationViewOffsetX = NO;  //  定位偏移量（经度
    displayParam.locationViewOffsetY = NO;  //  定位偏移量（维度
    displayParam.locationViewImgName = @"MOVE";
    [self.mapView updateLocationViewWithParam:displayParam];
}

/*
 *  初始化百度位置服务
 */
- (void)BMKLocationServiceInit {
    self.bmkLocationService = [[BMKLocationService alloc] init];
    // 距离过滤， 表示每移动多少距离更新一次位置
    _bmkLocationService.distanceFilter = 10;
    // 设置定位精度
    _bmkLocationService.desiredAccuracy = kCLLocationAccuracyBest;
}

#pragma mark - 百度地图代理方法
/**
 *  定位失败调用该方法
 *
 */
- (void)didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"定位失败：%@", error);
}

/**
 *  位置更新后，调用此函数
 *  @param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    NSLog(@"新的用户位置");
    if (userLocation.location.horizontalAccuracy > kCLLocationAccuracyNearestTenMeters) {
        NSLog(@"水平精准度大于10米");
    }
}

/**
 *  用户方向更新后 调用此函数
 *  @param userlocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation {
    [self.mapView updateLocationData:userLocation];
}

/**
 *  开始记录轨迹
 *  @param userLocation 实时更新的位置信息
 */
- (void)recordTrackingWithUserLocation:(BMKUserLocation *)userLocation {
    if (self.preLocation) {
        CGFloat distance = [userLocation.location distanceFromLocation:self.preLocation];
        NSLog(@"与上一位置点的距离为%f", distance);
        if (distance < 5) {
            return;
        }
    }
    [self.locationArray addObject:userLocation.location];
    self.preLocation = (CLLocation *)userLocation;
    
    [self drawWalkPolyline];
}

/*
 *  绘制轨迹路线
 */
- (void)drawWalkPolyline {
    NSInteger count = self.locationArray.count;
    BMKMapPoint *tempPoints = new BMKMapPoint[count];
    
    [self.locationArray enumerateObjectsUsingBlock:^(CLLocation *location, NSUInteger idx, BOOL *stop) {
        BMKMapPoint locationPoint = BMKMapPointForCoordinate(location.coordinate);
        tempPoints[idx] = locationPoint;
    }];
    
    if (self.polyLine) {
        [self.mapView addOverlay:self.polyLine];
    }
    
    delete []tempPoints;
    
    [self mapViewFitPolyLine:self.polyLine];
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
    [self showStopMenu];
    [switchButton setImage:[UIImage imageNamed:@"开始图标"] forState:UIControlStateNormal];
}

// 继续运动 隐藏暂停菜单
- (void)continueSport {
    [self hiddenStopMenu];
    [switchButton setImage:[UIImage imageNamed:@"暂停图标"] forState:UIControlStateNormal];
}

// 完成运动
- (void)doneSport {
    [self.navigationController popViewControllerAnimated:YES];
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
                     }];
    [UIView commitAnimations];
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor grayColor];
    // 地图图片测试
//    UIImageView *testMapImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"地图测试图片"]];
//    testMapImage.frame = [UIScreen mainScreen].bounds;
//    [self.view addSubview:testMapImage];
    [self UILayout];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [detailsView removeFromSuperview];
    self.navigationController.navigationBar.translucent = NO;
}

@end
