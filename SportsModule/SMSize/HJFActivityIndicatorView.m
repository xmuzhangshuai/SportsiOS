//
//  HJFActivityIndicatorView.m
//  SportsModule
//
//  Created by Hjf on 16/3/22.
//  Copyright © 2016年 xxn. All rights reserved.
//

#import "HJFActivityIndicatorView.h"

@interface HJFActivityIndicatorView()

@end

@implementation HJFActivityIndicatorView {
    UIActivityIndicatorView *myActivityIndecatorView;
    CGFloat                 _alpha;
    NSInteger               _cornerRadius;
}

- (instancetype)initWithFrame:(CGRect)frame andViewAlpha:(CGFloat)alpha andCornerRadius:(NSInteger)cornerRadius {
    if (self = [super initWithFrame:frame]) {
        myActivityIndecatorView = [[UIActivityIndicatorView alloc] init];
        _alpha = alpha;
        _cornerRadius = cornerRadius;
        
        [self Init];
    }
    return self;
}

- (void)Init {
    self.backgroundColor = [UIColor blackColor];
    self.clipsToBounds = YES;
    self.layer.cornerRadius = _cornerRadius;
    self.alpha = _alpha;
    
    /** 设置白色等待 */
    myActivityIndecatorView.center = self.center;
    [myActivityIndecatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [myActivityIndecatorView startAnimating];
    [self addSubview:myActivityIndecatorView];
}

@end
