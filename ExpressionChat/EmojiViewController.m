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
#import "SunSegmentView.h"

#import <AVOSCloud/AVOSCloud.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "RecordAudio.h"

@interface EmojiViewController () <RecordAudioDelegate, SunSegmentViewDelegate> {
    RecordAudio *recordAudio;
    NSData *curAudio;
    BOOL isRecording;
}

@property (strong, nonatomic) NSMutableArray *msgArray;
//@property (weak, nonatomic) IBOutlet UICollectionView *emojiKeyboard;
//@property (weak, nonatomic) IBOutlet UICollectionView *voiceKeyboard;
@property (strong, nonatomic) UICollectionView *emojiKeyboard;
@property (strong, nonatomic) UICollectionView *voiceKeyboard;
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
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) NSTimer *recordTimer;
//存每个emoji的数组
//@property (nonatomic, strong) NSMutableArray *emojiArray;
@property (nonatomic, strong) Emoji *tempEmoji;
@end

static double startRecordTime=0;
static double endRecordTime=0;

@implementation EmojiViewController

#define UP YES  //UP代表自己发送  上升
#define DOWN NO //DOWN代表接收  下落
#define CELL_PADDING 8
#define Ratio 1.77
static CGSize DROP_SIZE;
static CGFloat VIEW_WIDTH;
static CGFloat VIEW_HEIGHT;
static CGFloat CELL_IMG_X;
static CGFloat CELL_IMG_Y;
static CGFloat CELL_IMG;

- (void)RecordStatus:(int)status {
    if (status == 0){
        //播放中
    } else if(status == 1){
        //完成
        NSLog(@"播放完成");
    }else if(status == 2){
        //出错
        NSLog(@"播放出错");
    }
}

- (void)startRecord {
    
    endRecordTime = [NSDate timeIntervalSinceReferenceDate];
    
    NSURL *url = [recordAudio stopRecord];
    
    if (url != nil) {
        curAudio = EncodeWAVEToAMR([NSData dataWithContentsOfURL:url],1,16);
        if (curAudio) {
            _tempEmoji.isRecord = YES;
            _tempEmoji.emojiData = curAudio;
            _tempEmoji.soundURL = url;
            NSLog(@"%@", [url path]);
            //[curAudio retain];
            
            NSString *fileName = [_tempEmoji.emojiName stringByAppendingString:@".amr"];
            AVFile *file = [AVFile fileWithName:fileName data:_tempEmoji.emojiData];
            [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded && !error) {
                    _tempEmoji.avosURL = file.url;
                }
            }];
        }
    }
}

- (void)recordCell:(EmojiSoundCell *)cell {
    NSLog(@"EmojiSoundCell name:%li", cell.emojiNum);
    _tempEmoji = [[ResourceManager sharedInstance].emojiArray objectAtIndex:cell.emojiNum];
    //录音时间1s
    _recordTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(startRecord) userInfo:nil repeats:NO];
    //[recordAudio stopPlay];
    [recordAudio startRecord];
    startRecordTime = [NSDate timeIntervalSinceReferenceDate];
    
    curAudio=nil;
}

//滑动返回 需要修改
- (IBAction)swipeBack:(id)sender {
    //关闭当前声音
    [[SoundManager sharedManager] stopAllSounds];
    //通知session 当前聊天用户为空
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ClearCurrentFriend" object:nil];
    [[ResourceManager sharedInstance] removeSoundFile];
    [self performSegueWithIdentifier:@"BackToMain" sender:self];
}

- (void)shakeTillClick {
    [Animation shakeView:_friendButton];
}

-(void)SunSegmentClick:(NSInteger)index {
    
    switch(index) {
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

#pragma mark - 消息处理
- (IBAction)dropOfflineMsg:(id)sender {
    if ([_msgArray count]) {
        for (NotifyMsg *msg in _msgArray) {
            NSString *imgName;
            if ([msg.type isEqualToString:@"Voice"]) {
                imgName = @"emoji_audio";
            } else if ([msg.type isEqualToString:@"Emoji"]) {
                imgName = msg.resid;//[NSString stringWithFormat:@"emoji_%@", msg.resid];
            }
            
            //下载文件
            if (msg.fileUrl) {
                AVFile *file = [AVFile fileWithURL:msg.fileUrl];
                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (data && !error) {
                         [recordAudio play:data];
                    }
                }];
            }
            [self dropUpOrDown:DOWN withXratio:[msg.xratio floatValue] andImgName:imgName andType:msg.type andResid:msg.resid];
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
        imgName = resid;//[NSString stringWithFormat:@"emoji_%@", resid];//imgName = resid;
    }
    
    NSString *fileUrl = [dict objectForKey:@"url"];
    if (fileUrl) {
        AVFile *file = [AVFile fileWithURL:fileUrl];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (data && !error) {
                [recordAudio play:data];
            }
        }];
    }
    
    [self dropUpOrDown:DOWN withXratio:[xratio floatValue] andImgName:imgName andType:type andResid:resid];
}

