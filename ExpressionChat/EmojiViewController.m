//
//  EmojiViewController.m
//  ExpressionChat
//
//  Created by Feicun on 14-10-15.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import "EmojiViewController.h"
#import "BiuSessionManager.h"
#import "ResourceManager.h"
#import "Friends+Methods.h"
#import "NotifyMsg+Methods.h"
#import "AppDelegate.h"
#import "Animation.h"
#import "MainViewController.h"
#import "BiuMessage.h"
#import "Toast.h"
#import "GuideView.h"
#import "RecordAudio.h"
#import "DACircularProgressView.h"
#import "TTSManager.h"
#import <AVOSCloud/AVOSCloud.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>



@interface EmojiViewController () <RecordAudioDelegate, UIAlertViewDelegate> {
    RecordAudio *recordAudio;
    NSData *curAudio;
    BOOL isRecording;
    AVAudioPlayer *avPlayer;
}

@property (weak, nonatomic) IBOutlet UIButton *friendButton;
@property (strong, nonatomic) UIView *recordView;
@property (strong, nonatomic) UIImageView *recordImgView;
@property (strong, nonatomic) EmojiBoardView *emojiBoard;
//数据库
@property (strong, nonatomic) NSMutableArray *msgArray;

@property (strong, nonatomic) BiuSessionManager *sessionManager;
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *context;
//从plist文件中读取
@property (strong, nonatomic) NSDictionary *emojiDictionary;
//定时器
@property (strong, nonatomic) NSTimer *timer;
//录音
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) NSTimer *recordTimer;
@property (nonatomic, strong) NSTimer *powerTimer;
@property (strong, nonatomic) DACircularProgressView *progressView;
//存每个emoji的数组
@property (nonatomic, strong) Emoji *tempEmoji;
@property (nonatomic, strong) EmojiCellView *emojiCellView;
//引导
@property (nonatomic, strong) GuideView *guideView;
@property (nonatomic) BOOL firstGuide;
@property (nonatomic) BOOL secondGuide;
@property (nonatomic) BOOL thirdGuide;

//长按出现的View
@property (strong, nonatomic) NSMutableArray *ttsArray;
@property (strong, nonatomic) TTSManager *mySynthesizer;
@property (strong, nonatomic) TTSManager *yourSynthesizer;
@property (strong, nonatomic) Toast *loadToast;
@property (strong, nonatomic) OptionalView *optionalView;

@property (nonatomic, strong) NSTimer *ttsTimer;
@end

static double startRecordTime=0;
static double endRecordTime=0;

@implementation EmojiViewController

#define UP YES  //UP代表自己发送  上升
#define DOWN NO //DOWN代表接收  下落
#define DROP_WH (FACE_ICON_SIZE - PADDING_SIZE * 2)

static CGFloat VIEW_WIDTH;
static CGFloat VIEW_HEIGHT;

#pragma mark - 录音
- (void)recordStatus:(int)status {
    if (status == 0){
        //播放中
    } else if (status == 1){
        //完成
        NSLog(@"播放完成");
        self.optionalView.menuActive = YES;
    }else if (status == 2){
        //出错
        NSLog(@"播放出错");
    }
}

- (void)endRecord {
    endRecordTime = [NSDate timeIntervalSinceReferenceDate];
    [_powerTimer invalidate];
    _powerTimer = nil;
    NSURL *url = [recordAudio stopRecord];
    if (url != nil) {
        curAudio = EncodeWAVEToAMR([NSData dataWithContentsOfURL:url], 1, 16);
        if (curAudio) {
            [_emojiCellView showPointView];
            _tempEmoji.isRecord = YES;
            _tempEmoji.emojiData = curAudio;
            _tempEmoji.soundURL = [[ResourceManager sharedInstance] dataWriteToFile:_tempEmoji.emojiName withData:_tempEmoji.emojiData];
            [[ResourceManager sharedInstance] removeSoundFileByUrl:url];
        }
    }
    _recordView.hidden = YES;
    _progressView.progress = 0;
    _optionalView.menuActive = YES;
}

