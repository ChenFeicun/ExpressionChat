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
//#import "BiuSessionManager.h"
#import <AVOSCloud/AVOSCloud.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)initDocument {
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
    //ViewController *cv = [[ViewController alloc] init];
    //UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cv];
    //self.window.rootViewController = cv;

    [self initDocument];
    [AVOSCloud setApplicationId:@"v2a4kgkyvnsmjkj0kf6e73w8rve32gxx4cttl8ob7dss0ikb"
                      clientKey:@"v2o8ffr9ou10wqzk96hslcd3vmcqpv2huxv0qkeqef4rgfro"];
    
    //AVInstallation *installation = [AVInstallation alloc]in
    //不能在这初始化 因为不一定有AVUSer
    //[BiuSessionManager sharedInstance];
    //在这里判断是否需要注册
    //AVUser *user = [AVUser currentUser];
    
       return YES;
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
}

/*
- (void)toLogin {
    
}

- (void)toMain {
    MainViewController *cv = [[MainViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cv];
    self.window.rootViewController = nav;
    
    //self.window.rootViewController = controller;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    CDBaseTabBarController *tab = [[CDBaseTabBarController alloc] init];
    
    CDBaseController *controller = [[CDChatListController alloc] init];
    CDBaseNavigationController *nav = [[CDBaseNavigationController alloc] initWithRootViewController:controller];
    [tab addChildViewController:nav];
    
    controller = [[CDContactListController alloc] init];
    nav = [[CDBaseNavigationController alloc] initWithRootViewController:controller];
    [tab addChildViewController:nav];
    
    controller = [[CDProfileController alloc] init];
    nav = [[CDBaseNavigationController alloc] initWithRootViewController:controller];
    [tab addChildViewController:nav];
    
    self.window.rootViewController = tab;
     
}
*/

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
