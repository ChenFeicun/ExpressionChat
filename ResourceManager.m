//
//  ResourceManager.m
//  ExpressionChat
//
//  Created by Feicun on 14/11/1.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import "ResourceManager.h"

@interface ResourceManager()

@property (strong, nonatomic) NSMutableDictionary *soundDict;

@end

@implementation ResourceManager

static id instance = nil;
//static SystemSoundID shake_sound_male_id = 0;

+ (instancetype)sharedInstance {
    //dispatch_once_t 一般用来写单例
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _soundDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSDictionary *)readEmojiInfo {
    //加载plist
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Emoji" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    return dict;
}

- (NSDictionary *)readVoiceInfo {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Voice" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    return dict;
}

- (void)createSystemSoundID {
    NSDictionary *dictionary = [self readVoiceInfo];
    //NSLog(@"%li", [dictionary count]);
    for (int i = 0; i < [dictionary count]; i++) {
        NSString *str = [NSString stringWithFormat:@"%02i", i + 1];
        NSDictionary *dict = [dictionary objectForKey:str];
        //NSLog(@"%@", [dict objectForKey:@"name"]);
        NSString *path = [[NSBundle mainBundle] pathForResource:[dict objectForKey:@"path"] ofType:@"wav"];
        if (path) {
            //注册声音到系统
            //NSString *str = [NSString stringWithFormat:@"%02i", index];
            SystemSoundID soundID;
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
            //通过名字
            [_soundDict setObject:[NSString stringWithFormat:@"%i", (unsigned int)soundID] forKey:[dict objectForKey:@"path"]];
            //[_soundDict setObject:@"" forKey:str];
        }
    }
}

- (SystemSoundID)getSoundIdByVoicePath:(NSString *)path {
    return [[_soundDict objectForKey:path] intValue];
}
@end
