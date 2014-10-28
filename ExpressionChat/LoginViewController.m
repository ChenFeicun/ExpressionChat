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
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) AVUser *user;
@end

@implementation LoginViewController

- (IBAction)userLogin:(id)sender {
    self.user = [AVUser user];
    self.user.username = self.loginUserName.text;
    //暂定账号密码相同
    self.user.password = self.loginUserName.text;
    AVQuery *query = [AVUser query];
    [query whereKey:@"username" equalTo:self.loginUserName.text];
    [query getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        if (!error) {
            //NSLog(@"112312321313123123123213");
            [AVUser logInWithUsernameInBackground:self.user.username password:self.user.password block:^(AVUser *user, NSError *error) {
                [self performSegueWithIdentifier:@"RegistToLogin" sender:self];
            }];
        } else {
            //没找到
            [self.user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    //            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    //            [defaults setObject:self.user.username forKey:@"UserName"];
                    //            [defaults setObject:self.user.password forKey:@"Password"];
                    //            [defaults setObject:self.user.objectId forKey:@"UserObjId"];
                    [self performSegueWithIdentifier:@"RegistToLogin" sender:self];
                }else{
                    
                }
            }];
        }
    }];
    
}

//设置委托之后 才会调用这个方法
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.loginButton.enabled = ([newText length] > 0);
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置委托
    self.loginUserName.delegate = self;
    //清除AVUser缓存
    //[AVUser logOut];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.loginUserName becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
