//
//  MainViewController.h
//  ExpressionChat
//
//  Created by Feicun on 14-10-8.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JZSwipeCell.h"
//#import "ChatViewController.h"

@class Friends;
@class AVUser;

@interface MainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, JZSwipeCellDelegate>
@property (strong, nonatomic) AVUser *curUser;
@end
