//
//  MainViewController.m
//  ExpressionChat
//
//  Created by Feicun on 14-10-8.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import "MainViewController.h"
#import "Friends+Methods.h"
#import "NotifyMsg+Methods.h"
#import "AppDelegate.h"
#import "EmojiViewController.h"
#import "BiuSessionManager.h"
#import "Animation.h"
#import "Toast.h"
#import "GuideView.h"
#import "UINavigationController+YRBackGesture.h"
#import <AVOSCloud/AVOSCloud.h>

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UITextField *searchFriendTextField;
@property (weak, nonatomic) IBOutlet UIButton *curButton;
@property (weak, nonatomic) IBOutlet UITableView *friendsTableView;
//Biu用户
@property (strong, nonatomic) NSTimer *biuTimer;
@property (strong, nonatomic) CellLabel *biuLabel;
//引导
//@property (strong, nonatomic) GuideView *guideView;

//数据库用
@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSMutableArray *all;
@property (retain, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) BiuSessionManager *sessionManager;

@end

@implementation MainViewController

- (IBAction)searchFriendEnd:(id)sender {
    [self searchFriendWithName];
}

- (void)searchFriendWithName {
    //先从数据库里检索 是否存在该用户 不存在的话云端检索
    if ([self.searchFriendTextField.text isEqualToString:self.curUser.username]) {
        //是否要进入Settings页面
        //NSLog(@"yourself");
        [[Toast makeToast:@"就是你!"] show:NO];
    } else {
        Friends *friend = [Friends isFriendExistInDB:_searchFriendTextField.text inManagedObjectContext:_context];
        if (!friend) {
            AVQuery *query = [AVUser query];
            [query whereKey:@"username" equalTo:self.searchFriendTextField.text];
            [query getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
                if (!error) {
                    //NSLog(@"Find %@", self.searchFriendTextField.text);
                    //添加用户 关闭键盘
                    //[self initDocument];
                    [Friends addFriendLocalAndCloud:object inManagedObjectContext:_context];
                    //[self addFriend:object];
                    self.searchFriendTextField.text = @"";
                    [self.searchFriendTextField resignFirstResponder];
                    [self.friendsTableView reloadData];
                } else {
                    //NSLog(@"No such user");
                    [[Toast makeToast:@"查无此人"] show:NO];
                    [Animation shakeView:_searchFriendTextField];
                }
            }];
        } else {
            [self performSegueWithIdentifier:@"ChatWithFriend" sender:self];
        }
    }
}

#pragma mark - 链接数据库的一些准备工作

- (BOOL)documentIsReady
{
    //NSLog(@"Document State is %lu", self.document.documentState);
    if (self.document.documentState == UIDocumentStateNormal) {
        // start using document
        self.context = self.document.managedObjectContext;
        return YES;
    }
    return NO;
}

#pragma mark -页面
//每接收一条信息刷新一次页面
- (void)reloadTableView:(NSNotification *)notification {
    //all需要根据消息的时间来排序
    //_all = [Friends allFriendsInManagedObjectContext:_context];
    [self.friendsTableView reloadData];
}

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _searchFriendTextField.text = @"";

    [self.sessionManager clearCurrentFriend];
    //if (![[NSUserDefaults standardUserDefaults] boolForKey:@"MainTip"]) {
    //第一次进来 即使有离线消息，也会在viewWillAppear之后 reload
    _all = [Friends allFriendsInManagedObjectContext:_context];
    [self.friendsTableView reloadData];
}

