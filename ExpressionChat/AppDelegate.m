//
//  AppDelegate.m
//  ExpressionChat
//
//  Created by Feicun on 14-10-8.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "ViewController.h"
#import "ResourceManager.h"
#import <AVOSCloud/AVOSCloud.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)initDocument {
    
    [ResourceManager sharedInstance];
    
    NSLog(@"initDocument !!!!!!");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory
                                                     inDomains:NSUserDomainMask] firstObject];
    NSString *documentName = @"FriendsDocument";
    NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentName];
    self.document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [self.document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"docInitSuccess" object:@"YES"];
                //NSLog(@"Document open success");
            } else
                NSLog(@"couldn’t open document at %@", url);
        }];
    } else {
        [self.document saveToURL:url forSaveOperation:UIDocumentSaveForCreating
               completionHandler:^(BOOL success) {
            if (success) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"docInitSuccess" object:@"YES"];
                //NSLog(@"Document open success");
            } else
                NSLog(@"couldn’t create document at %@", url);
        }];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self initDocument];
    [AVOSCloud setApplicationId:@"v2a4kgkyvnsmjkj0kf6e73w8rve32gxx4cttl8ob7dss0ikb"
                      clientKey:@"v2o8ffr9ou10wqzk96hslcd3vmcqpv2huxv0qkeqef4rgfro"];
    
    //图标上的数字 通过推送推过来的 需要在服务器端做增加
    
    //推送过来的消息在这里 应用未启动
    if (launchOptions) {
        NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
        if (badge) {
            NSLog(@"%li", (long)badge);
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        }
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    } else {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];

    }
    
    return YES;
}

//接收远程消息 应用处于打开状态
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"didReceiveRemoteNotification");
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.userInfo = userInfo;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.alertBody = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    localNotification.fireDate = [NSDate date];
    localNotification.applicationIconBadgeNumber++;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}


//注册成功
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Receive DeviceToken: %@", deviceToken);
    AVInstallation *curInstallation = [AVInstallation currentInstallation];
    [curInstallation setDeviceTokenFromData:deviceToken];
    [curInstallation saveInBackground];
}
//注册失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed!!!!!!!!!!!!!!!!! %@", error.description);
}

#pragma mark - 应用的生命周期
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:[UIApplication sharedApplication].applicationIconBadgeNumber++];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
