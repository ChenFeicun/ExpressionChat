//
//  LoginViewController.m
//  ExpressionChat
//
//  Created by Feicun on 14-10-8.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import "LoginViewController.h"
#import "ViewController.h"
#import "Animation.h"
#import "Toast.h"
#import <AVOSCloud/AVOSCloud.h>

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *loginUserName;
@property (weak, nonatomic) IBOutlet UITextField *loginPassword;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) AVUser *user;
@property (strong, nonatomic) Toast *loadToast;
@end

@implementation LoginViewController

static BOOL editingOrNot = YES;

- (IBAction)userLogin:(id)sender {
    [self enter];
}

- (IBAction)finishInput:(id)sender {
    [_loginPassword becomeFirstResponder];
}

- (void)enter {
    _user = [AVUser user];
    _user.username = [_loginUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //特殊字符判断
    _user.password = [_loginPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (_user.username.length > 16 || _user.username.length <= 2) {
        //提醒
        [Animation shakeView:_loginUserName];
        //[[Toast makeToast:@"请稍候"] loading];
        [[Toast makeToast:@"长度为3-16个字符"] show:NO];
    } else if (_user.password.length > 16 || _user.password.length <= 2) {
        //提醒
        [Animation shakeView:_loginPassword];
        [[Toast makeToast:@"长度为3-16个字符"] show:NO];
    } else {
        _loadToast = [Toast makeToast:@"请稍候"];
        [_loadToast loading];
        [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(avosLogin:) userInfo:nil repeats:NO];
    }
}

- (void)avosLogin:(NSTimer *)timer {
    [AVUser logInWithUsernameInBackground:_user.username password:_user.password block:^(AVUser *user, NSError *error) {
        //NSLog(@"-----%@-----", error.localizedDescription);
        [_loadToast endLoading];
        if (user && !error) {
            //本地时间戳
            [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"LocalTimestamp"];
            [self performSegueWithIdentifier:@"LoginToMain" sender:self];
        } else if ([error.localizedDescription isEqualToString:@"The Internet connection appears to be offline." ] || [error.localizedDescription isEqualToString:@"似乎已断开与互联网的连接。"]) {
            //没有网络连接
            [[Toast makeToast:@"网络连接异常"] show:NO];
        } else if ([error.localizedDescription isEqualToString:@"Could not find user"]) {
            [_user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    //注册成功  本地时间戳
                    [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"LocalTimestamp"];
                    [self performSegueWithIdentifier:@"LoginToMain" sender:self];
                } else {
                    
                }
            }];
        } else if ([error.localizedDescription isEqualToString:@"The request timed out."]) {
            //The request timed out.
            [[Toast makeToast:@"登录请求超时"] show:NO];
        } else if ([error.localizedDescription isEqualToString:@"The username and password mismatch."]) {
            [Animation shakeView:_loginButton];
            [[Toast makeToast:@"用户名与密码不匹配"] show:NO];
        }
    }];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置委托
    _loginUserName.delegate = self;
    _loginPassword.delegate = self;
    //键盘将出现事件监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //键盘将隐藏事件监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)handleKeyboardWillShow:(NSNotification *)notification {
    if (editingOrNot) {
        [Animation moveViewForEditing:self.view orNot:editingOrNot];
        editingOrNot = !editingOrNot;
    }
    
}

- (void)handleKeyboardWillHide:(NSNotification *)notification {
    if (!editingOrNot) {
        [Animation moveViewForEditing:self.view orNot:editingOrNot];
        editingOrNot = !editingOrNot;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[_loginUserName becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    //https://github.com/hhuai/ios-amr
}
@end