- (void)friendsSync {
    self.curUser = [AVUser currentUser];
    
    long long cloudTimestemp = [[[AVUser currentUser] objectForKey:@"timestamp"] longLongValue];
    long long localTimestemp = [[[NSUserDefaults standardUserDefaults] objectForKey:@"LocalTimestamp"] longLongValue];
//#warning 异步的  需要Toast等待？  reload
    _all = [Friends allFriendsInManagedObjectContext:_context];
    if (cloudTimestemp != localTimestemp) {
        AVRelation *relation = [[AVUser currentUser] relationforKey:@"friends"];
        AVQuery *friendQuery = [relation query];
        [friendQuery whereKey:@"ownerId" equalTo:self.curUser.objectId];
        //[friendQuery includeKey:@"friendId"]; 
        [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects && !error) {
                if (cloudTimestemp > localTimestemp) {
                    //从云端下载
                    [Friends addFriendsFromCloud:objects inManagedObjectContext:_context];
                } else {
                    //上传
                    BOOL isInCloud = NO;
                    NSString *friendId;
                    for (Friends *friend in _all) {
                        isInCloud = NO;
                        //是Biu的话不上传
                        if ([friend.username isEqualToString:@"Biu"]) {
                            continue;
                        }
                        for (AVObject *element in objects) {
                            friendId = [element objectForKey:@"friendId"];
                            if ([friend.id isEqualToString:friendId]) {
                                isInCloud = YES;
                                break;
                            }
                        }
                        if (!isInCloud) {
                            //传到云端
                            [Friends addFriendToCloud:friend];
                        }
                    }
                    //云端多余的要删掉
                    BOOL isExist = NO;
                    for (AVObject *element in objects) {
                        friendId = [element objectForKey:@"friendId"];
                        for (Friends *friend in _all) {
                            if ([friendId isEqualToString:friend.id]) {
                                isExist = YES;
                                break;
                            }
                        }
                        if (!isExist) {
                            //云端删除
                            [Friends deleteCloudFriend:friendId];
                        }
                    }
                }
            }
        }];
    } else {
        //如果都等于0 考虑上版本  当本地用户数不为0 上传
        if (localTimestemp == 0 && [_all count] > 0) {
            for (Friends *friend in _all) {
                if (![friend.username isEqualToString:@"Biu"])
                    [Friends addFriendToCloud:friend];
            }
        }
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    //数据库相关
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.sessionManager = [BiuSessionManager sharedInstance];
    self.document = self.appDelegate.document;
    [self documentIsReady];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView:) name:@"addCloudFriend" object:nil];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"Biu"]) {
        //添加Biu好友 (写死的)
        //时间戳设到很大的值 保证Biu是在第一个 13位
        [Friends addFriendWithUsername:@"Biu" andId:@"54a9f5bce4b08a3aeaece545" andTime:9999999999999 andUnread:YES inManagedObjectContext:self.context];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Biu"];
    }
    
    [self friendsSync];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView:) name:@"reloadTableView" object:nil];
    [self.navigationController setEnableBackGesture:YES];
    
    [self.curButton setTitle:self.curUser.username forState:UIControlStateNormal];
    
    //使 + 为白色
    [_searchFriendTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -tableView的相关操作

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    _all = [Friends allFriendsInManagedObjectContext:_context];
    if (_all) {
        return [self.all count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JZSwipeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friend"];
    if(cell == nil) {
        cell = [[JZSwipeCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"friend"];
    }
    cell.delegate = self;
    if (self.all) {
        CellLabel *label = (CellLabel *)[cell viewWithTag:100];
        Friends *friend = self.all[indexPath.row];
        //NSLog(@"%@", friend.id);
        label.text = friend.username;
        //在这里根据friendid查找数据库 看是否有离线消息
        //现在改成判断unread属性
        
        if ([friend.unread boolValue]) {
            if ([friend.username isEqualToString:@"Biu"]) {
                _biuLabel = label;
                if (!_biuTimer) {
                    _biuTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(biuShake) userInfo:nil repeats:YES];
                    [[NSRunLoop currentRunLoop] addTimer:_biuTimer forMode:NSDefaultRunLoopMode];
                }
            } else {
                [Animation shakeView:label];
            }
            [label showBang:YES];
        } else {
            [label showBang:NO];
        }
    }
    return cell;
}

- (void)biuShake {
    [Animation shakeView:_biuLabel];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (IBAction)toSettings:(id)sender {
    //[Animation setBackgroundColorWithDark:sender];
    [self performSegueWithIdentifier:@"MainToSettings" sender:self];
}

//2
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    JZSwipeCell *cell = (JZSwipeCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.delegate = self;
    [cell triggerSwipeWithType:JZSwipeTypeNone];
    Friends *friend = self.all[indexPath.row];
    if ([friend.username isEqualToString:@"Biu"]) {
        [_biuTimer setFireDate:[NSDate distantFuture]];
        [_biuTimer invalidate];
        _biuTimer = nil;
    }
    //[_guideView removeAll];
}
//1
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ChatWithFriend"]) {
        EmojiViewController *controller = segue.destinationViewController;
        NSIndexPath *path = [self.friendsTableView indexPathForCell:sender];
        controller.chatFriend = [self.all objectAtIndex:path.row];
    }
}

- (void)swipeCell:(JZSwipeCell*)cell triggeredSwipeWithType:(JZSwipeType)swipeType {
    if (swipeType != JZSwipeTypeNone) {
        NSIndexPath *indexPath = [self.friendsTableView indexPathForCell:cell];
        if (indexPath) {
            Friends *friend = [_all objectAtIndex:indexPath.row];
            [NotifyMsg deleteFriendMsg:friend inManagedObjectContext:_context];
            [Friends deleteFriendLocalAndCloud:friend inManagedObjectContext:_context];
            //deleteRowsAtIndexPaths 执行完会自动删除
            //[self.all removeObjectAtIndex:indexPath.row];
            [self.friendsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)swipeCell:(JZSwipeCell *)cell swipeTypeChangedFrom:(JZSwipeType)from to:(JZSwipeType)to {
    // perform custom state changes here
    //NSLog(@"Swipe Changed From (%d) To (%d)", from, to);
}
@end