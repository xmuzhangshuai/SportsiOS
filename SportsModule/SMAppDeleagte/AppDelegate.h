//
//  AppDelegate.h
//  SportsModule
//
//  Created by Hjf on 16/3/11.
//  Copyright © 2016年 xxn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
/** 本地数据库路径 */
@property (nonatomic, strong) NSString *dataBasePath;

/** 总运动里程 */
@property (nonatomic) CGFloat   totalTrackDistance;

/** 记录当前的运动uId 类型UUID */
@property (nonatomic) NSString  *currentUUID;

/** 后台定位 */
@property (nonatomic, unsafe_unretained) UIBackgroundTaskIdentifier bgTask;

@end