- (void)recordImgViewChangedByPower {
    //进度条变更
    CGFloat progress = _progressView.progress + 0.01f;
    [_progressView setProgress:progress animated:YES];
    
    if (_progressView.progress >= 1.0f && [_powerTimer isValid]) {
        [_powerTimer invalidate];
        _powerTimer = nil;
    }
    
    int powerImg = (int)([recordAudio getPeakPower] * 15);
    if (powerImg == 0) {
        powerImg = 1;
    } else if (powerImg > 15) {
        powerImg = 15;
    }
    //NSLog(@"%i", powerImg);
    _recordImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"record_animate_%02i.png", powerImg]];
}

- (void)shakeTillClick {
    [Animation shakeView:_friendButton];
}

#pragma mark - 消息处理
- (IBAction)dropOfflineMsg:(id)sender {
    //将Friend表的unread置0
    [Friends updateUnreadByName:_chatFriend.username inManagedObjectContext:_context];
    if ([_chatFriend.username isEqualToString:@"Biu"] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"EmojiTip"]) {
        [_timer invalidate];
        _timer = nil;
        //掉下一个特定的消息
        [self dropUpOrDown:DOWN withResXRatio:0.5f andResName:@"emoji_01.png"];
        NSURL* guideUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"step0" ofType:@"mp3"]];
        avPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:guideUrl error:nil];
        [avPlayer prepareToPlay];
        [avPlayer play];
        [_guideView guideViewForView:self.view withFrame:CGRectMake(0, _emojiBoard.frame.origin.y, FACE_ICON_SIZE, FACE_ICON_SIZE)  andStepIndex:1];
        _firstGuide = true;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"EmojiTip"];
    }
    if ([_msgArray count]) {
        [_timer invalidate];
        _timer = nil;
        for (NotifyMsg *msg in _msgArray) {
            //下载文件
            BiuMessage *biuMsg = [[BiuMessage alloc] initWithNotifyMsg:msg];
            if ([msg.type isEqualToString:@"0"]) {
                [self dropUpOrDown:DOWN withResXRatio:biuMsg.resXRatio andResName:biuMsg.resName];
                //[self dropEmoji:biuMsg upOrDown:DOWN];
            } else if ([msg.type isEqualToString:@"1"]) {
                if (msg.audioid) {
                    [AVFile getFileWithObjectId:msg.audioid withBlock:^(AVFile *file, NSError *error) {
                        if (file && !error) {
                            AVFile *dataFile = [AVFile fileWithURL:file.url];
                            [dataFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                                //NSLog(@"%@", error.localizedDescription);
                                if (data && !error) {
                                    [recordAudio play:data];
                                    [self dropUpOrDown:DOWN withResXRatio:biuMsg.resXRatio andResName:biuMsg.resName];
                                    //[self dropEmoji:biuMsg upOrDown:DOWN];
                                    [file deleteInBackground];
                                    [file clearCachedFile];
                                }
                            }];
                        }
                    }];
                }
            } else if ([msg.type isEqualToString:@"2"]) {
                NSString *ttsString = biuMsg.ttsString;
                [_ttsArray addObject:biuMsg];
                [_yourSynthesizer synthesize:ttsString];
            }
        }
        [_friendButton setTitle:_chatFriend.username forState:UIControlStateNormal];
        [NotifyMsg deleteFriendMsg:_chatFriend inManagedObjectContext:_context];
    }
}


- (void)recieveMsg:(NSNotification *)notification {
    AVMessage *msg = [notification object];
    //NSLog(@"recieve msg : %@", msg.payload);
    NSError *error = nil;
    NSData *data = [msg.payload dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
    NSString *type = [numFormatter stringFromNumber:[dict objectForKey:@"type"]];

    BiuMessage *biuMsg = [[BiuMessage alloc] initWithDictionary:dict];
    if ([type isEqualToString:@"0"]) {
        [self dropUpOrDown:DOWN withResXRatio:biuMsg.resXRatio andResName:biuMsg.resName];
        //[self dropEmoji:biuMsg upOrDown:DOWN];
    } else if ([type isEqualToString:@"1"]) {
        //NSString *fileUrl = [dict objectForKey:@"audioUrl"];
        NSString *fileId = [dict objectForKey:@"audioID"];
        if (fileId) {
            [AVFile getFileWithObjectId:fileId withBlock:^(AVFile *file, NSError *error) {
                if (file && !error) {
                    AVFile *dataFile = [AVFile fileWithURL:file.url];
                    [dataFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        if (data && !error) {
                            [recordAudio play:data];
                            [self dropUpOrDown:DOWN withResXRatio:biuMsg.resXRatio andResName:biuMsg.resName];
                            //[self dropEmoji:biuMsg upOrDown:DOWN];
                            [file deleteInBackground];
                            [file clearCachedFile];
                        }
                    }];
                }
            }];
        }
    } else if ([type isEqualToString:@"2"]) {
        //NSString *fileUrl = [dict objectForKey:@"audioUrl"];
        NSString *ttsString = biuMsg.ttsString;
        [_ttsArray addObject:biuMsg];
        [_yourSynthesizer synthesize:ttsString];
    }

}

