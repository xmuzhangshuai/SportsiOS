//
//  SaveDataToLocalDB.m
//  SportsModule
//
//  Created by Hjf on 16/3/26.
//  Copyright © 2016年 xxn. All rights reserved.
//

#import "SaveDataToLocalDB.h"
#import <FMDB/FMDB.h>
#import "AppDelegate.h"

@implementation SaveDataToLocalDB

+ (BOOL)saveDataToSportScoreTempFinallyWithEndTime:(NSDate *)endTime PauseTime:(int)pauseTime MotionTrack:(NSString *)motionTrack Distance:(float)distance {
    NSLog(@"endtime:%@", endTime);
    AppDelegate *myAppDelegate = [[UIApplication sharedApplication] delegate];
    FMDatabase *db = [FMDatabase databaseWithPath:myAppDelegate.dataBasePath];
    [db open];
    NSString *query;
    query = [NSString stringWithFormat:@"update sportrecordtemp set endtime = '%@', pausetime = %d, motiontrack = '%@', distance = %f where uid = '%@'", endTime, pauseTime, motionTrack, distance, myAppDelegate.currentUUID];
    BOOL success = [db executeUpdate:query];
    if (success) {
        [db close];
        return YES;
    }
    [db close];
    return NO;
}

+ (BOOL)saveDataToSportScoreTempPer3MinWithPauseTime:(int)pauseTime MotionTrack:(NSString *)motionTrack Distance:(float)distance {
    AppDelegate *myAppDelegate = [[UIApplication sharedApplication] delegate];
    FMDatabase *db = [FMDatabase databaseWithPath:myAppDelegate.dataBasePath];
    [db open];
    NSString *query;
    query = [NSString stringWithFormat:@"update sportrecordtemp set pausetime = %d, motiontrack = '%@', distance = %f where uid = '%@'", pauseTime, motionTrack, distance, myAppDelegate.currentUUID];
    BOOL success = [db executeUpdate:query];
    if (success) {
        [db close];
        return YES;
    }
    [db close];
    return NO;
}

+ (BOOL)saveDataToSportScoreTempFirstWithUId:(NSString *)uid UserId:(NSString *)userId SportType:(int)sportType StartTime:(NSDate *)startTime EndTime:(NSDate *)endtime PauseTime:(int)pauseTime MotionTrack:(NSString *)motionTrack Distance:(float)distance {
    NSLog(@"starttime:%@", startTime);
    AppDelegate *myAppDelegate = [[UIApplication sharedApplication] delegate];
    FMDatabase *db = [FMDatabase databaseWithPath:myAppDelegate.dataBasePath];
    [db open];
    NSString *query;
    query = [NSString stringWithFormat:@"delete from sportrecordtemp"];
    BOOL success = [db executeUpdate:query];
    if (success) {
        query = [NSString stringWithFormat:@"insert into sportrecordtemp (uid, userid, sporttype, starttime, endtime, pausetime, motiontrack, distance) values ('%@', '%@', %d, '%@', '%@', %d, '%@', %f);", uid, userId, sportType, startTime, endtime, pauseTime, motionTrack, distance];
        success = [db executeUpdate:query];
        if (success) {
            [db close];
            return YES;
        }
    }
    [db close];
    return NO;
}

+ (BOOL)saveDataToSportScore:(NSString *)uid UserId:(NSString *)userId SportType:(int)sportType StartTime:(NSDate *)startTime endTime:(NSDate *)endTime PauseTime:(int)pauseTime MotionTrack:(NSString *)motionTrack Distance:(float)distance {
    
    AppDelegate *myAppDelegate = [[UIApplication sharedApplication] delegate];
    FMDatabase *db = [FMDatabase databaseWithPath:myAppDelegate.dataBasePath];
    [db open];
    NSString *query;
    query = [NSString stringWithFormat:@"insert into sportrecord (uid, userid, sporttype, starttime, endtime, pausetime, motiontrack, distance) values ('%@', '%@', %d, '%@', '%@', %d, '%@', %f)", uid, userId, sportType, startTime, endTime, pauseTime, motionTrack, distance];
    BOOL success = [db executeUpdate:query];
    if (success) {
        [db close];
        return YES;
    }
    [db close];
    return NO;
}

+ (BOOL)saveDataToIntegralGained:(NSString *)uid UserId:(NSString *)userId GainTime:(NSDate *)gainTime Integral:(int)integral GainReason:(int)gainReason {
    
    AppDelegate *myAppDelegate = [[UIApplication sharedApplication] delegate];
    FMDatabase *db = [FMDatabase databaseWithPath:myAppDelegate.dataBasePath];
    [db open];
    NSString *query;
    query = [NSString stringWithFormat:@"insert into integralgained (uid, useid, gaintime, integral, gainreason) values ('%@', '%@', '%@', %d, %d)", uid, userId, gainTime, integral, gainReason];
    BOOL success = [db executeUpdate:query];
    if (success) {
        [db close];
        return YES;
    }
    [db close];
    return NO;
}

@end
