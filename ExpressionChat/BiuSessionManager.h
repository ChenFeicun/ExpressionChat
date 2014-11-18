//
//  BiuSessionManager.h
//  ExpressionChat
//
//  Created by Feicun on 14-10-13.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>

@class Friends;

@interface BiuSessionManager : NSObject <AVSessionDelegate>
+ (instancetype)sharedInstance;
- (void)sendMessage:(NSString *)message toPeerId:(NSString *)peerId;
- (void)sendNotifyMsgWithDictionary:(NSMutableDictionary *)dict toPeerId:(NSString *)peerId;
- (void)addWatchPeerId:(NSString *)peerId andSetCurFriend:(Friends *)person;
@end