- (void)dropUpOrDown:(BOOL)isUp withResXRatio:(float)x andResName:(NSString *)resName {
    NSInteger height = _emojiBoard.frame.origin.y - _friendButton.bounds.size.height;

    CGRect frame = CGRectMake(0, 0, DROP_WH, DROP_WH);
    
    CGFloat quarter; //1/4处
    CGFloat half; //一半
    if (isUp == UP) {
        x = x * VIEW_WIDTH;
        frame.origin = CGPointMake(x, height + _friendButton.bounds.size.height - DROP_WH);
        quarter = height * 3 / 4 + _friendButton.bounds.size.height + DROP_WH / 2;
        half = height / 2 + _friendButton.bounds.size.height + DROP_WH / 2;
    } else {
        x = VIEW_WIDTH - x * VIEW_WIDTH;
        frame.origin = CGPointMake(x, _friendButton.frame.origin.y + _friendButton.frame.size.height);
        quarter = height / 4 + _friendButton.bounds.size.height - DROP_WH / 2;
        half = height / 2 + _friendButton.bounds.size.height - DROP_WH / 2;
    }
    
    UIImageView *dropView = [[UIImageView alloc] initWithFrame:frame];
    dropView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", resName]];
    [self.view addSubview:dropView];
    dropView.alpha = 0;
    //表情动画
    [UIView animateWithDuration:1.0f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        dropView.center = CGPointMake(dropView.center.x, quarter);
        dropView.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            dropView.center = CGPointMake(dropView.center.x, half);
            dropView.alpha = 0;
        } completion:^(BOOL finished) {
            [dropView removeFromSuperview];
        }];
    }];

}

- (void)dropEmoji:(BiuMessage *)biuMsg upOrDown:(BOOL)isUp{
    [self dropUpOrDown:isUp withResXRatio:biuMsg.resXRatio andResName:biuMsg.resName];
    if (biuMsg.type == 1 || biuMsg.type == 2) {
        if (isUp == UP) {
            NSString *str = [biuMsg.resName substringFromIndex:biuMsg.resName.length - 2];
            Emoji *emj = [[ResourceManager sharedInstance].emojiArray objectAtIndex:[str integerValue] - 1];
            if (emj.isRecord) {
                if (![[NSUserDefaults standardUserDefaults] boolForKey:@"OpenOrClose"]) {
                    if (biuMsg.type == 1) {
                        [recordAudio play:emj.emojiData];
                    } else {
                        [recordAudio playMp3:emj.emojiData];
                    }
                }
            }
        }
    }
}

- (void)sendBiuMessage:(BiuMessage *)biuMsg {
    
    if ([_chatFriend.username isEqualToString:@"Biu"]) {
        //引导
        [self dropUpOrDown:DOWN withResXRatio:biuMsg.resXRatio andResName:[NSString stringWithFormat:@"emoji_%02d", arc4random() % 74 + 1]];
        
    } else {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        //[dict setObject:[AVUser currentUser].objectId forKey:@"fromid"];
        [dict setObject:[AVUser currentUser].username forKey:@"fromName"];
        [dict setObject:[NSString stringWithFormat:@"%f", biuMsg.resXRatio] forKey:@"resXRatio"];
        [dict setObject:[NSNumber numberWithInteger:biuMsg.type] forKey:@"type"];
        [dict setObject:biuMsg.resName forKey:@"resName"];
        if (biuMsg.type == 1) {
            [dict setObject:biuMsg.audioID forKey:@"audioID"];
            [dict setObject:biuMsg.audioName forKey:@"audioName"];
            [dict setObject:biuMsg.audioUrl forKey:@"audioUrl"];
        } else if (biuMsg.type == 2){
            [dict setObject:biuMsg.ttsString forKey:@"ttsString"];
        }
        [_sessionManager sendBiuMessageWithDictionary:dict toPeerId:_chatFriend.id];
    }
}

