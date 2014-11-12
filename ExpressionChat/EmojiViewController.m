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
#import "NotifyMsg.h"
#import "NotifyMsg+Methods.h"
#import "AppDelegate.h"
#import "Animation.h"
#import "MainViewController.h"
#import "SoundManager.h"

#import "MLAmrPlayer.h"
#import "MLAudioMeterObserver.h"
#import "AmrPlayerReader.h"
#import "AmrRecordWriter.h"

#import <AVOSCloud/AVOSCloud.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface EmojiViewController ()
@property (strong, nonatomic) NSMutableArray *msgArray;
@property (weak, nonatomic) IBOutlet UICollectionView *emojiKeyboard;
@property (weak, nonatomic) IBOutlet UICollectionView *voiceKeyboard;
@property (weak, nonatomic) IBOutlet UIButton *friendButton;
@property (strong, nonatomic) BiuSessionManager *sessionManager;
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *context;
//从plist文件中读取
@property (strong, nonatomic) NSDictionary *emojiDictionary;
@property (strong, nonatomic) NSDictionary *voiceDictionary;
//定时器
@property (strong, nonatomic) NSTimer *timer;
//segment YES--emoji  NO--voice
@property (nonatomic) BOOL emojiOrVoice;

//录音
@property (nonatomic, strong) MLAudioRecorder *recorder;
@property (nonatomic, strong) AmrRecordWriter *amrWriter;

@property (nonatomic, strong) MLAudioPlayer *player;
@property (nonatomic, strong) AmrPlayerReader *amrReader;

@property (nonatomic, strong) AVAudioPlayer *avAudioPlayer;

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) MLAudioMeterObserver *meterObserver;

@property (nonatomic, strong) NSTimer *recordTimer;

//存每个emoji的数组
@property (nonatomic, strong) NSMutableArray *emojiArray;
@end

@implementation EmojiViewController

#define UP YES  //UP代表自己发送  上升
#define DOWN NO //DOWN代表接收  下落

- (void)startRecord {
    if (self.recorder.isRecording) {
        //取消录音
        [self.recorder stopRecording];
        
//        self.amrReader.filePath = self.amrWriter.filePath;
//        
//        if (self.player.isPlaying) {
//            [self.player stopPlaying];
//        }else{
//            [self.player startPlaying];
//        }
    }
}

- (void)recordCell:(EmojiSoundCell *)cell {
    NSLog(@"EmojiSoundCell name:%li", cell.emojiNum);
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *soundName = [NSString stringWithFormat:@"%@.amr", cell.emojiName];
    self.amrWriter.filePath = [path stringByAppendingPathComponent:soundName];
    //NSLog(@"EmojiSoundCell count:%li", [_emojiArray count]);
    //[_emojiArray objectAtIndex:cell.emojiNum];
    Emoji *emj = [[ResourceManager sharedInstance].emojiArray objectAtIndex:cell.emojiNum];
    emj.isRecord = YES;
    emj.soundPath = self.amrWriter.filePath;
    
    cell.isRecord = YES;
    cell.soundPath = self.amrWriter.filePath;
    
    _recordTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(startRecord) userInfo:nil repeats:NO];
    
    if (!self.recorder.isRecording) {
        [self.recorder startRecording];
        self.meterObserver.audioQueue = self.recorder->_audioQueue;
    }

}

//滑动返回 需要修改
- (IBAction)swipeBack:(id)sender {
    //通知session 当前聊天用户为空
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ClearCurrentFriend" object:nil];
    [self performSegueWithIdentifier:@"BackToMain" sender:self];
}

- (IBAction)segmentValueChanged:(id)sender {
    switch([(UISegmentedControl *)sender selectedSegmentIndex]) {
        case 0:
            NSLog(@"%@", @"image!!!");
            _emojiKeyboard.hidden = NO;
            _voiceKeyboard.hidden = YES;
            _emojiOrVoice = YES;
            break;
        case 1:
            NSLog(@"%@", @"voice!!!");
            _emojiKeyboard.hidden = YES;
            _voiceKeyboard.hidden = NO;
            _emojiOrVoice = NO;
            break;
        default:
            _emojiOrVoice = YES;
            break;
    }
}

