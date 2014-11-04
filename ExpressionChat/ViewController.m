//
//  ViewController.m
//  ExpressionChat
//
//  Created by Feicun on 14-10-8.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import "ViewController.h"
#import <AVOSCloud/AVOSCloud.h>
//#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)start:(id)sender {
    //Document的初始化未完成就跳转了页面  这个方法可能不可行  用LaunchScreen一样
    //故还是要再AppDelegate中判断 初始化成功后跳转
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePage:) name:@"docInitSuccess" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)changePage:(NSNotification *)notification {
   //NSString *str = [notification object];
    if ([AVUser currentUser]) {
    
        [self setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self performSegueWithIdentifier:@"LoginLoading" sender:self];
        //[self toMain];
        
    } else {
        NSLog(@"Please Login");
        [self setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self performSegueWithIdentifier:@"Regist" sender:self];
        //[self toLogin];
    }
}
@end