- (void)didSelectEmoji:(Emoji *)emj passingXRatio:(float)resXRatio andType:(NSInteger)type {
    BiuMessage *biuMsg = [[BiuMessage alloc] initWithAudioID:emj.avosID audioName:emj.avosName audioUrl:emj.avosURL fromName:[AVUser currentUser].username resName:emj.emojiName resXRatio:resXRatio type:type ttsString:emj.ttsString];
    [self sendBiuMessage:biuMsg];
    //[self dropEmoji:biuMsg upOrDown:UP];
}

- (void)preDrop:(Emoji *)emj passingXRatio:(float)resXRatio andType:(NSInteger)type {
    BiuMessage *biuMsg = [[BiuMessage alloc] initWithResName:emj.emojiName resXRatio:resXRatio type:type];
    [self dropEmoji:biuMsg upOrDown:UP];
}

#pragma mark - 表情键盘的点击
- (void)firstStepFinshed:(NSTimer *)timer {
    [timer invalidate];
    [_guideView guideViewForView:self.view withFrame:CGRectMake(FACE_ICON_SIZE * 3, _emojiBoard.frame.origin.y, FACE_ICON_SIZE, FACE_ICON_SIZE) andStepIndex:2];
    _secondGuide = true;

    Emoji *emj = [[ResourceManager sharedInstance].emojiArray objectAtIndex:5];
    [self didSelectEmoji:emj passingXRatio:0.5 andType:0];
    NSURL* guideUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"step1" ofType:@"mp3"]];
    avPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:guideUrl error:nil];
    [avPlayer prepareToPlay];
    [avPlayer play];
}

- (void)clickEmojiCell:(EmojiCellView *)cellView {
    NSInteger type;
    //NSString *str = [NSString stringWithFormat:@"%02li",(long)indexPath.row + 1];
    //NSDictionary *dic;
    float resXRatio = (arc4random() % (int)(VIEW_WIDTH - DROP_WH * 3)) + DROP_WH * 3 / 2;
    resXRatio = resXRatio / VIEW_WIDTH;
    
    //引导用户点击表情
    if (_firstGuide) {
        _firstGuide = false;
        [avPlayer stop];
        [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(firstStepFinshed:) userInfo:nil repeats:NO];
    } else {
        Emoji *emj = [[ResourceManager sharedInstance].emojiArray objectAtIndex:([cellView.emojiIndex integerValue] - 1)];
        if (emj.isRecord) {
            NSArray *array = [[emj.soundURL path] componentsSeparatedByString:@"."];
            if ([[array lastObject]  isEqual: @"mp3"]) {
                type = 2;
                [self preDrop:emj passingXRatio:resXRatio andType:type];
                [self didSelectEmoji:emj passingXRatio:resXRatio andType:type];
            }else if ([[array lastObject]  isEqual: @"amr"]){
                type = 1;
                [self preDrop:emj passingXRatio:resXRatio andType:type];
                AVFile *file = [AVFile fileWithName:emj.avosName data:emj.emojiData];
                [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    //NSLog(@"%@", error.localizedDescription);
                    if (succeeded && !error) {
                        emj.avosURL = file.url;
                        emj.avosID = file.objectId;
                        //使本地可实时显示表情声音 不必等待上传结束
                        [self didSelectEmoji:emj passingXRatio:resXRatio andType:type];
                        [file clearCachedFile];
                    } else if ([error.localizedDescription isEqualToString:@"The Internet connection appears to be offline."]) {
                        [[Toast makeToast:@"网络连接异常"] show:NO];
                    }
                }];
            }
        } else {
            type = 0;
            [self preDrop:emj passingXRatio:resXRatio andType:type];
            [self didSelectEmoji:emj passingXRatio:resXRatio andType:type];
        }
    }
}

