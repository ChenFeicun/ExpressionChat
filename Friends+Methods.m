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

+ (Friends *)isFriendExistInDB:(NSString *)account inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Friends"];
    request.predicate = [NSPredicate predicateWithFormat:@"account = %@", account];
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
    friend.account = [userObj objectForKey:@"username"];
    if ([context save:nil]) {
        NSLog(@"add successd");
    } else {
        NSLog(@"add failed");
    }
}

+ (void)addFriendWithAccount:(NSString *)account andId:(NSString *)id inManagedObjectContext:(NSManagedObjectContext *)context {
    Friends *friend = [NSEntityDescription insertNewObjectForEntityForName:@"Friends" inManagedObjectContext:context];
    friend.account = account;
    friend.id = id;
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

@end
