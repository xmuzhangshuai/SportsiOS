//
//  SaveDataToServer.m
//  SportsModule
//
//  Created by Hjf on 16/3/26.
//  Copyright © 2016年 xxn. All rights reserved.
//

#import "SaveDataToServer.h"
#import <AVOSCloud/AVOSCloud.h>
#import <FMDB/FMDB.h>
#import "AppDelegate.h"

@implementation SaveDataToServer

+ (BOOL)saveDateToSportScoreTemp {
    /** 记录是否更新服务器成功 */
    __block BOOL isUpload = false;
    AppDelegate *myAppDelegate = [[UIApplication sharedApplication] delegate];
    FMDatabase *db = [FMDatabase databaseWithPath:myAppDelegate.dataBasePath];
    [db open];
    if ([myAppDelegate.currentUUID isEqualToString:@""]) {
        /** 去本地数据库获取endtime为空的记录 */
        NSString *findCurrentSportStr = @"select * from sportrecordtemp";
        FMResultSet *resultSet = [db executeQuery:findCurrentSportStr];
        while ([resultSet next]) {
            myAppDelegate.currentUUID = [resultSet stringForColumn:@"uid"];
        }
    }
    /** 根据currentUUID来获取相关的数据 对服务器上的数据库进行更新 */
    NSString *queryStr = [NSString stringWithFormat:@"select * from sportrecordtemp"];
    FMResultSet *resultSet = [db executeQuery:queryStr];
    while ([resultSet next]) {
        int pauseTime = [resultSet intForColumn:@"pauseTime"];
        NSString *motionTrack = [resultSet stringForColumn:@"motionTrack"];
        CGFloat trackDistance = [resultSet doubleForColumn:@"distance"];
        NSString *endTimeStr = [resultSet stringForColumn:@"endTime"];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss +0000"];
        NSDate *endTime = [df dateFromString:endTimeStr];
        AVQuery *query = [AVQuery queryWithClassName:@"SportRecordTmp"];
        [query whereKey:@"uid" equalTo:myAppDelegate.currentUUID];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects.count == 0) {
                // 没有此条运动记录 插入新纪录
                NSString *uId = [resultSet stringForColumn:@"uid"];
                NSString *userId = [resultSet stringForColumn:@"userid"];
                int sportMode = [resultSet intForColumn:@"sporttype"];
                NSDate *startTime = [resultSet dateForColumn:@"starttime"];
                AVObject *newSport = [AVObject objectWithClassName:@"SportRecordTmp"];
                [newSport setObject:uId forKey:@"uid"];
                [newSport setObject:userId forKey:@"userID"];
                [newSport setObject:[NSNumber numberWithInt:sportMode] forKey:@"sportType"];
                [newSport setObject:startTime forKey:@"startTime"];
                [newSport setObject:endTime forKey:@"endTime"];
                [newSport setObject:[NSNumber numberWithInt:pauseTime] forKey:@"pauseTime"];
                [newSport setObject:motionTrack forKey:@"motionTrack"];
                [newSport setObject:[NSNumber numberWithFloat:trackDistance] forKey:@"distance"];
                isUpload = [newSport save];
            }else {
                AVObject *currentSport = [objects objectAtIndex:0];
                [currentSport setObject:motionTrack forKey:@"motionTrack"];
                [currentSport setObject:[NSNumber numberWithFloat:trackDistance] forKey:@"distance"];
                [currentSport setObject:[NSNumber numberWithInt:pauseTime] forKey:@"pauseTime"];
                [currentSport setObject:endTime forKey:@"endTime"];
                isUpload = [currentSport save];
            }
        }];
    }
    [db close];
    return isUpload;
}

+ (BOOL)saveDateToSportScore {
    /** 记录是否更新服务器成功 */
    BOOL isUpload = false;
    AppDelegate *myAppDelegate = [[UIApplication sharedApplication] delegate];
    FMDatabase *db = [FMDatabase databaseWithPath:myAppDelegate.dataBasePath];
    [db open];
    if ([myAppDelegate.currentUUID isEqualToString:@""]) {
        /** 去本地数据库获取记录 */
        NSString *findCurrentSportStr = @"select * from sportrecordtemp";
        FMResultSet *resultSet = [db executeQuery:findCurrentSportStr];
        while ([resultSet next]) {
            myAppDelegate.currentUUID = [resultSet stringForColumn:@"uid"];
        }
    }
    /** 根据currentUUID来获取相关的数据 对服务器上的数据库进行更新 */
    NSString *queryStr = [NSString stringWithFormat:@"select * from sportrecordtemp"];
    FMResultSet *resultSet = [db executeQuery:queryStr];
    while ([resultSet next]) {
        NSString *uId = [resultSet stringForColumn:@"uid"];
        NSString *userId = [resultSet stringForColumn:@"userid"];
        int sportMode = [resultSet intForColumn:@"sporttype"];
        NSString *startTimeStr = [resultSet stringForColumn:@"starttime"];
        int pauseTime = [resultSet intForColumn:@"pausetime"];
        NSString *motionTrack = [resultSet stringForColumn:@"motiontrack"];
        CGFloat trackDistance = [resultSet doubleForColumn:@"distance"];
        NSString *endTimeStr = [resultSet stringForColumn:@"endtime"];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-HH-dd HH:mm:ss +0000"];
        NSDate *startTime = [df dateFromString:startTimeStr];
        NSDate *endTime = [df dateFromString:endTimeStr];
        AVObject *newSport = [AVObject objectWithClassName:@"SportRecord"];
        [newSport setObject:uId forKey:@"uid"];
        [newSport setObject:userId forKey:@"userID"];
        [newSport setObject:[NSNumber numberWithInt:sportMode] forKey:@"sportType"];
        [newSport setObject:startTime forKey:@"startTime"];
        [newSport setObject:endTime forKey:@"endTime"];
        [newSport setObject:[NSNumber numberWithInt:pauseTime] forKey:@"pauseTime"];
        [newSport setObject:motionTrack forKey:@"motionTrack"];
        [newSport setObject:[NSNumber numberWithFloat:trackDistance] forKey:@"distance"];
        isUpload = [newSport save];
    }
    [db close];
    return isUpload;
}

@end