- (IBAction)dropOfflineMsg:(id)sender {
    if ([_msgArray count]) {
        for (NotifyMsg *msg in _msgArray) {
            NSString *imgName;
            if ([msg.type isEqualToString:@"Voice"]) {
                imgName = @"emoji_audio";
            } else if ([msg.type isEqualToString:@"Emoji"]) {
                imgName = [NSString stringWithFormat:@"emoji_%@", msg.resid];
            }
            [self dropUpOrDown:DOWN withXratio:[msg.xratio intValue] andImgName:imgName andType:msg.type andResid:msg.resid];
        }
        [_friendButton setTitle:_chatFriend.account forState:UIControlStateNormal];
        [_timer invalidate];
        [NotifyMsg deleteFriendMsg:_chatFriend inManagedObjectContext:_context];
        if ([self.context save:nil]) {
            NSLog(@"delete successd");
        } else {
            NSLog(@"delete failed");
        }
        //清空数据库
        //不能批量？
        //[_context deletedObjects:[NSSet setWithArray:_msgArray]];
    }
}

- (void)shakeTillClick {
    [Animation shakeView:_friendButton];
}

- (void)initRecorder {
    
    AmrRecordWriter *amrWriter = [[AmrRecordWriter alloc]init];
    //amrWriter.filePath = [path stringByAppendingPathComponent:@"record.amr"];
    amrWriter.maxSecondCount = 60;
    amrWriter.maxFileSize = 1024*256;
    self.amrWriter = amrWriter;
    
    MLAudioMeterObserver *meterObserver = [[MLAudioMeterObserver alloc]init];
    meterObserver.actionBlock = ^(NSArray *levelMeterStates,MLAudioMeterObserver *meterObserver){
        //DLOG(@"volume:%f",[MLAudioMeterObserver volumeForLevelMeterStates:levelMeterStates]);
    };
    meterObserver.errorBlock = ^(NSError *error,MLAudioMeterObserver *meterObserver){
        [[[UIAlertView alloc]initWithTitle:@"错误" message:error.userInfo[NSLocalizedDescriptionKey] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil]show];
    };
    self.meterObserver = meterObserver;
    
    MLAudioRecorder *recorder = [[MLAudioRecorder alloc]init];
    __weak __typeof(self)weakSelf = self;
    recorder.receiveStoppedBlock = ^{
        //[weakSelf.recordButton setTitle:@"Record" forState:UIControlStateNormal];
        weakSelf.meterObserver.audioQueue = nil;
    };
    recorder.receiveErrorBlock = ^(NSError *error){
        //[weakSelf.recordButton setTitle:@"Record" forState:UIControlStateNormal];
        weakSelf.meterObserver.audioQueue = nil;
        
        [[[UIAlertView alloc]initWithTitle:@"错误" message:error.userInfo[NSLocalizedDescriptionKey] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil]show];
    };

    recorder.bufferDurationSeconds = 0.5;
    recorder.fileWriterDelegate = self.amrWriter;
    
    self.recorder = recorder;
  
    MLAudioPlayer *player = [[MLAudioPlayer alloc]init];
    AmrPlayerReader *amrReader = [[AmrPlayerReader alloc]init];
    
    player.fileReaderDelegate = amrReader;
    player.receiveErrorBlock = ^(NSError *error){
        //[weakSelf.playButton setTitle:@"Play" forState:UIControlStateNormal];
        
        [[[UIAlertView alloc]initWithTitle:@"错误" message:error.userInfo[NSLocalizedDescriptionKey] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil]show];
    };
    player.receiveStoppedBlock = ^{
        //[weakSelf.playButton setTitle:@"Play" forState:UIControlStateNormal];
    };
    self.player = player;
    self.amrReader = amrReader;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //将用户添加到 session的watchId中
    _appDelegate = [[UIApplication sharedApplication] delegate];
    _sessionManager = [BiuSessionManager sharedInstance];
    [_sessionManager addWatchPeerId:_chatFriend.id andSetCurFriend:_chatFriend];
    
    //获取数据库的信息
    _context = _appDelegate.document.managedObjectContext;
    
    NSArray *array = [NotifyMsg recentlyOfflineMsg:_chatFriend inManagedObjectContext:_context];
    
    NSMutableString *title = [NSMutableString stringWithString:_chatFriend.account];
    if ([array count]) {
        _msgArray = [[NSMutableArray alloc] initWithArray:array];
        [title appendString:@"!!!"];
        //定时
        _timer = [NSTimer timerWithTimeInterval:2.0f target:self selector:@selector(shakeTillClick) userInfo:nil repeats:YES];
    } else {
        _msgArray = [[NSMutableArray alloc] init];
    }
    
    [_friendButton setTitle:title forState:UIControlStateNormal];
    NSLog(@"recieve msg : %li", (unsigned long)[array count]);
    
    //加载plist
    _emojiOrVoice = YES;
    _emojiDictionary = [[ResourceManager sharedInstance] readEmojiInfo];
    _voiceDictionary = [[ResourceManager sharedInstance] readVoiceInfo];
    _emojiArray = [[ResourceManager sharedInstance] emojiSoundInfo];
    NSLog(@"emojiSoundInfo count:%li", [_emojiArray count]);
    //声音
    [SoundManager sharedManager].allowsBackgroundMusic = YES;
    [[SoundManager sharedManager] prepareToPlay];
    
    [self initRecorder];
    _emojiArray = [[NSMutableArray alloc] init];
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
}

