//
//  Friends+Methods.h
//  ExpressionChat
//
//  Created by Feicun on 14/10/28.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import "Friends.h"

@class AVObject;

@interface Friends (Methods)

+ (Friends *)isFriendExistInDB:(NSString *)username inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Friends *)isFriendExistWithId:(NSString *)id inManagedObjectContext:(NSManagedObjectContext *)context;
//+ (void)addFriend:(AVObject *)userObj inManagedObjectContext:(NSManagedObjectContext *)context;
//云端同步
+ (void)addFriendToCloud:(Friends *)friend;
+ (void)addFriendLocalAndCloud:(AVObject *)userObj inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)addFriendLocalAndCloud:(NSString *)friendId friendName:(NSString *)friendName inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)addFriendsFromCloud:(NSArray *)userObjs inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)addFriendWithUsername:(NSString *)username andId:(NSString *)id andTime:(int64_t)time andUnread:(BOOL)unread inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)deleteCloudFriend:(NSString *)delId;
+ (void)deleteFriendLocalAndCloud:(Friends *)delFriend inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSMutableArray *)allFriendsInManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)deleteAllFriends:(NSManagedObjectContext *)context;
+ (void)updateFriend:(Friends *)friend time:(int64_t)time unread:(BOOL)unread  inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)updateUnreadByName:(NSString *)username inManagedObjectContext:(NSManagedObjectContext *)context;
@end
