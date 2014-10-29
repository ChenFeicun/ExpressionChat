//
//  LoginViewController.m
//  ExpressionChat
//
//  Created by Feicun on 14-10-8.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import "LoginViewController.h"
#include "ViewController.h"
#import <AVOSCloud/AVOSCloud.h>

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *loginUserName;
@property (weak, nonatomic) IBOutlet UITextField *loginPassword;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) AVUser *user;
@end

@implementation LoginViewController

- (IBAction)userLogin:(id)sender {
    _user = [AVUser user];
    _user.username = [_loginUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //暂定账号密码相同
    _user.password = [_loginPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (_user.username.length > 12) {
        ;
    } else {
        [AVUser logInWithUsernameInBackground:_user.username password:_user.password block:^(AVUser *user, NSError *error) {
            NSLog(@"%@", error.localizedDescription);
            if (user) {
                [self performSegueWithIdentifier:@"RegistToLogin" sender:self];
            } else if ([error.localizedDescription isEqualToString:@"Could not find user"]) {
                [_user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        //注册成功
                        [self performSegueWithIdentifier:@"RegistToLogin" sender:self];
                    }else{
                        
                    }
                }];
            } else {
                //用户名密码不匹配
            }
        }];
    }
}

//设置委托之后 才会调用这个方法
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    _loginButton.enabled = ([newText length] > 0);
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置委托
    _loginUserName.delegate = self;
    //清除AVUser缓存
    //[AVUser logOut];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_loginUserName becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