- (void)recieveMsg:(NSNotification *)notification {
    AVMessage *msg = [notification object];
    NSLog(@"recieve msg : %@", msg.payload);
    NSDictionary *dict = nil;
    NSError *error = nil;
    NSData *data = [msg.payload dataUsingEncoding:NSUTF8StringEncoding];
    dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSString *resid = [dict objectForKey:@"resid"];
    NSString *xratio = [dict objectForKey:@"xratio"];
    NSString *type = [dict objectForKey:@"type"];
    NSString *imgName;
    if ([type isEqualToString:@"Voice"]) {
        imgName = @"emoji_audio";
    } else if ([type isEqualToString:@"Emoji"]) {
        imgName = [NSString stringWithFormat:@"emoji_%@", resid];//imgName = resid;
    }
    [self dropUpOrDown:DOWN withXratio:[xratio intValue] andImgName:imgName andType:type andResid:resid];
}

static const CGSize DROP_SIZE = {50, 50};

- (void)dropUpOrDown:(BOOL)isUp withXratio:(int)x andImgName:(NSString *)imgName andType:(NSString *)type andResid:(NSString *)resid {
    NSInteger height = _emojiKeyboard.center.y - _emojiKeyboard.bounds.size.height / 2 - _friendButton.bounds.size.height;
    
    CGRect frame;
    frame.origin = CGPointZero;
    frame.size = DROP_SIZE;
    //int x = (arc4random() % (int)(_view.bounds.size.width) / DROP_SIZE.width - 1);
    CGFloat quarter;
    CGFloat half;
    if (isUp == UP) {
        frame.origin = CGPointMake(x * DROP_SIZE.width, height + _friendButton.bounds.size.height - DROP_SIZE.height);
        quarter = height * 3 / 4 + _friendButton.bounds.size.height + DROP_SIZE.height / 2;
        half = height / 2 + _friendButton.bounds.size.height + DROP_SIZE.height / 2;
    } else {
        frame.origin = CGPointMake(x * DROP_SIZE.width, _friendButton.bounds.size.height);
        quarter = height / 4 + _friendButton.bounds.size.height - DROP_SIZE.height / 2;
        half = height / 2 + _friendButton.bounds.size.height - DROP_SIZE.height / 2;
    }
    
    UIImageView *dropView = [[UIImageView alloc] initWithFrame:frame];
    dropView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", imgName]];
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
    
    if ([type isEqualToString:@"Voice"]) {
        [[SoundManager sharedManager] playSound:[self getVoicePath:resid] looping:NO];
    } else {
        Emoji *emj = [[ResourceManager sharedInstance].emojiArray objectAtIndex:[resid integerValue] - 1];//[_emojiArray objectAtIndex:[resid integerValue] - 1];
        if (emj.isRecord) {
            self.amrReader.filePath = emj.soundPath;
            
            if (self.player.isPlaying) {
                [self.player stopPlaying];
            }else{
                [self.player startPlaying];
            }
        }
        
    }
}

