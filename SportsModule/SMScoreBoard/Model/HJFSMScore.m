//
//  HJFSMScore.m
//  SportsModule
//
//  Created by Hjf on 16/3/12.
//  Copyright © 2016年 xxn. All rights reserved.
//

#import "HJFSMScore.h"

@implementation HJFSMScore

- (HJFSMScore *)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+ (HJFSMScore *)scoreWithDict:(NSDictionary *)dict {
    HJFSMScore *score = [[HJFSMScore alloc] initWithDict:dict];
    return score;
}

@end