- (void)dropUpOrDown:(BOOL)isUp withXratio:(int)x andImgName:(NSString *)imgName andType:(NSString *)type andResid:(NSString *)resid {
    NSInteger height = _emojiKeyboard.center.y - _emojiKeyboard.bounds.size.height / 2 - _friendButton.bounds.size.height;
    
    x = x * DROP_SIZE.width;
    
    CGRect frame = CGRectMake(CELL_IMG_X, CELL_IMG_Y, CELL_IMG, CELL_IMG);
    //int x = (arc4random() % (int)(_view.bounds.size.width / DROP_SIZE.width));
    CGFloat quarter;
    CGFloat half;
    if (isUp == UP) {
        frame.origin = CGPointMake(x + CELL_IMG_X, height + _friendButton.bounds.size.height - DROP_SIZE.height);
        quarter = height * 3 / 4 + _friendButton.bounds.size.height + DROP_SIZE.height / 2;
        half = height / 2 + _friendButton.bounds.size.height + DROP_SIZE.height / 2;
    } else {
        frame.origin = CGPointMake(x + CELL_IMG_X, _friendButton.bounds.size.height);
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
        NSString *str = [resid substringFromIndex:resid.length - 2];
        Emoji *emj = [[ResourceManager sharedInstance].emojiArray objectAtIndex:[str integerValue] - 1];
        if (emj.isRecord) {
            [recordAudio play:emj.emojiData];
        }
        
    }
}

- (void)sendMsgByPassingResid:(NSString *)resid andXratio:(NSString *)xratio andType:(NSString *)type andAVOSUrl:(NSString *)avosUrl {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[AVUser currentUser].objectId forKey:@"fromid"];
    [dict setObject:[AVUser currentUser].username forKey:@"fromName"];
    [dict setObject:type forKey:@"type"];
    [dict setObject:resid forKey:@"resid"];
    [dict setObject:xratio forKey:@"xratio"];
    if (avosUrl) {
        [dict setObject:avosUrl forKey:@"url"];
    }
    [_sessionManager sendNotifyMsgWithDictionary:dict toPeerId:_chatFriend.id];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView.restorationIdentifier isEqualToString:@"ImageSegment"]) {
        //cell = [[EmojiSoundCell alloc] init];
        EmojiSoundCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"emojiCell" forIndexPath:indexPath];
        for (UIView *subView in cell.subviews) {
            if (![subView isEqual:cell.contentView]) {
                [subView removeFromSuperview];
            }
        }
        [Animation setBackgroundColorWithGrey:cell.selectedBackgroundView];
        [cell triggerRecorder];
        CELL_IMG_X = (cell.frame.size.width - cell.frame.size.height) / 2 + CELL_PADDING / 2;
        CELL_IMG_Y = CELL_PADDING / 2;
        CELL_IMG = cell.frame.size.height - CELL_PADDING;
        CGRect rect = CGRectMake(CELL_IMG_X, CELL_IMG_Y, CELL_IMG, CELL_IMG);
        UIImageView *view = [[UIImageView alloc] initWithFrame:rect];
        view.image = [UIImage imageNamed:[NSString stringWithFormat:@"emoji_%02li.png", (indexPath.row + 1)]];
        [cell addSubview:view];
        cell.emojiNum = indexPath.row;
        cell.emojiName = [NSString stringWithFormat:@"emoji_%02li", (indexPath.row + 1)];
        cell.delegate = self;
        return cell;
    }
    if ([collectionView.restorationIdentifier isEqualToString:@"VoiceSegment"]) {
        //NSLog(@"VoiceSegment!!!");
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"voiceCell" forIndexPath:indexPath];
        for (UIView *subView in cell.subviews) {
            [subView removeFromSuperview];
        }
        [Animation setBackgroundColorWithGrey:cell.selectedBackgroundView];
        CGRect rect = CGRectMake(CELL_PADDING, CELL_PADDING, cell.frame.size.width - CELL_PADDING * 2, cell.frame.size.height - CELL_PADDING);
        UILabel *label = [[UILabel alloc] initWithFrame:rect];
        label.font = [UIFont boldSystemFontOfSize:17.0f];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [[_voiceDictionary objectForKey:[NSString stringWithFormat:@"%02li", (indexPath.row + 1)]] objectForKey:@"content"];
        [cell addSubview:label];
        return cell;
    }
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([collectionView.restorationIdentifier isEqualToString:@"ImageSegment"])
        return [_emojiDictionary count];
    else if ([collectionView.restorationIdentifier isEqualToString:@"VoiceSegment"])
        return [_voiceDictionary count];
    return 0;
}