#pragma mark -长按菜单
- (void)longPressEmojiCell:(EmojiCellView *)cellView {
    if (_secondGuide) {
        _secondGuide = false;
        _thirdGuide = true;
        [_guideView changeNoticeText:@"录音 TTS 试听 删除"];
    }
    _emojiCellView = cellView;
    [self.view addSubview:self.optionalView];
    CGFloat emojiY = VIEW_HEIGHT - VIEW_WIDTH / 7 * 3 - 20 + cellView.frame.origin.y;
    CGRect emojiFrame = CGRectMake(cellView.frame.origin.x, emojiY, cellView.frame.size.width, cellView.frame.size.height);
    [_optionalView showOptionView:cellView.emojiIndex frame:emojiFrame isHidden:[cellView isPointViewHide]];
}

- (void)tapShadowArea {
    if (_thirdGuide) {
        _thirdGuide = false;
        [_guideView removeAll];
        [avPlayer stop];
        [self dropUpOrDown:DOWN withResXRatio:0.5f andResName:@"emoji_12.png"];
        NSURL* guideUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"step2" ofType:@"mp3"]];
        avPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:guideUrl error:nil];
        [avPlayer prepareToPlay];
        [avPlayer play];
    }
}

- (void)tapTTSButton {
    _tempEmoji = [[ResourceManager sharedInstance].emojiArray objectAtIndex:[_emojiCellView.emojiIndex integerValue] - 1];
    [self.optionalView showttsEditView:_tempEmoji.ttsString];
    //self.optionalView
}

- (void)tapRcdButton {
    //判读是否允许访问麦克风
    AVAudioSession *avSession = [AVAudioSession sharedInstance];
    if ([avSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [avSession requestRecordPermission:^(BOOL available) {
            if (available) {
                //completionHandler
                dispatch_async(dispatch_get_main_queue(), ^{
                    _tempEmoji = [[ResourceManager sharedInstance].emojiArray objectAtIndex:[_emojiCellView.emojiIndex integerValue] - 1];
                    //录音时间2s
                    _recordTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(endRecord) userInfo:nil repeats:NO];
                    [recordAudio startRecord];
                    _recordView.hidden = NO;
                    startRecordTime = [NSDate timeIntervalSinceReferenceDate];
                    curAudio=nil;
                    _powerTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(recordImgViewChangedByPower) userInfo:nil repeats:YES];
                    [self.optionalView showPointView];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法录音" message:@"请在iPhone的“设置-隐私-麦克风”选项中，允许Biu访问您的麦克风。" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
                    [alert show];
                });
            }
        }];
        
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"DismissBtn");
    if (buttonIndex == 0) {
        [_optionalView disAppearOptionalView];
    }
}

- (void)tapCheckButton {
    Emoji *emj = [[ResourceManager sharedInstance].emojiArray objectAtIndex:[_emojiCellView.emojiIndex integerValue] - 1];
    if (emj.isRecord) {
        NSArray *array = [[emj.soundURL path] componentsSeparatedByString:@"."];
        if ([[array lastObject]  isEqual: @"mp3"]) {
            [recordAudio playMp3:emj.emojiData];
        }else if ([[array lastObject]  isEqual: @"amr"]){
            [recordAudio play:emj.emojiData];
        }
    }else{
        self.optionalView.menuActive = YES;
    }
}
- (void)tapClearButton {
    _tempEmoji = [[ResourceManager sharedInstance].emojiArray objectAtIndex:[_emojiCellView.emojiIndex integerValue] - 1];
    _tempEmoji.ttsString = @"";
    [[ResourceManager sharedInstance] removeSoundFileByIndex:[_emojiCellView.emojiIndex integerValue] - 1];
    [_emojiCellView hidePointView];
    [self.optionalView hiddenPointView];
    self.optionalView.menuActive = YES;
}

#pragma mark - 语音合成

-(void)confrimTTS:(NSString *)ttsString {
    if (ttsString.length > 12) {
        _loadToast = [Toast makeToast:@"长度请保持在12以内"];
        [_loadToast show:NO];
    } else if (ttsString.length == 0){
        _loadToast = [Toast makeToast:@"请输入文字"];
        [_loadToast show:NO];
        [Animation shakeView:[_optionalView.ttsEditView viewWithTag:97]];
    } else {
        [_mySynthesizer synthesize:ttsString];
        _tempEmoji.ttsString = ttsString;
        [[ResourceManager sharedInstance] saveEmojiTTSString:_tempEmoji];
        //提示信息：等待回复；
        _loadToast = [Toast makeToast:@"请稍候"];
        [_loadToast loading];
        _loadToast.toastView.backgroundColor = [UIColor clearColor];
        _ttsTimer = [NSTimer scheduledTimerWithTimeInterval:6.0f target:self selector:@selector(lostTTS) userInfo:nil repeats:NO];
    }
}

