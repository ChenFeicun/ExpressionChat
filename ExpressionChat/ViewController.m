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

@interface ViewController ()
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat img_wh = self.view.frame.size.width / 3;
    CGRect frame = CGRectMake((self.view.frame.size.width - img_wh) / 2, (self.view.frame.size.height - img_wh) / 2, img_wh, img_wh);
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:frame];
    imgView.image = [UIImage imageNamed:@"biu_logo.png"];
    [self.view addSubview:imgView];
    [self setNeedsStatusBarAppearanceUpdate];
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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