//点击下去 背景色应该改变 
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *type;
    NSString *str = [NSString stringWithFormat:@"%02li",(long)indexPath.row + 1];
    NSDictionary *dic;
    int x = (arc4random() % 7);
    
    if ([collectionView.restorationIdentifier isEqualToString:@"ImageSegment"]) {
        Emoji *emj = [[ResourceManager sharedInstance].emojiArray objectAtIndex:indexPath.row];//[_emojiArray objectAtIndex:indexPath.row];
        
        dic = [_emojiDictionary objectForKey:str];
        type = @"Emoji";
        [self sendMsgByPassingResid:[dic objectForKey:@"resid"] andXratio:[NSString stringWithFormat:@"%i", x] andType:type andAVOSUrl:emj.avosURL];
        NSString *imgName = [NSString stringWithFormat:@"emoji_%@", str];
        [self dropUpOrDown:UP withXratio:x andImgName:imgName andType:type andResid:[dic objectForKey:@"resid"]];
    }
    else if ([collectionView.restorationIdentifier isEqualToString:@"VoiceSegment"]) {
        dic = [_voiceDictionary objectForKey:str];
        type = @"Voice";
        [self sendMsgByPassingResid:[dic objectForKey:@"resid"] andXratio:[NSString stringWithFormat:@"%i", x] andType:type andAVOSUrl:nil];
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

#pragma mark - 初始化
- (void)initSegmentView {
    UIColor *selectColor = [[UIColor alloc] initWithRed:245.0 / 255.0 green:245.0 / 255.0 blue:245.0 / 255.0 alpha:1.0];
    UIColor *normalColor = [[UIColor alloc] initWithRed:117.0 / 255.0 green:117.0 / 255.0 blue:117.0 / 255.0 alpha:1.0];
    SunSegmentView *segmentView=[[SunSegmentView alloc] initWithFrame:CGRectMake(0, VIEW_HEIGHT - 40, VIEW_WIDTH, 40) withViewCount:2 withNormalColor:normalColor withSelectColor:selectColor withNormalTitleColor:selectColor withSelectTitleColor:normalColor];
    segmentView.titleArray = @[@"Image", @"Audio"];
    segmentView.selectIndex = 0;
    segmentView.backgroundColor = [UIColor clearColor];
    segmentView.titleFont = [UIFont boldSystemFontOfSize:17.0];
    segmentView.segmentDelegate = self;
    [self.view addSubview:segmentView];
}

- (void)initResource {
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
    
    //声音
    [SoundManager sharedManager].allowsBackgroundMusic = YES;
    [[SoundManager sharedManager] prepareToPlay];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"OpenOrClose"]) {
        [[SoundManager sharedManager] setVolumeToZero];
    } else {
        [[SoundManager sharedManager] setVolumeToOne];
    }
    
    //录音
    recordAudio = [[RecordAudio alloc]init];
    recordAudio.delegate = self;
}

- (void)initCollectionView {
    
    UICollectionViewFlowLayout *emojiFL = [[UICollectionViewFlowLayout alloc] init];
    emojiFL.itemSize = DROP_SIZE;//CGSizeMake(VIEW_WIDTH / 7, VIEW_WIDTH / 7 - CELL_PADDING * 2);
    emojiFL.minimumInteritemSpacing = 0;
    emojiFL.minimumLineSpacing = 0;
    [emojiFL setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    CGRect frame = CGRectMake(0, VIEW_HEIGHT - (VIEW_WIDTH / 7 * 3 + 40) + CELL_PADDING * 3, VIEW_WIDTH, VIEW_WIDTH / 7 * 3 - CELL_PADDING * 3);
    _emojiKeyboard = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:emojiFL];
    [Animation setBackgroundColorWithLight:_emojiKeyboard];
    _emojiKeyboard.restorationIdentifier = @"ImageSegment";
    _emojiKeyboard.delegate = self;
    _emojiKeyboard.dataSource = self;
    [_emojiKeyboard registerClass:[EmojiSoundCell class] forCellWithReuseIdentifier:@"emojiCell"];
    [self.view addSubview:_emojiKeyboard];
    _emojiKeyboard.hidden = NO;
    
    UICollectionViewFlowLayout *voiceFL = [[UICollectionViewFlowLayout alloc] init];
    voiceFL.itemSize = CGSizeMake(VIEW_WIDTH / 3, VIEW_WIDTH / 7 - CELL_PADDING * 2);
    voiceFL.minimumInteritemSpacing = 0;
    voiceFL.minimumLineSpacing = 0;
    [voiceFL setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    _voiceKeyboard = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:voiceFL];
    [Animation setBackgroundColorWithLight:_voiceKeyboard];
    _voiceKeyboard.restorationIdentifier = @"VoiceSegment";
    _voiceKeyboard.delegate = self;
    _voiceKeyboard.dataSource = self;
    [_voiceKeyboard registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"voiceCell"];
    [self.view addSubview:_voiceKeyboard];
    _voiceKeyboard.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    VIEW_WIDTH = self.view.frame.size.width;
    VIEW_HEIGHT = self.view.frame.size.height;
    NSLog(@"--Width Height--:%f, %f", VIEW_WIDTH, VIEW_HEIGHT);
    DROP_SIZE = CGSizeMake(VIEW_WIDTH / 7, VIEW_WIDTH / 7 - CELL_PADDING * 2);
    [self initCollectionView];
    [self initSegmentView];
    [self initResource];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