- (void)lostTTS {
    [_loadToast endLoading];
    _loadToast = [Toast makeToast:@"网络连接超时"];
    [_loadToast show:NO];
    self.optionalView.menuActive = YES;
}

- (void)closeTTS {
    self.optionalView.menuActive = YES;
}

-(void)synthesizerNewDataArrived:(BDSSpeechSynthesizer *)speechSynthesizer data:(NSData *)newData isLastData:(BOOL)lastDataFlag {
    curAudio = newData;
    NSString *IDF = [(NSObject*)speechSynthesizer valueForKey:@"params"];
    if ([IDF isEqual: @"me"]){
        if ([_ttsTimer isValid]) {
            [_ttsTimer invalidate];
            _ttsTimer = nil;
            if (curAudio) {
                [_emojiCellView showPointView];
                _tempEmoji = [[ResourceManager sharedInstance].emojiArray objectAtIndex:[_emojiCellView.emojiIndex integerValue] - 1];
                _tempEmoji.isRecord = YES;
                _tempEmoji.emojiData = curAudio;
                _tempEmoji.soundURL = [[ResourceManager sharedInstance] dataWriteToFileMp3:_tempEmoji.emojiName withData:_tempEmoji.emojiData];
                
                //提示信息：得到回复；
                [_loadToast endLoading];
                [self.optionalView ttsrcdEnd:_tempEmoji.isRecord];
                [self.optionalView hiddenttsEditView];
                [self.optionalView showPointView];
            }
        }
        self.optionalView.menuActive = YES;
    }else if ([IDF isEqual: @"you"]){
        NSObject *newDis = [(NSObject*)speechSynthesizer valueForKey:@"requestDispatcher"];
        NSString *emojiString = [(NSObject*)newDis valueForKey:@"textToSynthesize"];
        [self removeFormTTSArray:emojiString ttsData:newData];
        //NSLog(@"%@",emojiString);
    }
    //NSLog(@"合成完成");
}

//不会进入这个方法
//- (void)synthesizerErrorOccurred:(BDSSpeechSynthesizer *)speechSynthesizer error:(NSError *)error {
//    NSLog(@"%@", error.localizedDescription);
//    NSLog(@"%@", error);
//}

- (void)removeFormTTSArray:(NSString *)ttsString ttsData:(NSData *)ttsData {
    for (NSInteger i = [_ttsArray count]-1; i>=0; i--) {
        BiuMessage *msg = _ttsArray[i];
        if (msg.ttsString == ttsString) {
            [recordAudio playMp3:ttsData];
            [self dropUpOrDown:DOWN withResXRatio:msg.resXRatio andResName:msg.resName];
            [_ttsArray removeObjectAtIndex:i];
        }
    }
}

#pragma mark - 初始化
- (void)initRecordView {
    const CGFloat BG_WH = 120;
    const CGFloat IMG_WIDTH = 75 * 3 / 4;
    const CGFloat IMG_HEIGHT = 111 * 3 / 4;
    CGRect frame = CGRectMake((VIEW_WIDTH - BG_WH) / 2, (VIEW_HEIGHT - BG_WH) / 2, BG_WH, BG_WH);
    _recordView = [[UIView alloc] initWithFrame:frame];
    UIImageView *bgImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BG_WH, BG_WH)];
    bgImg.image = [UIImage imageNamed:@"record_bg.png"];
    [_recordView addSubview:bgImg];
    //frame是针对父view的
    CGRect imgFrame = CGRectMake((BG_WH - IMG_WIDTH) / 2, (BG_WH - IMG_HEIGHT) / 2, IMG_WIDTH, IMG_HEIGHT);
    _recordImgView= [[UIImageView alloc] initWithFrame:imgFrame];
    _recordImgView.image = [UIImage imageNamed:@"record_animate_01.png"];
    [_recordView addSubview:_recordImgView];
    
    //进度条
    _progressView = [[DACircularProgressView alloc] initWithFrame:CGRectMake(0, 0, BG_WH, BG_WH)];
    _progressView.roundedCorners = YES;
    _progressView.thicknessRatio = 0.1f;
    _progressView.progressTintColor = [[UIColor alloc] initWithRed:0.0283401 green:0.781377 blue:0.854251 alpha:1];
    _progressView.trackTintColor = [UIColor clearColor];
    [_recordView addSubview:_progressView];

    _recordView.hidden = YES;
    [self.view addSubview:_recordView];
    
}

