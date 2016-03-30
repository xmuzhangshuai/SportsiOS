//
//  IntegralGainedHistory.h
//  SportsModule
//
//  Created by Hjf on 16/3/30.
//  Copyright © 2016年 xxn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IntegralGainedHistory : NSObject

/** 获取日期 */
@property (nonatomic, strong)NSString *gainedDate;

/** 获取分数 */
@property (nonatomic) NSUInteger      integral;

@end
