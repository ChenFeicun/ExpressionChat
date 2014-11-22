//
//  ViewController.m
//  ExpressionChat
//
//  Created by Feicun on 14-10-8.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import "ViewController.h"
#import <AVOSCloud/AVOSCloud.h>
#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController ()
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //786 967
    CGFloat width = self.view.frame.size.width;
    CGFloat height = width / 2 / 786 * 967;
    CGRect frame = CGRectMake(width / 4, (self.view.frame.size.height - height) / 2, width / 2, height);
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:frame];
    imgView.image = [UIImage imageNamed:@"shuxiajian.png"];
    [self.view addSubview:imgView];
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
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(loginOrRegist) userInfo:nil repeats:NO];
}

- (void)loginOrRegist {
    if ([AVUser currentUser]) {
        
        [self setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self performSegueWithIdentifier:@"StartToMain" sender:self];
        //[self toMain];
        
    } else {
        NSLog(@"Please Login");
        [self setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self performSegueWithIdentifier:@"Regist" sender:self];
        //[self toLogin];
    }
}
@end
