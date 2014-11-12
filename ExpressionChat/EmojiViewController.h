//
//  EmojiViewController.h
//  ExpressionChat
//
//  Created by Feicun on 14-10-15.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmojiSoundCell.h"

@class Friends;

@interface EmojiViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIDynamicAnimatorDelegate, EmojiSoundCellDelegate>
@property (strong, nonatomic) Friends *chatFriend;
@end
