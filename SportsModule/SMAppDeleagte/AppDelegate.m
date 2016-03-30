//
//  AppDelegate.m
//  SportsModule
//
//  Created by Hjf on 16/3/11.
//  Copyright © 2016年 xxn. All rights reserved.
//

#import "AppDelegate.h"
#import "SMLoginViewController.h"

/*
 *  LeanCloud头文件
 */
#import <AVOSCloud/AVOSCloud.h>

/*
 *  百度地图头文件
 */
#import <BaiduMapAPI_Base/BMKBaseComponent.h>

/*
 *  数据库FMDB头文件
 */
#import <FMDB.h>

/** 讯飞语音 */
#import "iflyMSC/IFlyMSC.h"

@interface AppDelegate () <BMKGeneralDelegate>

@property (nonatomic, strong) BMKMapManager *mapManager;
@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 数据库创建
    self.dataBasePath = [self DataBasePath];
    NSLog(@"shahe:%@", self.dataBasePath);
    [self dataBaseCreate:self.dataBasePath];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
//    if (![self.userDefaults boolForKey:@"everLaunched"]) {
//        // 缓存字段创建
//        [self.userDefaults setObject:@"" forKey:@"userId"];
//        [self.userDefaults setBool:NO forKey:@"isSport"];
//        [self.userDefaults setObject:@"" forKey:@"currentIntegral"];
//    }
    
    // LeanCloud ID设置
    [AVOSCloud setApplicationId:@"WGUoySgrc7k8FVz2dvWNkJAd-gzGzoHsz" clientKey:@"vHarYvaUm7SuGQQSoOFGVA4m"];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    // 主界面 登陆
    SMLoginViewController *loginViewController = [[SMLoginViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    self.window.rootViewController = navigationController;
    
    // 百度地图实例化
    self.mapManager = [[BMKMapManager alloc] init];
    BOOL ret = [self.mapManager start:@"6uqF5fg6mZkR9Zx1kghU8D83" generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed");
    }
    
    // 讯飞语音
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",@"56e62dd4"];
    [IFlySpeechUtility createUtility:initString];

    // 导航栏全局设置
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"黑色背景"] forBarMetrics:UIBarMetricsDefault];
    [UINavigationBar appearance].translucent = NO;
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    // 一些全局变量的初始化
    self.currentUUID = @"";
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - 百度地图代理
- (void)onGetNetworkState:(int)iError {
    if (0 == iError) {
        NSLog(@"联网成功");
    }else {
        NSLog(@"state: %d", iError);
    }
}

- (void)onGetPermissionState:(int)iError {
    if (0 == iError) {
        NSLog(@"授权成功");
    }else {
        NSLog(@"Pstate: %d", iError);
    }
}

#pragma mark - 数据库
#pragma mark -- 数据库路径获取
- (NSString *)DataBasePath {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *document = [path objectAtIndex:0];
    return [document stringByAppendingPathComponent:@"SportModule.sqlite"];
}


#pragma mark -- 数据库创建
- (void)dataBaseCreate:(NSString *)dataBasePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    FMDatabase *db = [FMDatabase databaseWithPath:dataBasePath];
    if (![fileManager fileExistsAtPath:dataBasePath]) {
        NSLog(@"未创建数据库，正在创建。。。");
        if ([db open]) {
            if ([self tableCreate:db]) {
                NSLog(@"表创建成功");
                [db close];
            }else {
                NSLog(@"表创建失败");
            }
        }else {
            NSLog(@"数据库打开失败");
        }
    }
}
#pragma mark -- 表创建
- (BOOL)tableCreate:(FMDatabase *)dataBase {
    BOOL result = [dataBase executeUpdate:
                   @"create table if not exists IntegralGained (uid text PRIMARY KEY, useId text NOT NULL, gainTime date Not NULL, integral int NOT NULL, gainReason int NOT NULL);"];
    BOOL result1 = [dataBase executeUpdate:
                    @"create table if not exists SportRecord (uid text PRIMARY KEY, userId text NOT NULL, sportType int not null, starttime date not null, endtime date not null, pausetime int, motiontrack text not null, distance float);"];
    BOOL result2 = [dataBase executeUpdate:
                    @"create table if not exists SportRecordTemp (uid text PRIMARY KEY, userId text NOT NULL, sportType int not null, starttime date not null, endtime date not null, pausetime int, motiontrack text not null, distance float);"];
    return result && result1 && result2;
}

@end
