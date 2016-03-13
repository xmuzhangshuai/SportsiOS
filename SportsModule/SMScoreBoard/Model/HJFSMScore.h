//
//  HJFSMScore.h
//  SportsModule
//
//  Created by Hjf on 16/3/12.
//  Copyright © 2016年 xxn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HJFSMScore : NSObject

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userScore;
@property (nonatomic, copy) NSString *userRank;
@property (nonatomic, strong) NSString *userPicUrl;

- (HJFSMScore *)initWithDict:(NSDictionary *)dict;

+ (HJFSMScore *)scoreWithDict:(NSDictionary *)dict;

@end
