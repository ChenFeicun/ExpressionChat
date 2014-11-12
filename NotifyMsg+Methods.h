//
//  NotifyMsg+Methods.h
//  ExpressionChat
//
//  Created by Feicun on 14/10/28.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import "NotifyMsg.h"

@class Friends;

@interface NotifyMsg (Methods)

+ (NSUInteger)getOfflineMsgCount:(Friends *)friend inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)recentlyOfflineMsg:(Friends *)friend inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)getOfflineMsg:(Friends *)friend inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)addMsgWithDictionary:(NSDictionary *)dict andTime:(int64_t)time inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)deleteFriendMsg:(Friends *)friend inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)deleteAllMsg:(NSManagedObjectContext *)context;

@end
