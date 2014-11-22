//
//  MainViewController.m
//  ExpressionChat
//
//  Created by Feicun on 14-10-8.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import "MainViewController.h"
#import "Friends.h"
#import "Friends+Methods.h"
#import "NotifyMsg+Methods.h"
#import "AppDelegate.h"
#import "EmojiViewController.h"
#import "BiuSessionManager.h"
#import "NotifyMsg.h"
#import "Animation.h"
#import "Toast.h"
#import "UINavigationController+YRBackGesture.h"
#import <AVOSCloud/AVOSCloud.h>

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UITextField *searchFriendTextField;
@property (weak, nonatomic) IBOutlet UIButton *curButton;
@property (weak, nonatomic) IBOutlet UITableView *friendsTableView;
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
        [[Toast makeToast:@"就是你!"] show];
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
                    [Friends addFriend:object inManagedObjectContext:_context];
                    //[self addFriend:object];
                    self.searchFriendTextField.text = @"";
                    [self.searchFriendTextField resignFirstResponder];
                    [self.friendsTableView reloadData];
                } else {
                    //NSLog(@"No such user");
                    [[Toast makeToast:@"查无此人"] show];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.friendsTableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView:) name:@"reloadTableView" object:nil];
    [self.navigationController setEnableBackGesture:YES];
    self.curUser = [AVUser currentUser];
    [self.curButton setTitle:self.curUser.username forState:UIControlStateNormal];
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.document = self.appDelegate.document;
    self.sessionManager = [BiuSessionManager sharedInstance];
    [self documentIsReady];
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
        UILabel *label = (UILabel *)[cell viewWithTag:100];
        Friends *friend = self.all[indexPath.row];
        NSLog(@"%@", friend.id);
        label.text = friend.username;
        //在这里根据friendid查找数据库 看是否有离线消息
        NSInteger count = [NotifyMsg getOfflineMsgCount:friend inManagedObjectContext:_context];
        UILabel *lab = (UILabel *)[cell viewWithTag:101];
        if (count) {
            lab.text = @"!!!";
            [Animation shakeView:cell];
        } else
            lab.text = @"";
        [Animation setBackgroundColorWithWhite:label];
        [Animation setBackgroundColorWithWhite:lab];
    }
    return cell;
}

- (IBAction)toSettings:(id)sender {
    //[Animation setBackgroundColorWithDark:sender];
    [self performSegueWithIdentifier:@"MainToSettings" sender:self];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //
        Friends *friend = [self.all objectAtIndex:indexPath.row];
        [Friends deleteFriend:friend inManagedObjectContext:_context];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

//2
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    JZSwipeCell *cell = (JZSwipeCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.delegate = self;
    [cell triggerSwipeWithType:JZSwipeTypeNone];
    
    [Animation setBackgroundColorWithLight:[cell viewWithTag:100]];
    [Animation setBackgroundColorWithLight:[cell viewWithTag:101]];
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
        if (indexPath)
        {
            Friends *friend = [_all objectAtIndex:indexPath.row];
            [Friends deleteFriend:friend inManagedObjectContext:_context];
            [NotifyMsg deleteFriendMsg:friend inManagedObjectContext:_context];
            //deleteRowsAtIndexPaths 执行完会自动删除
            //[self.all removeObjectAtIndex:indexPath.row];
            [self.friendsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)swipeCell:(JZSwipeCell *)cell swipeTypeChangedFrom:(JZSwipeType)from to:(JZSwipeType)to {
    // perform custom state changes here
    NSLog(@"Swipe Changed From (%d) To (%d)", from, to);
}
@end