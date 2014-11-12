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

+ (Friends *)isFriendExistInDB:(NSString *)account inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Friends *)isFriendExistWithId:(NSString *)id inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)addFriend:(AVObject *)userObj inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)addFriendWithAccount:(NSString *)account andId:(NSString *)id inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)deleteFriend:(Friends *)delFriend inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSMutableArray *)allFriendsInManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)deleteAllFriends:(NSManagedObjectContext *)context;

@end
