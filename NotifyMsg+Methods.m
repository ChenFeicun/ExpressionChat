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

+ (NSArray *)getOfflineMsg:(Friends *)friend inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"NotifyMsg"];
    request.predicate = [NSPredicate predicateWithFormat:@"fromid = %@", friend.id];
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    return array;
}

+ (void)addMsgWithDictionary:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context {
    NotifyMsg *msg = [NSEntityDescription insertNewObjectForEntityForName:@"NotifyMsg" inManagedObjectContext:context];
    msg.fromid = [dict objectForKey:@"fromid"];
    msg.resid = [dict objectForKey:@"resid"];
    msg.xratio = [dict objectForKey:@"xratio"];
    msg.type = [dict objectForKey:@"type"];
    if ([context save:nil]) {
        NSLog(@"msg%@ : %@", msg.fromid, msg.resid);
    } else {
        NSLog(@"add message failed");
    }
}

@end
