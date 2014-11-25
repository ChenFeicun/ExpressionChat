//
//  EmojiViewController.h
//  ExpressionChat
//
//  Created by Feicun on 14-10-15.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmojiBoardView.h"

@class Friends;

@interface EmojiViewController : UIViewController <UIDynamicAnimatorDelegate, EmojiCellDelegate>
@property (strong, nonatomic) Friends *chatFriend;
@end
