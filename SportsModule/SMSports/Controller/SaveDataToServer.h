//
//  SaveDataToServer.h
//  SportsModule
//
//  Created by Hjf on 16/3/26.
//  Copyright © 2016年 xxn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SaveDataToServer : NSObject

/** 将运动记录保存到服务器运动记录临时表 */
+ (BOOL)saveDateToSportScoreTemp;

/** 将运动记录保存到服务器运动记录表 */
+ (BOOL)saveDateToSportScore;

@end
