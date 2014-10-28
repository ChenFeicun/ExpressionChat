//
//  ChatViewController.h
//  ExpressionChat
//
//  Created by Feicun on 14-10-10.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Friends;

//@protocol ChatWithFriend <NSObject>
//
//- (void)setFriendChatWith:(Friends *)friend;
//
//@end

@interface ChatViewController : UIViewController
@property (strong, nonatomic) Friends *chatFriend;
//@property (nonatomic, weak) id<ChatWithFriend> delegate;
@end
