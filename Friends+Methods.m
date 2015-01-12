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

+ (void)addFriendWithUsername:(NSString *)username andId:(NSString *)id andTime:(int64_t)time andUnread:(BOOL)unread inManagedObjectContext:(NSManagedObjectContext *)context {
    Friends *friend = [NSEntityDescription insertNewObjectForEntityForName:@"Friends" inManagedObjectContext:context];
    friend.username = username;
    friend.id = id;
    friend.unread = [NSNumber numberWithBool:unread];
    friend.time = [NSNumber numberWithLongLong:time];
    if ([context save:nil]) {
        NSLog(@"save friend successed");
    } else {
        NSLog(@"save friend failed");
        //NSLog(@"add message failed");
    }

}

+ (void)deleteFriend:(Friends *)delFriend inManagedObjectContext:(NSManagedObjectContext *)context {
    [context deleteObject:delFriend];
    if ([context save:nil]) {
        NSLog(@"delete successd");
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
    //NSLog(@"%@", friend.time);
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