- (void)sendMsgByPassingResid:(NSString *)resid andXratio:(NSString *)xratio andType:(NSString *)type{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[AVUser currentUser].objectId forKey:@"fromid"];
    [dict setObject:[AVUser currentUser].username forKey:@"fromName"];
    [dict setObject:type forKey:@"type"];
    [dict setObject:resid forKey:@"resid"];
    [dict setObject:xratio forKey:@"xratio"];
    [_sessionManager sendNotifyMsgWithDictionary:dict toPeerId:_chatFriend.id];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EmojiSoundCell *cell;
    if ([collectionView.restorationIdentifier isEqualToString:@"ImageSegment"]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"emojiCell" forIndexPath:indexPath];
        
        UIImageView *view = (UIImageView *)[cell viewWithTag:100];
        view.image = [UIImage imageNamed:[NSString stringWithFormat:@"emoji_%02li.png", (indexPath.row + 1)]];
        cell.emojiNum = indexPath.row;
        cell.emojiName = [NSString stringWithFormat:@"emoji_%02li", (indexPath.row + 1)];
        cell.delegate = self;
    }
    if ([collectionView.restorationIdentifier isEqualToString:@"VoiceSegment"]) {
        //NSLog(@"VoiceSegment!!!");
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"voiceCell" forIndexPath:indexPath];
        UILabel *label = (UILabel *)[cell viewWithTag:100];
        label.text = [[_voiceDictionary objectForKey:[NSString stringWithFormat:@"%02li", (indexPath.row + 1)]] objectForKey:@"content"];
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([collectionView.restorationIdentifier isEqualToString:@"ImageSegment"])
        return [_emojiDictionary count];
    else if ([collectionView.restorationIdentifier isEqualToString:@"VoiceSegment"])
        return [_voiceDictionary count];
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    NSString *type;
    NSString *str = [NSString stringWithFormat:@"%02li",(long)indexPath.row + 1];
    NSDictionary *dic;
    int x = (arc4random() % (int)(self.view.bounds.size.width) / DROP_SIZE.width - 1);
    
    if ([collectionView.restorationIdentifier isEqualToString:@"ImageSegment"]) {
        dic = [_emojiDictionary objectForKey:str];
        type = @"Emoji";
        [self sendMsgByPassingResid:[dic objectForKey:@"resid"] andXratio:[NSString stringWithFormat:@"%i", x] andType:type];
        NSString *imgName = [NSString stringWithFormat:@"emoji_%@", str];
        [self dropUpOrDown:UP withXratio:x andImgName:imgName andType:type andResid:[dic objectForKey:@"resid"]];
    }
    else if ([collectionView.restorationIdentifier isEqualToString:@"VoiceSegment"]) {
        dic = [_voiceDictionary objectForKey:str];
        type = @"Voice";
        [self sendMsgByPassingResid:[dic objectForKey:@"resid"] andXratio:[NSString stringWithFormat:@"%i", x] andType:type];
        [self dropUpOrDown:UP withXratio:x andImgName:[dic objectForKey:@"name"] andType:type andResid:[dic objectForKey:@"resid"]];
    }
}

- (NSString *)getVoicePath:(NSString *)resid {
    NSDictionary *dic = [_voiceDictionary objectForKey:resid];
    return [dic objectForKey:@"path"];
}

- (NSString *)getImgName:(NSString *)resid {
    NSDictionary *dic = [_emojiDictionary objectForKey:resid];
    return [dic objectForKey:@"name"];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
