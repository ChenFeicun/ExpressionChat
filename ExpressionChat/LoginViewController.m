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
@end
//
static BOOL editingOrNot = NO;

@implementation LoginViewController

- (IBAction)userLogin:(id)sender {
    [self enter];
}
//
- (IBAction)finishInput:(id)sender {
    [self enter];
}

- (void)enter {
    _user = [AVUser user];
    _user.username = [_loginUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //特殊字符判断
    _user.password = [_loginPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (_user.username.length > 12 || _user.username.length <= 0) {
        //提醒
        [Animation shakeView:_loginUserName];
        [[Toast makeToast:@"用户名太长!!!!"] show];
    } else if (_user.password.length > 12 || _user.password.length <= 0) {
        //提醒
        [Animation shakeView:_loginPassword];
    } else {
        [AVUser logInWithUsernameInBackground:_user.username password:_user.password block:^(AVUser *user, NSError *error) {
            NSLog(@"-----%@-----", error.localizedDescription);
            if (user) {
                [self performSegueWithIdentifier:@"RegistLoading" sender:self];
            } else if ([error.localizedDescription isEqualToString:@"The Internet connection appears to be offline."]) {
                //没有网络连接
                [[Toast makeToast:@"网络连接异常"] show];
            } else if ([error.localizedDescription isEqualToString:@"Could not find user"]) {
                [_user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        //注册成功
                        [self performSegueWithIdentifier:@"RegistLoading" sender:self];
                    }else{
                        
                    }
                }];
            } else {
                //用户名密码不匹配
                [Animation shakeView:_loginButton];
                [[Toast makeToast:@"用户名与密码不匹配"] show];
            }
        }];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    editingOrNot = YES;
    [Animation moveViewForEditing:self.view orNot:editingOrNot];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    editingOrNot = NO;
    [Animation moveViewForEditing:self.view orNot:editingOrNot];
}

//设置委托之后 才会调用这个方法
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    if ([textField isEqual:_loginUserName]) {
//        NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
//        _loginButton.enabled = ([newText length] > 0);
//        [Animation setBackgroundColorWithDark:_loginButton];
//    }
//    return YES;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置委托
    _loginUserName.delegate = self;
    _loginPassword.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[_loginUserName becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//https://github.com/hhuai/ios-amr
@end
