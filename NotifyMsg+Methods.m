//
//  NotifyMsg+Methods.m
//  ExpressionChat
//
//  Created by Feicun on 14/10/28.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import "NotifyMsg+Methods.h"
#import "Friends.h"

@implementation NotifyMsg (Methods)

+ (NSUInteger)getOfflineMsgCount:(Friends *)friend inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"NotifyMsg"];
    request.predicate = [NSPredicate predicateWithFormat:@"fromid = %@", friend.id];
    NSError *error;
    NSUInteger count = [context countForFetchRequest:request error:&error];
    return count;
}

+ (NSArray *)recentlyOfflineMsg:(Friends *)friend inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"NotifyMsg"];
    request.predicate = [NSPredicate predicateWithFormat:@"fromid = %@", friend.id];
    request.fetchLimit = 5;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO]];
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (!error && array) {
        return array;
    } else {
        return nil;
    }
}

+ (NSArray *)getOfflineMsg:(Friends *)friend inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"NotifyMsg"];
    request.predicate = [NSPredicate predicateWithFormat:@"fromid = %@", friend.id];
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (!error && array) {
        return array;
    } else {
        return nil;
    }
}

+ (void)addMsgWithDictionary:(NSDictionary *)dict andPeerId:(NSString *)peerId andTime:(int64_t)time inManagedObjectContext:(NSManagedObjectContext *)context {
    NotifyMsg *msg = [NSEntityDescription insertNewObjectForEntityForName:@"NotifyMsg" inManagedObjectContext:context];
    msg.fromid = peerId;
    msg.resname = [dict objectForKey:@"resName"];
    NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
    msg.xratio = [NSString stringWithFormat:@"%@", [dict objectForKey:@"resXRatio"]];
    msg.type = [numFormatter stringFromNumber:[dict objectForKey:@"type"]];
    msg.time = [NSNumber numberWithLongLong:time];
    if ([msg.type integerValue] == 1) {
        msg.audiourl = [dict objectForKey:@"audioUrl"];
        msg.audioname = [dict objectForKey:@"audioName"];
        msg.audioid = [dict objectForKey:@"audioID"];
    }
    
    if ([context save:nil]) {
        NSLog(@"msg%@ : %@", msg.fromid, msg.resname);
    } else {
        NSLog(@"add message failed");
    }
}

+ (void)deleteFriendMsg:(Friends *)friend inManagedObjectContext:(NSManagedObjectContext *)context {
    NSArray *array = [self getOfflineMsg:friend inManagedObjectContext:context];
    if (array) {
        for (NotifyMsg *msg in array) {
            [context deleteObject:msg];
        }
        if ([context save:nil]) {
            NSLog(@"delete friend`s msg successd");
        } else {
            NSLog(@"delete friend`s msg failed");
        }
    }
}

+ (void)deleteAllMsg:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"NotifyMsg"];
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (!error && array) {
        for (NotifyMsg *msg in array) {
            [context deleteObject:msg];
        }
        if ([context save:nil]) {
            NSLog(@"delete all successd");
        } else {
            NSLog(@"delete all failed");
        }
    }
}

@end
