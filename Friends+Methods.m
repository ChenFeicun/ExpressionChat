//
//  Friends+Methods.m
//  ExpressionChat
//
//  Created by Feicun on 14/10/28.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import "Friends+Methods.h"
#import <AVOSCloud/AVOSCloud.h>

@implementation Friends (Methods)

+ (Friends *)isFriendExistInDB:(NSString *)username inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Friends"];
    request.predicate = [NSPredicate predicateWithFormat:@"username = %@", username];
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if ([array count]) {
        return [array firstObject];
    } else {
        return nil;
    }
}

+ (Friends *)isFriendExistWithId:(NSString *)id inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Friends"];
    request.predicate = [NSPredicate predicateWithFormat:@"id = %@", id];
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if ([array count]) {
        return [array firstObject];
    } else {
        return nil;
    }
}

+ (void)addFriendToCloud:(Friends *)friend {
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSNumber *timestamp = [NSNumber numberWithLongLong:(long long)(time * 1000)];
    [[NSUserDefaults standardUserDefaults] setObject:timestamp forKey:@"LocalTimestamp"];
    AVRelation *relation = [[AVUser currentUser] relationforKey:@"friends"];
    AVObject *fri = [AVObject objectWithClassName:@"Friend"];
    [fri setObject:[AVUser currentUser].objectId forKey:@"ownerId"];
    [fri setObject:friend.id forKey:@"friendId"];
    [fri setObject:friend.username forKey:@"friendName"];
    [fri saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded && !error) {
            [relation addObject:fri];
            //更新时间戳
            [[AVUser currentUser] setObject:timestamp forKey:@"timestamp"];
            [[AVUser currentUser] saveInBackground];
        }
    }];
}

+ (void)addFriendLocalAndCloud:(NSString *)friendId friendName:(NSString *)friendName inManagedObjectContext:(NSManagedObjectContext *)context {
    Friends *friend = [NSEntityDescription insertNewObjectForEntityForName:@"Friends" inManagedObjectContext:context];
    friend.id = friendId;
    friend.username = friendName;
    if ([context save:nil]) {
        [self addFriendToCloud:friend];
    } else {
        NSLog(@"add failed");
    }
}

+ (void)addFriendLocalAndCloud:(AVObject *)userObj inManagedObjectContext:(NSManagedObjectContext *)context {
    [self addFriendLocalAndCloud:[userObj objectForKey:@"objectId"] friendName:[userObj objectForKey:@"username"] inManagedObjectContext:context];
}

+ (void)addFriend:(AVObject *)userObj inManagedObjectContext:(NSManagedObjectContext *)context {
    Friends *friend = [NSEntityDescription insertNewObjectForEntityForName:@"Friends" inManagedObjectContext:context];
    friend.id = [userObj objectForKey:@"objectId"];
    friend.username = [userObj objectForKey:@"username"];
    if ([context save:nil]) {
        NSLog(@"add successd");
    } else {
        NSLog(@"add failed");
    }
}

+ (void)addFriendsFromCloud:(NSArray *)userObjs inManagedObjectContext:(NSManagedObjectContext *)context {
    for (AVUser *userObj in userObjs) {
        Friends *findfriend = [self isFriendExistWithId:[userObj objectForKey:@"friendId"] inManagedObjectContext:context];
        if (!findfriend) {
            Friends *friend = [NSEntityDescription insertNewObjectForEntityForName:@"Friends" inManagedObjectContext:context];
            friend.id = [userObj objectForKey:@"friendId"];
            friend.username = [userObj objectForKey:@"friendName"];
            if ([context save:nil]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"addCloudFriend" object:nil];
                NSLog(@"add successd");
            } else {
                NSLog(@"add failed");
            }
        }
    }
}

+ (void)addFriendWithUsername:(NSString *)username andId:(NSString *)objid andTime:(int64_t)time andUnread:(BOOL)unread inManagedObjectContext:(NSManagedObjectContext *)context {
    Friends *friend = [NSEntityDescription insertNewObjectForEntityForName:@"Friends" inManagedObjectContext:context];
    friend.username = username;
    friend.id = objid;
    friend.unread = [NSNumber numberWithBool:unread];
    friend.time = [NSNumber numberWithLongLong:time];
    if ([context save:nil]) {
        if (![username isEqualToString:@"Biu"])
            [self addFriendToCloud:friend];
        NSLog(@"save friend successed");
    } else {
        NSLog(@"save friend failed");
        //NSLog(@"add message failed");
    }

}

+ (void)deleteCloudFriend:(NSString *)delId {
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSNumber *timestamp = [NSNumber numberWithLongLong:(long long)(time * 1000)];
    [[NSUserDefaults standardUserDefaults] setObject:timestamp forKey:@"LocalTimestamp"];
    AVRelation *relation = [[AVUser currentUser] relationforKey:@"friends"];
    AVQuery *friendQuery = [relation query];
    [friendQuery whereKey:@"ownerId" equalTo:[AVUser currentUser].objectId];
    [friendQuery whereKey:@"friendId" equalTo:delId];
    [friendQuery getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        if (object && !error) {
            [relation removeObject:object];
            //更新时间戳
            [[AVUser currentUser] setObject:timestamp forKey:@"timestamp"];
            [[AVUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded && !error) {
                    [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        //donothing
                    }];
                }
            }];
        }
    }];
}

+ (void)deleteFriendLocalAndCloud:(Friends *)delFriend inManagedObjectContext:(NSManagedObjectContext *)context {
    NSString *delId = delFriend.id;
    [context deleteObject:delFriend];
    if ([context save:nil]) {
        [self deleteCloudFriend:delId];
    } else {
        NSLog(@"delete failed");
    }
}

+ (NSMutableArray *)allFriendsInManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *all = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Friends"];
    //排序！！！
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES selector:@selector(localizedStandardCompare:)]];
    request.predicate = nil;
    
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (!error) {
        all = [[NSMutableArray alloc] initWithArray:array];
        //return self.all;
    } else
        NSLog(@"%@", error);
    return all;
}

+ (void)deleteAllFriends:(NSManagedObjectContext *)context {
    NSMutableArray *array = [self allFriendsInManagedObjectContext:context];
    if (array) {
        for (Friends *friend in array) {
            [context deleteObject:friend];
        }
        if ([context save:nil]) {
            NSLog(@"delete all successd");
        } else {
            NSLog(@"delete all failed");
        }
    }
}

+ (void)updateFriend:(Friends *)friend time:(int64_t)time unread:(BOOL)unread  inManagedObjectContext:(NSManagedObjectContext *)context {
    //NSLog(@"time: %@", friend.time);
    friend.time = [NSNumber numberWithLongLong:time];
    friend.unread = [NSNumber numberWithBool:unread];
    //NSLog(@"%@", friend.time);
    if ([context save:nil]) {
        NSLog(@"update successd");
    } else {
        NSLog(@"update failed");
    }
}

+ (void)updateUnreadByName:(NSString *)username inManagedObjectContext:(NSManagedObjectContext *)context {
    Friends *friend = [self isFriendExistInDB:username inManagedObjectContext:context];
    friend.unread = [NSNumber numberWithBool:NO];
    NSLog(@"%@", friend.unread);
    if ([context save:nil]) {
        NSLog(@"update successd");
    } else {
        NSLog(@"update failed");
    }
}

@end
