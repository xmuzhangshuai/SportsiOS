//
//  SMLoginViewController.m
//  SportsModule
//
//  Created by Hjf on 16/3/11.
//  Copyright © 2016年 xxn. All rights reserved.
//

#import "SMLoginViewController.h"
#import "AFNetworking.h"
#import "UISize.h"
#import "SMSize.h"
#import "SMMainViewController.h"

#pragma mark - 控件尺寸
#define USERID_CENTER_X 0.5*SCREEN_WIDTH
#define USERID_CENTER_Y 0.26*SCREEN_HEIGHT
#define USERID_WIDTH    0.72*SCREEN_WIDTH
#define USERID_HEIGHT   0.06*SCREEN_HEIGHT

#define LOGINBUTTON_CENTER_X    0.5*SCREEN_WIDTH
#define LOGINBUTTON_CENTER_Y    0.425*SCREEN_HEIGHT


#define LEFTPADDING     0.02*SCREEN_HEIGHT
@interface SMLoginViewController ()

@end

@implementation SMLoginViewController {
    UITextField *userIdTF;
    UIButton    *loginButton;
}

- (id)init {
    if (self = [super init]) {
        userIdTF    = [[UITextField alloc] init];
        loginButton = [[UIButton alloc] init];
    }
    
    return self;
}

#pragma mark - 导航栏初始化
- (void)NavigationInit {
    self.navigationItem.title = @"登录";
}

#pragma mark - mark 控件布局
- (void)UILayout {
    userIdTF.frame = CGRectMake(0, 0, USERID_WIDTH, USERID_HEIGHT);
    userIdTF.center = CGPointMake(USERID_CENTER_X, USERID_CENTER_Y);
    userIdTF.backgroundColor = [UIColor whiteColor];
    userIdTF.placeholder = @"请输入用户识别码";
    [userIdTF setValue:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    [SMLoginViewController setTextFieldLeftPadding:userIdTF forWidth:LEFTPADDING];
    userIdTF.layer.borderWidth = 1;
    userIdTF.layer.borderColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0].CGColor;
    userIdTF.layer.cornerRadius = CORNER_REDIUS;
    
    loginButton.frame = CGRectMake(0, 0, BLACKBUTTON_WIDTH, BLACKBUTTON_HEIGHT);
    loginButton.center = CGPointMake(LOGINBUTTON_CENTER_X, LOGINBUTTON_CENTER_Y);
    loginButton.backgroundColor = [UIColor blackColor];
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    loginButton.layer.cornerRadius = CORNER_REDIUS;
    [loginButton addTarget:self action:@selector(toMainView) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:userIdTF];
    [self.view addSubview:loginButton];
    
    [self NavigationInit];
}

#pragma mark - 私有方法
+ (void)setTextFieldLeftPadding:(UITextField *)textField forWidth:(CGFloat)leftWidth
{
    CGRect frame = textField.frame;
    frame.size.width = leftWidth;
    UIView *leftview = [[UIView alloc] initWithFrame:frame];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.leftView = leftview;
}

- (void)toMainView {
    SMMainViewController *mainViewController = [[SMMainViewController alloc] init];
    [self.navigationController pushViewController:mainViewController animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    [self UILayout];
    self.extendedLayoutIncludesOpaqueBars = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
