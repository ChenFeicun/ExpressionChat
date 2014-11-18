//
//  ResourceManager.m
//  ExpressionChat
//
//  Created by Feicun on 14/11/1.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import "ResourceManager.h"
#import "EmojiSoundCell.h"

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
        _emojiArray = [self emojiSoundInfo];
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

- (NSMutableArray *)emojiSoundInfo {
    NSDictionary *dict = [self readEmojiInfo];
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[dict count]];
    for (int i = 0; i < [dict count]; i++) {
        NSDictionary *dic = [dict objectForKey:[NSString stringWithFormat:@"%02i", i + 1]];
        Emoji *emj = [[Emoji alloc] initWithEmojiName:[dic objectForKey:@"name"]];
        [array addObject:emj];
    }
    return array;
}

- (void)removeSoundFile {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error;
    //应该可以清理整个文件夹？
    for (Emoji *emj in _emojiArray) {
        if (emj.isRecord) {
            if ([manager fileExistsAtPath:[emj.soundURL path]]) {
                [manager removeItemAtURL:emj.soundURL error:&error];
            }
        }
    }
    _emojiArray = [self emojiSoundInfo];
}

@end