- (void)initResource {
    //将用户添加到 session的watchId中
    _appDelegate = [[UIApplication sharedApplication] delegate];
    _sessionManager = [BiuSessionManager sharedInstance];
    [_sessionManager addWatchPeerId:_chatFriend.id andSetCurFriend:_chatFriend];
    
    //获取数据库的信息
    _context = _appDelegate.document.managedObjectContext;
    
    NSArray *array = [NotifyMsg recentlyOfflineMsg:_chatFriend inManagedObjectContext:_context];
    
    NSMutableString *title = [NSMutableString stringWithString:_chatFriend.username];
    if ([array count]) {
        _msgArray = [[NSMutableArray alloc] initWithArray:array];
        //定时
        _timer = [NSTimer timerWithTimeInterval:2.0f target:self selector:@selector(shakeTillClick) userInfo:nil repeats:YES];
    } else {
        _msgArray = [[NSMutableArray alloc] init];
    }
    
    [_friendButton setTitle:title forState:UIControlStateNormal];

    _emojiDictionary = [[ResourceManager sharedInstance] readEmojiInfo];
    //录音
    recordAudio = [[RecordAudio alloc]init];
    recordAudio.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    VIEW_WIDTH = self.view.frame.size.width;
    VIEW_HEIGHT = self.view.frame.size.height;
    [self initResource];
    [self initRecordView];
    
    _emojiBoard = [[EmojiBoardView alloc] initWithFrame:CGRectMake(0, VIEW_HEIGHT - VIEW_WIDTH / 7 * 3 - 20, VIEW_WIDTH, VIEW_WIDTH / 7 * 3 + 20)];
    _emojiBoard.delegate = self;
    [self.view addSubview:_emojiBoard];
    
    [self initOplView];
    //TTS
    [self initTTSSynthesizer];
}

- (void)initOplView {
    _optionalView = [[OptionalView alloc] initWithOriginalFrame:CGRectMake(0, 0, FACE_ICON_SIZE, FACE_ICON_SIZE)];
    _optionalView.delegate = self;
    [_optionalView addSubview:_recordView];
}

- (void)initTTSSynthesizer {
    _ttsArray = [[NSMutableArray alloc] init];
    _mySynthesizer = [TTSManager newInstance];
    _yourSynthesizer = [TTSManager newInstance];
    
    _mySynthesizer.synthesizer = [[BDSSpeechSynthesizer alloc] initSynthesizer:@"me" delegate:self];
    [_mySynthesizer setParams];
    
    _yourSynthesizer.synthesizer = [[BDSSpeechSynthesizer alloc] initSynthesizer:@"you" delegate:self];
    [_yourSynthesizer setParams];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveMsg:) name:@"readMsg" object:nil];
    if (_timer) {
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    }
//#warning 引导
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [recordAudio stopPlay];
    if (avPlayer) {
        [avPlayer stop];
    }
    //Biu的未读设置为NO 并且更新时间戳
    if ([_chatFriend.username isEqualToString:@"Biu"]) {
        [Friends updateFriend:_chatFriend time:0 unread:NO inManagedObjectContext:_context];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //通知session 当前聊天用户为空
  
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ClearCurrentFriend" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"EmojiTip"]) {
        if ([_chatFriend.username isEqualToString:@"Biu"]) {
            self.guideView = [GuideView initWithArray];
            [self.guideView guideViewForView:self.view withFrame:CGRectMake(0, 0, VIEW_WIDTH, _friendButton.frame.origin.y) andStepIndex:0];
            //[self.guideView noticeTextForView:self.view withText:@"向右滑动跳过引导"];
            
            _timer = [NSTimer timerWithTimeInterval:2.0f target:self selector:@selector(shakeTillClick) userInfo:nil repeats:YES];
        }
    }
}

@end
