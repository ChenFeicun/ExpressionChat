//
//  ResourceManager.m
//  ExpressionChat
//
//  Created by Feicun on 14/11/1.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import "ResourceManager.h"
#import "EmojiBoardView.h"

@interface ResourceManager()

//@property (strong, nonatomic) NSMutableDictionary *soundDict;

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
        //_soundDict = [[NSMutableDictionary alloc] init];
        _emojiArray = [self emojiSoundInfo];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory
                                                         inDomains:NSUserDomainMask] firstObject];
        NSURL *url = [documentsDirectory URLByAppendingPathComponent:@"audio"];
        [fileManager createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return self;
}

- (NSDictionary *)readEmojiInfo {
    //加载plist
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Emoji" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    return dict;
}

//- (NSDictionary *)readVoiceInfo {
//    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Voice" ofType:@"plist"];
//    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
//    return dict;
//}

- (NSMutableArray *)emojiSoundInfo {
    NSDictionary *dict = [self readEmojiInfo];
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[dict count]];
    for (int i = 0; i < [dict count]; i++) {
        NSDictionary *dic = [dict objectForKey:[NSString stringWithFormat:@"%02i", i + 1]];
        Emoji *emj = [[Emoji alloc] initWithEmojiName:[dic objectForKey:@"name"]];
        NSURL *url = [self searchAmrFile:emj.emojiName];
        if (url) {
            NSData *data = [NSData dataWithContentsOfURL:url];
            emj.soundURL = url;
            emj.isRecord = YES;
            emj.emojiData = data;
        }
        [array addObject:emj];
    }
    return array;
}

- (void)removeAllSoundFile {
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

- (void)removeSoundFileByUrl:(NSURL *)url {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error;
    if ([manager fileExistsAtPath:[url path]]) {
        [manager removeItemAtURL:url error:&error];
    }
}

- (void)removeSoundFileByIndex:(NSInteger)Index {
    Emoji *emj = [self.emojiArray objectAtIndex:Index];
    [self removeSoundFileByUrl:emj.soundURL];
    emj.isRecord = NO;
    emj.soundURL = nil;
}

- (NSURL *)searchAmrFile:(NSString *)emojiName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory
                                                     inDomains:NSUserDomainMask] firstObject];
    NSURL *url = [documentsDirectory URLByAppendingPathComponent:[@"audio" stringByAppendingPathComponent:[emojiName stringByAppendingString:@".amr"]]];
    if ([fileManager fileExistsAtPath:[url path]]) {
        return url;
    }
    return nil;
}

- (NSURL *)dataWriteToFile:(NSString *)emojiName withData:(NSData *)data {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory
                                                     inDomains:NSUserDomainMask] firstObject];
    NSURL *url = [[documentsDirectory URLByAppendingPathComponent:@"audio"] URLByAppendingPathComponent:[emojiName stringByAppendingString:@".amr"]];
    [data writeToURL:url atomically:YES];
    return url;
}
- (NSURL *)dataWriteToFileMp3:(NSString *)emojiName withData:(NSData *)data {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory
                                                     inDomains:NSUserDomainMask] firstObject];
    NSURL *url = [[documentsDirectory URLByAppendingPathComponent:@"audio"] URLByAppendingPathComponent:[emojiName stringByAppendingString:@".mp3"]];
    [data writeToURL:url atomically:YES];
    return url;
}

@end
