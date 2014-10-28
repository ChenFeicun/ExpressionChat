//
//  ChatViewController.m
//  ExpressionChat
//
//  Created by Feicun on 14-10-10.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import "ChatViewController.h"
#import "Friends.h"
#import "BiuSessionManager.h"

@interface ChatViewController ()
@property (weak, nonatomic) IBOutlet UITextField *contentTF;
@property (strong, nonatomic) BiuSessionManager *sessionManager;
@end

@implementation ChatViewController

- (IBAction)cancel:(id)sender {
    NSLog(@"........");
}

- (IBAction)sendMsg:(id)sender {
    NSLog(@"%@", self.contentTF.text);
    [self.sessionManager sendMessage:self.contentTF.text toPeerId:_chatFriend.id];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self.delegate setFriendChatWith:self.chatFriend];
    //
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //将用户添加到 session的watchId中
    self.sessionManager = [BiuSessionManager sharedInstance];
    [self.sessionManager addWatchPeerId:self.chatFriend.id andSetCurFriend:self.chatFriend];
    //self.chatFriendNavigationItem.title = self.chatFriend.account;
    //NSLog(@"NavigationItemTitle : %@", self.chatFriend.account);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
