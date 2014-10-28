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
//@property (strong, nonatomic) AVAudioPlayer *player;
//@property (nonatomic)SystemSoundID soundID;
@end

@implementation ViewController

static SystemSoundID soundID = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *strSoundFile = [[NSBundle mainBundle] pathForResource:@"audio_01" ofType:@"wav"];
    if (strSoundFile) {
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
        AudioServicesAddSystemSoundCompletion(soundID, nil, nil, SoundFinished, nil);
        NSLog(@"find file");
    }
   
    //AudioServicesPlaySystemSound(soundID);
    
//    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"audio_01" ofType:@"wav"];
//    NSURL *fileUrl  = [NSURL fileURLWithPath:filePath];
//    //NSURL *url = [[NSURL alloc] initWithString:@"audio_01.wav"];
//    SystemSoundID soundId;
//    OSStatus err = AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileUrl, &soundId);
//    if (err) {
//        NSLog(@"Error occurred assigning system sound!");
//        //return -1;
//    }
//    NSLog(@"%u",(unsigned int)soundId);

}

static void SoundFinished(SystemSoundID sysID, void *sample) {
    NSLog(@"play sound finished");
}

- (IBAction)start:(id)sender {
    //NSLog(@"%u", (unsigned int)soundID);
    //AudioServicesPlaySystemSound(soundID);
    
//    CFBundleRef mainbundle=CFBundleGetMainBundle();
//    SystemSoundID soundFileObject;
//    //获得声音文件URL
//    CFURLRef soundfileurl=CFBundleCopyResourceURL(mainbundle,CFSTR("audio_01"),CFSTR("wav"),NULL);
//    //创建system sound 对象
//    AudioServicesCreateSystemSoundID(soundfileurl, &soundFileObject);
//    //播放
//    AudioServicesPlaySystemSound(soundFileObject);
    
//    NSString *fileName = [[NSBundle mainBundle] pathForResource:@"audio_01"
//                                                         ofType:@"mp3"];
//    NSURL *fileUrl = [NSURL fileURLWithPath:fileName];
//    NSError *error = nil;
//    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:&error];
//    if (error) {
//        NSLog(@"!!!!%@", error);
//    }
//    
//    [_player prepareToPlay];
//    [_player play];
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
        [self performSegueWithIdentifier:@"MainPage" sender:self];
        //[self toMain];
        
    } else {
        NSLog(@"Please Login");
        [self performSegueWithIdentifier:@"Regist" sender:self];
        //[self toLogin];
    }
}
/*
 #define CORNER_FONT_HEOGHT 180.0
 #define CORNER_RADIUS 12.0
 
 - (CGFloat)cornerScaleFactor:(UIButton *)button {
 return button.bounds.size.height /CORNER_FONT_HEOGHT;
 }
 
 - (CGFloat)cornerRadius:(UIButton *)button {
 return CORNER_RADIUS * [self cornerScaleFactor:button];
 }
 
 - (CGFloat)cornerOffset:(UIButton *)button {
 return [self cornerRadius:button] / 3.0;
 }
 
 - (void)changeToCornerRadius:(UIButton *)button {
 UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:button.bounds cornerRadius:[self cornerRadius:button]];
 [roundedRect addClip];
 UIRectFill(self.curButton.bounds);
 }
 */
@end
