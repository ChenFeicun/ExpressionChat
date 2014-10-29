//
//  EmojiViewController.m
//  ExpressionChat
//
//  Created by Feicun on 14-10-15.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import "EmojiViewController.h"
#import "BiuSessionManager.h"
#import "Friends.h"
#import "NotifyMsg.h"
#import "AppDelegate.h"
#import "Animation.h"
#import <AVOSCloud/AVOSCloud.h>
#import <AVFoundation/AVFoundation.h>

@interface EmojiViewController ()
@property (strong, nonatomic) NSMutableArray *msgArray;
@property (weak, nonatomic) IBOutlet UICollectionView *emojiKeyboard;
@property (weak, nonatomic) IBOutlet UIButton *friendButton;
@property (strong, nonatomic) BiuSessionManager *sessionManager;
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *context;
//从plist文件中读取 应该是公用的 不需要每次打开聊天界面就读一次
@property (strong, nonatomic) NSDictionary *emojiDictonary;
//定时器
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation EmojiViewController

#define UP YES  //UP代表自己发送  上升
#define DOWN NO //DOWN代表接收  下落

- (IBAction)dropOfflineMsg:(id)sender {
    if ([_msgArray count]) {
        for (NotifyMsg *msg in _msgArray) {
            [self dropUpOrDown:DOWN withXratio:[msg.xratio intValue] andImgName:[self getImgName:msg.resid]];
        }
        [_friendButton setTitle:_chatFriend.account forState:UIControlStateNormal];
        [_timer invalidate];
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
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"NotifyMsg"];
    request.predicate = [NSPredicate predicateWithFormat:@"fromid = %@", _chatFriend.id];
    NSError *error;
    NSArray *array = [_context executeFetchRequest:request error:&error];
    
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
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Emoji" ofType:@"plist"];
    _emojiDictonary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
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
    [self dropUpOrDown:DOWN withXratio:[xratio intValue] andImgName:[self getImgName:resid]];
}

static const CGSize DROP_SIZE = {50, 50};

- (void)dropUpOrDown:(BOOL)isUp withXratio:(int)x andImgName:(NSString *)imgName
{
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
    /*
    NSInteger curCount = 0;
    while (curCount <= 50) {
        //NSLog(@"height %f", dropView.center.y - dropView.bounds.size.height);
        CGFloat currentStep = (-(height - dropView.bounds.size.height) * 8 /  (TIMES * TIMES * 10 / 2) * curCount + (height - dropView.bounds.size.height) * 9 / (TIMES * 10 / 2));
        //!!!!!
        //每次都判断 完全没必要
        currentStep = isUp ? currentStep : - currentStep;
        //NSLog(@"currentStep:%f curCount:%li", currentStep, curCount);
        
        [UIView animateWithDuration:2.0 animations:^{
            //NSLog(@"current alpha %f", dropView.alpha);
            dropView.alpha = ((-17.0 / 35.0) * curCount * curCount + (170.0 / 7.0) * curCount);
            dropView.center = CGPointMake(dropView.center.x, dropView.center.y - currentStep);
        } completion:^(BOOL finished) {
            if (finished) {
                [dropView removeFromSuperview];
            }
        }];
        curCount++;
    }
    
    */
    //NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(emojiDrop) object:nil];
    
    //[NSThread detachNewThreadSelector:@selector(emojiDrop:) toTarget:dropView withObject:nil];
    /*
    dispatch_queue_t queue = dispatch_queue_create("emojiDrop", NULL);
    //创建一个子线程
    
    dispatch_async(queue, ^{
        if (curCount == 50) {
            //
        } else {
            float currentStep = (float) (-(250 - dropView.bounds.size.height) * 8 /  (TIMES * TIMES * 10 / 2) * curCount + (250 - dropView.bounds.size.height) * 9 / (TIMES * 10 / 2));
            NSLog(@"currentStep:%f curCount:%li", currentStep, curCount);
            [UIView beginAnimations:@"AnimationName0" context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            dropView.center = CGPointMake(dropView.center.x, dropView.center.y + currentStep);
            [UIView commitAnimations];
        
            curCount++;
        }
    });
    */
}

- (void)sendMsgByPassingResid:(NSString *)resid andXratio:(NSString *)xratio {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[AVUser currentUser].objectId forKey:@"fromid"];
    [dict setObject:[AVUser currentUser].username forKey:@"fromName"];
    //[dict setObject:msg.type forKey:@"type"];
    [dict setObject:resid forKey:@"resid"];
    [dict setObject:xratio forKey:@"xratio"];
    [_sessionManager sendNotifyMsgWithDictionary:dict toPeerId:_chatFriend.id];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"emojiCell" forIndexPath:indexPath];
    
    UIImageView *view = (UIImageView *)[cell viewWithTag:100];
    view.image = [UIImage imageNamed:[NSString stringWithFormat:@"emoji_%02li.png", (indexPath.row + 1)]];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 33;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //NSString *str = [NSString stringWithFormat:@"%02li", indexPath.row];
    //NSLog(@"%@", str);
    
    //NotifyMsg *msg = [[NotifyMsg alloc] init];
    //[_sessionManager sendMessage:@"" toPeerId:_chatFriend.id];
    //dispatch_queue_t main_queue = dispatch_get_main_queue();//dispatch_queue_create("emojiDrop", NULL);
    //创建一个子线程
    //跟UI相关的需要在主线程里操作
    //dispatch_async(main_queue, ^{
    NSString *str = [NSString stringWithFormat:@"%02li",(long)indexPath.row + 1];
    NSDictionary *dic = [_emojiDictonary objectForKey:str];
    int x = (arc4random() % (int)(self.view.bounds.size.width) / DROP_SIZE.width - 1);
    [self sendMsgByPassingResid:[dic objectForKey:@"resid"] andXratio:[NSString stringWithFormat:@"%i", x]];
    [self dropUpOrDown:UP withXratio:x andImgName:[dic objectForKey:@"name"]];
    //});
}

- (NSString *)getImgName:(NSString *)resid {
    NSDictionary *dic = [_emojiDictonary objectForKey:resid];
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
