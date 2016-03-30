//
//  SportRecord.h
//  SportsModule
//
//  Created by Hjf on 16/3/30.
//  Copyright © 2016年 xxn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SportRecord : NSObject

/** 运动日期 */
@property (nonatomic, strong)NSString *sportDate;

/** 运动距离和时间 */
@property (nonatomic, strong)NSString *distanceAndTime;

@end
