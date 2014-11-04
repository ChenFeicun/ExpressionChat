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
//从plist文件中读取 应该是公用的 不需要每次打开聊天界面就读一次
@property (strong, nonatomic) NSDictionary *emojiDictionary;
@property (strong, nonatomic) NSDictionary *voiceDictionary;
//定时器
@property (strong, nonatomic) NSTimer *timer;
//segment YES--emoji  NO--voice
@property (nonatomic) BOOL emojiOrVoice;
@end

@implementation EmojiViewController

#define UP YES  //UP代表自己发送  上升
#define DOWN NO //DOWN代表接收  下落

//滑动返回 需要修改
- (IBAction)swipeBack:(id)sender {
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.7f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = kCATransitionReveal;
    animation.subtype = kCATransitionFromLeft;
    [[self.view layer] addAnimation:animation forKey:@"animation"];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)segmentValueChanged:(id)sender {
    switch([(UISegmentedControl *)sender selectedSegmentIndex])
    {
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
            [_context deleteObject:msg];
            if ([self.context save:nil]) {
                NSLog(@"delete successd");
            } else {
                NSLog(@"delete failed");
            }
        }
        [_friendButton setTitle:_chatFriend.account forState:UIControlStateNormal];
        [_timer invalidate];
        //清空数据库
        //不能批量？
        //[_context deletedObjects:[NSSet setWithArray:_msgArray]];
    }
}

- (void)shakeTillClick {
    [Animation shakeView:_friendButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //将用户添加到 session的watchId中
    _appDelegate = [[UIApplication sharedApplication] delegate];
    _sessionManager = [BiuSessionManager sharedInstance];
    [_sessionManager addWatchPeerId:_chatFriend.id andSetCurFriend:_chatFriend];
    
    //获取数据库的信息
    _context = _appDelegate.document.managedObjectContext;
    
    NSArray *array = [NotifyMsg getOfflineMsg:_chatFriend inManagedObjectContext:_context];
    
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
    //NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Emoji" ofType:@"plist"];
    //_emojiDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    _emojiOrVoice = YES;
    _emojiDictionary = [[ResourceManager sharedInstance] readEmojiInfo];
    _voiceDictionary = [[ResourceManager sharedInstance] readVoiceInfo];
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
    
    //[self sendMsgByPassingResid:@"1" andXratio:@""];
    
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
        SystemSoundID soundID = [[ResourceManager sharedInstance] getSoundIdByVoicePath:[self getVoicePath:resid]];
        AudioServicesPlaySystemSound(soundID);
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
    UICollectionViewCell *cell;
    if ([collectionView.restorationIdentifier isEqualToString:@"ImageSegment"]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"emojiCell" forIndexPath:indexPath];
        
        UIImageView *view = (UIImageView *)[cell viewWithTag:100];
        view.image = [UIImage imageNamed:[NSString stringWithFormat:@"emoji_%02li.png", (indexPath.row + 1)]];
    }
    if ([collectionView.restorationIdentifier isEqualToString:@"VoiceSegment"]) {
        NSLog(@"VoiceSegment!!!");
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
    
    //});
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
