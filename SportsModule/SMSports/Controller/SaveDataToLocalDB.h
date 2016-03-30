//
//  SaveDataToLocalDB.h
//  SportsModule
//
//  Created by Hjf on 16/3/26.
//  Copyright © 2016年 xxn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SaveDataToLocalDB : NSObject

/** 将数据保存到本地数据库运动记录临时表 */
+ (BOOL)saveDataToSportScoreTempFinallyWithEndTime:(NSDate *)endTime PauseTime:(int)pauseTime MotionTrack:(NSString *)motionTrack Distance:(float)distance;

+ (BOOL)saveDataToSportScoreTempPer3MinWithPauseTime:(int)pauseTime MotionTrack:(NSString *)motionTrack Distance:(float)distance;

+ (BOOL)saveDataToSportScoreTempFirstWithUId:(NSString *)uid UserId:(NSString *)userId SportType:(int)sportType StartTime:(NSDate *)startTime EndTime:(NSDate *)endtime PauseTime:(int)pauseTime MotionTrack:(NSString *)motionTrack Distance:(float)distance;

/** 将数据保存到本地数据库运动记录正式表 */
+ (BOOL)saveDataToSportScore:(NSString *)uid UserId:(NSString *)userId SportType:(int)sportType StartTime:(NSDate *)startTime endTime:(NSDate *)endTime PauseTime:(int)pauseTime MotionTrack:(NSString *)motionTrack Distance:(float)distance;

+ (BOOL)saveDataToIntegralGained:(NSString *)uid UserId:(NSString *)userId GainTime:(NSDate *)gainTime Integral:(int)integral GainReason:(int)gainReason;

@end
