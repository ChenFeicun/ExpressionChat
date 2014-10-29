//
//  MainViewController.m
//  ExpressionChat
//
//  Created by Feicun on 14-10-8.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import "MainViewController.h"
#import "Friends.h"
#import "AppDelegate.h"
#import "EmojiViewController.h"
#import "BiuSessionManager.h"
#import "NotifyMsg.h"
#import "Animation.h"
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
//init—>loadView—>viewDidLoad—>viewWillApper—>viewDidApper—>viewWillDisapper—>viewDidDisapper—>viewWillUnload->viewDidUnload—>dealloc

- (IBAction)searchFriendEnd:(id)sender {
    [self searchFriendWithName];
}

- (void)searchFriendWithName {
    //先从数据库里检索 是否存在该用户 不存在的话云端检索
    if ([self.searchFriendTextField.text isEqualToString:self.curUser.username]) {
        //
        NSLog(@"yourself");
        return;
    }
    Friends *friend = [self isFriendExistInDB];
    if (!friend) {
        AVQuery *query = [AVUser query];
        [query whereKey:@"username" equalTo:self.searchFriendTextField.text];
        [query getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
            if (!error) {
                NSLog(@"Find %@", self.searchFriendTextField.text);
                //添加用户 关闭键盘
                //[self initDocument];
                [self addFriend:object];
                
                [self.searchFriendTextField resignFirstResponder];
                [self.friendsTableView reloadData];
            } else {
                NSLog(@"No such user");
                [Animation shakeView:_searchFriendTextField];
//                CATransition *animation = [CATransition animation];
//                animation.duration = 1.0f;
//                animation.type = @"rippleEffect";
//                [self.searchFriendTextField.layer addAnimation:animation forKey:nil];
            }
        }];
    } else {
        [self performSegueWithIdentifier:@"ChatWithFriend" sender:self];
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

#pragma mark -数据库操作

- (Friends *)isFriendExistInDB {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Friends"];
    request.predicate = [NSPredicate predicateWithFormat:@"account = %@", self.searchFriendTextField.text];
    NSError *error;
    NSArray *array = [self.context executeFetchRequest:request error:&error];
    if ([array count]) {
        return [array firstObject];
    } else {
        return nil;
    }
}

- (void)addFriend:(AVObject *)userObj {
    if ([self documentIsReady]) {
        Friends *friend = [NSEntityDescription insertNewObjectForEntityForName:@"Friends" inManagedObjectContext:self.context];
        friend.id = [userObj objectForKey:@"objectId"];
        friend.account = [userObj objectForKey:@"username"];
        if ([self.context save:nil]) {
            NSLog(@"add successd");
        } else {
            NSLog(@"add failed");
        }
    }
}

- (void)deleteFriend:(Friends *)delFriend {
    if ([self documentIsReady]) {
        [self.context deleteObject:delFriend];
        if ([self.context save:nil]) {
            NSLog(@"delete successd");
        } else {
            NSLog(@"delete failed");
        }
    }
}

- (void)allFriends {
    if ([self documentIsReady]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Friends"];
        //排序！！！
        request.predicate = nil;
        
        NSError *error;
        NSArray *array = [self.context executeFetchRequest:request error:&error];
        if (!error) {
            self.all = [[NSMutableArray alloc] initWithArray:array];
            //return self.all;
        } else
            NSLog(@"%@", error);
    } else {
        NSLog(@"failed allfriend");
        self.all = nil;
    }
}

//根据id查找离线消息
- (NSUInteger)getOfflineMsgCount:(Friends *)friend {
    if ([self documentIsReady]) {
        //应该有可以直接返回count的
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"NotifyMsg"];
        request.predicate = [NSPredicate predicateWithFormat:@"fromid = %@", friend.id];
        NSError *error;
        NSUInteger count = [self.context countForFetchRequest:request error:&error];
        return count;
    }
    return 0;
}

#pragma mark -页面
//每接收一条信息刷新一次页面
- (void)reloadTableView:(NSNotification *)notification {
    [self.friendsTableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView:) name:@"reloadTableView" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //NSLog(@"!!!!!!!!!!!!!!!!");
    self.curUser = [AVUser currentUser];
    [self.curButton setTitle:self.curUser.username forState:UIControlStateNormal];
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.document = self.appDelegate.document;
    self.sessionManager = [BiuSessionManager sharedInstance];
    //[self initDocument];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -tableView的相关操作

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [self allFriends];
    if (self.all) {
        //NSLog(@"select all success %lui", (unsigned long)[self.all count]);
        return [self.all count];
    } else {
        NSLog(@"111111");
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"celllllllll");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friend"];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"friend"];
    }
    
    if (self.all) {
        UILabel *label = (UILabel *)[cell viewWithTag:100];
        Friends *friend = self.all[indexPath.row];
        label.text = friend.account;
        
        //在这里根据friendid查找数据库 看是否有离线消息
        NSInteger count = [self getOfflineMsgCount:friend];
        if (count) {
            UILabel *label = (UILabel *)[cell viewWithTag:101];
            label.text = @"!!!";
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //
        Friends *friend = [self.all objectAtIndex:indexPath.row];
        [self deleteFriend:friend];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
//2
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //self.selectedFriend = [self.all objectAtIndex:indexPath.row];
    //[self.navigationController pushViewController:nil animated:YES];
}
//1
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ChatWithFriend"]) {
        EmojiViewController *controller = segue.destinationViewController;//(ChatViewController *)[segue.destinationViewController topViewController];
        NSIndexPath *path = [self.friendsTableView indexPathForCell:sender];
        controller.chatFriend = [self.all objectAtIndex:path.row];
    }
}



@end
