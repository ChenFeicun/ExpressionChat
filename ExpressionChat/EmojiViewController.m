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
#import "Friends.h"
#import "Friends+Methods.h"
#import "NotifyMsg.h"
#import "NotifyMsg+Methods.h"
#import "AppDelegate.h"
#import "Animation.h"
#import "MainViewController.h"
#import "BiuMessage.h"
#import "Toast.h"

#import <AVOSCloud/AVOSCloud.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "RecordAudio.h"

@interface EmojiViewController () <RecordAudioDelegate> {
    RecordAudio *recordAudio;
    NSData *curAudio;
    BOOL isRecording;
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
//存每个emoji的数组
@property (nonatomic, strong) Emoji *tempEmoji;
@property (nonatomic, strong) EmojiCellView *emojiCellView;
@end

static double startRecordTime=0;
static double endRecordTime=0;

@implementation EmojiViewController

#define UP YES  //UP代表自己发送  上升
#define DOWN NO //DOWN代表接收  下落
#define DROP_WH (FACE_ICON_SIZE - PADDING_SIZE * 2)

static CGFloat VIEW_WIDTH;
static CGFloat VIEW_HEIGHT;

//- (IBAction)swipeToBack:(id)sender {
//    [self performSegueWithIdentifier:@"BackToMain" sender:self];
//}

#pragma mark - 录音
- (void)RecordStatus:(int)status {
    if (status == 0){
        //播放中
    } else if (status == 1){
        //完成
        NSLog(@"播放完成");
    }else if (status == 2){
        //出错
        NSLog(@"播放出错");
    }
}

- (void)endRecord {
    endRecordTime = [NSDate timeIntervalSinceReferenceDate];
    [_powerTimer invalidate];
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
}

- (void)recordImgViewChangedByPower {
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
    if ([_msgArray count]) {
        [_timer invalidate];
        for (NotifyMsg *msg in _msgArray) {
            //下载文件
            BiuMessage *biuMsg = [[BiuMessage alloc] initWithNotifyMsg:msg];
            if ([msg.type isEqualToString:@"0"]) {
                [self dropEmoji:biuMsg upOrDown:DOWN];
            } else if ([msg.type isEqualToString:@"1"]) {
                if (msg.audioid) {
                    [AVFile getFileWithObjectId:msg.audioid withBlock:^(AVFile *file, NSError *error) {
                        if (file && !error) {
                            AVFile *dataFile = [AVFile fileWithURL:file.url];
                            [dataFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                                //NSLog(@"%@", error.localizedDescription);
                                if (data && !error) {
                                    [recordAudio play:data];
                                    [self dropEmoji:biuMsg upOrDown:DOWN];
                                    [file deleteInBackground];
                                    [file clearCachedFile];
                                }
                            }];
                        }
                    }];
                }
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
        [self dropEmoji:biuMsg upOrDown:DOWN];
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
                            [self dropEmoji:biuMsg upOrDown:DOWN];
                            [file deleteInBackground];
                            [file clearCachedFile];
                        }
                    }];
                }
            }];
        }
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
    if (biuMsg.type == 1) {
        if (isUp == UP) {
            NSString *str = [biuMsg.resName substringFromIndex:biuMsg.resName.length - 2];
            Emoji *emj = [[ResourceManager sharedInstance].emojiArray objectAtIndex:[str integerValue] - 1];
            if (emj.isRecord) {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"OpenOrClose"]) {
                    //[recordAudio playWithNoSound:emj.emojiData];
                } else {
                    [recordAudio play:emj.emojiData];
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
        }
        [_sessionManager sendBiuMessageWithDictionary:dict toPeerId:_chatFriend.id];
    }
}

- (void)didSelectEmoji:(Emoji *)emj passingXRatio:(float)resXRatio andType:(NSInteger)type {
    BiuMessage *biuMsg = [[BiuMessage alloc] initWithAudioID:emj.avosID audioName:emj.avosName audioUrl:emj.avosURL fromName:[AVUser currentUser].username resName:emj.emojiName resXRatio:resXRatio type:type];
    [self sendBiuMessage:biuMsg];
    //[self dropEmoji:biuMsg upOrDown:UP];
}

- (void)preDrop:(Emoji *)emj passingXRatio:(float)resXRatio andType:(NSInteger)type {
    BiuMessage *biuMsg = [[BiuMessage alloc] initWithResName:emj.emojiName resXRatio:resXRatio type:type];
    [self dropEmoji:biuMsg upOrDown:UP];
}

#pragma mark - 表情键盘的点击 长按事件
- (void)clickEmojiCell:(EmojiCellView *)cellView {
    NSInteger type;
    //NSString *str = [NSString stringWithFormat:@"%02li",(long)indexPath.row + 1];
    //NSDictionary *dic;
    float resXRatio = (arc4random() % (int)(VIEW_WIDTH - DROP_WH * 3)) + DROP_WH * 3 / 2;
    resXRatio = resXRatio / VIEW_WIDTH;
    
    //if ([collectionView.restorationIdentifier isEqualToString:@"ImageSegment"]) {
    Emoji *emj = [[ResourceManager sharedInstance].emojiArray objectAtIndex:([cellView.emojiIndex integerValue] - 1)];
    if (emj.isRecord) {
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
    } else {
        type = 0;
        [self preDrop:emj passingXRatio:resXRatio andType:type];
        [self didSelectEmoji:emj passingXRatio:resXRatio andType:type];
    }
}

- (void)recordEmojiCell:(EmojiCellView *)cellView {
    _emojiCellView = cellView;
    _tempEmoji = [[ResourceManager sharedInstance].emojiArray objectAtIndex:[cellView.emojiIndex integerValue] - 1];
    //录音时间2s
    _recordTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(endRecord) userInfo:nil repeats:NO];
    [recordAudio startRecord];
    _recordView.hidden = NO;
    startRecordTime = [NSDate timeIntervalSinceReferenceDate];
    curAudio=nil;
    
    _powerTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(recordImgViewChangedByPower) userInfo:nil repeats:YES];
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
    _recordView.hidden = YES;
    //NSLog(@"%f, %f, %f", _recordView.frame.origin.x, _recordView.frame.origin.y, _recordView.frame.size.width);
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
        //[title appendString:@"!!!"];
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

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //通知session 当前聊天用户为空
    [recordAudio stopPlay];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ClearCurrentFriend" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"EmojiTip"]) {
        //NSLog(@"%f, %f", _emojiBoard.frame.origin.y, (_emojiBoard.frame.origin.y + _emojiBoard.frame.size.height / 2));
        [[Toast makeTip] chatPageTip:(_emojiBoard.frame.origin.y + _emojiBoard.frame.size.height / 2 - 40)];//[[Toast makeTip] pageTip:@"查看离线消息" andCenter:@"向右滑动返回主界面" andBottom:@"长按表情录音"];
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"EmojiTip"];
}

@end
