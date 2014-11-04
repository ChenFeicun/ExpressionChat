//
//  BiuSessionManager.m
//  ExpressionChat
//
//  Created by Feicun on 14-10-13.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import "BiuSessionManager.h"
#import "AppDelegate.h"
#import "Friends.h"
#import "NotifyMsg.h"
#import "Friends+Methods.h"
#import "NotifyMsg+Methods.h"

@interface BiuSessionManager ()
@property (strong, nonatomic) AVSession *session;
@property (strong, nonatomic) Friends *chatFriendCurrent;
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *context;
@end

static id instance = nil;
static BOOL initialized = NO;
@implementation BiuSessionManager

+ (instancetype)sharedInstance {
    //dispatch_once_t 一般用来写单例
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    if (!initialized) {
        [instance commonInit];
    }
    return instance;
}

- (instancetype)init {
    
    if (self = [super init]) {
        AVSession *session = [[AVSession alloc] init];
        session.sessionDelegate = self;
        //session.signatureDelegate = self;
        _session = session;
    }
    [self commonInit];
    return self;
}

- (void)commonInit {
    //NSLog(@"%@",[AVUser currentUser].objectId);
    _appDelegate = [[UIApplication sharedApplication] delegate];
    [_session openWithPeerId:[AVUser currentUser].objectId];
    _context = _appDelegate.document.managedObjectContext;
    initialized = YES;
}

- (void)addWatchPeerId:(NSString *)peerId andSetCurFriend:(Friends *)friend{
    //先判断是否peerId已经重复 每次都重新设置friend
    NSArray *array = [[NSArray alloc] initWithObjects:peerId, nil];
    NSLog(@"!!!!!%@!!!!%@", array, peerId);
    [_session watchPeerIds:array];
    _chatFriendCurrent = friend;
}

- (void)sendNotifyMsgWithDictionary:(NSMutableDictionary *)dict toPeerId:(NSString *)peerId {
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    if (!error) {
        NSString *payload = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        AVMessage *messageObject = [AVMessage messageForPeerWithSession:_session toPeerId:peerId payload:payload];
        [_session sendMessage:messageObject transient:NO];
    }
}
////
- (void)sendMessage:(NSString *)message toPeerId:(NSString *)peerId {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:_session.peerId forKey:@"fromId"];
    [dict setObject:@"text" forKey:@"type"];
    [dict setObject:message forKey:@"msg"];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString *payload = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    AVMessage *messageObject = [AVMessage messageForPeerWithSession:_session toPeerId:peerId payload:payload];
    [_session sendMessage:messageObject transient:NO];
    //[_session sendMessage:messageObject];
}

- (void)sessionOpened:(AVSession *)session {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"session:%@", session.peerId);
}

- (void)sessionPaused:(AVSession *)session {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"session:%@", session.peerId);
}

- (void)sessionResumed:(AVSession *)session {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"session:%@", session.peerId);
}

- (void)session:(AVSession *)session didReceiveMessage:(AVMessage *)message {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    //NSLog(@"session:%@ message:%@ fromPeerId:%@", session.peerId, message, message.fromPeerId);
    //存一个当前聊天用户 判断消息是否是当前用户发送的  不是的话 就存入数据库
    if ([message.fromPeerId isEqualToString:self.chatFriendCurrent.id]) {
        NSLog(@"message:%@", message);
        //发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"readMsg" object:message];
    } else {
        //需要查下数据库是否存在这个好友
        //不存在则需要入库
        NSError *error = nil;
        NSData *data = [message.payload dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (![Friends isFriendExistWithId:message.fromPeerId inManagedObjectContext:_context]) {
            [NotifyMsg addMsgWithDictionary:dict inManagedObjectContext:_context];
            [Friends addFriendWithAccount:[dict objectForKey:@"fromName"] andId:message.fromPeerId inManagedObjectContext:_context];
        } else {
            [NotifyMsg addMsgWithDictionary:dict inManagedObjectContext:_context];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTableView" object:nil];
    }
}

- (void)session:(AVSession *)session messageSendFailed:(AVMessage *)message error:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"session:%@ message:%@ toPeerId:%@ error:%@", session.peerId, message, message.toPeerId, error);
}

- (void)session:(AVSession *)session messageSendFinished:(AVMessage *)message {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"session:%@ message:%@ toPeerId:%@", session.peerId, message, message.toPeerId);
}

- (void)session:(AVSession *)session didReceiveStatus:(AVPeerStatus)status peerIds:(NSArray *)peerIds {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"session:%@ peerIds:%@ status:%@", session.peerId, peerIds, status==AVPeerStatusOffline?@"offline":@"online");
}

- (void)sessionFailed:(AVSession *)session error:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"session:%@ error:%@", session.peerId, error);
}

@end
