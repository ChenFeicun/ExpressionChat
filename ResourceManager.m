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
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory
                                                         inDomains:NSUserDomainMask] firstObject];
        NSURL *url = [documentsDirectory URLByAppendingPathComponent:@"audio"];
        [fileManager createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:nil];
        NSURL *emojiUrl = [documentsDirectory URLByAppendingPathComponent:@"Emoji.plist"];
        if (![fileManager fileExistsAtPath:[emojiUrl path]]) {
            NSMutableDictionary *rootDict = [[NSMutableDictionary alloc] initWithCapacity:FACE_COUNT_ALL];
            for (int i = 0; i < FACE_COUNT_ALL; i++) {
                NSString *indexStr = [NSString stringWithFormat:@"%02d", i + 1];
                NSMutableDictionary *indexDict = [[NSMutableDictionary alloc] init];
                [indexDict setObject:[NSString stringWithFormat:@"emoji_%@", indexStr] forKey:@"name"];
                [indexDict setObject:[NSString stringWithFormat:@"emoji_%@", indexStr] forKey:@"resid"];
                if (i == 0) {
                    [indexDict setObject:@"你好" forKey:@"ttsstring"];
                } else if (i == 1) {
                    [indexDict setObject:@"笑尿了" forKey:@"ttsstring"];
                } else if (i == 7) {
                    [indexDict setObject:@"心塞" forKey:@"ttsstring"];
                } else if (i == 8) {
                    [indexDict setObject:@"摸摸答" forKey:@"ttsstring"];
                } else {
                    [indexDict setObject:@"" forKey:@"ttsstring"];
                }
                [rootDict setObject:indexDict forKey:indexStr];
            }
            [rootDict writeToFile:[emojiUrl path] atomically:YES];
        }
        _emojiArray = [self emojiSoundInfo];
    }
    return self;
}

- (NSDictionary *)readEmojiInfo {
    //加载plist
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory
                                                     inDomains:NSUserDomainMask] firstObject];
    NSString *plistPath = [[documentsDirectory URLByAppendingPathComponent:@"Emoji.plist"] path];//[[NSBundle mainBundle] pathForResource:@"Emoji" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    return dict;
}

- (NSMutableArray *)emojiSoundInfo {
    NSDictionary *dict = [self readEmojiInfo];
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[dict count]];
    for (int i = 0; i < [dict count]; i++) {
        NSDictionary *dic = [dict objectForKey:[NSString stringWithFormat:@"%02i", i + 1]];
        Emoji *emj = [[Emoji alloc] initWithEmojiName:[dic objectForKey:@"name"]];
        emj.ttsString = [dic objectForKey:@"ttsstring"];
        NSURL *url = [self searchSoundFile:emj.emojiName];
        if (url) {
            NSData *data = [NSData dataWithContentsOfFile:[url path]];//[NSData dataWithContentsOfURL:url];
            emj.soundURL = url;
            emj.isRecord = YES;
            emj.emojiData = data;
        }
        [array addObject:emj];
    }
    return array;
}
//预置语音
- (void)presetEmojiSound {
    
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

- (NSURL *)searchSoundFile:(NSString *)emojiName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory
                                                     inDomains:NSUserDomainMask] firstObject];
    NSURL *url = [documentsDirectory URLByAppendingPathComponent:[@"audio" stringByAppendingPathComponent:[emojiName stringByAppendingString:@".amr"]]];
    NSURL *mp3Url = [documentsDirectory URLByAppendingPathComponent:[@"audio" stringByAppendingPathComponent:[emojiName stringByAppendingString:@".mp3"]]];
    
    NSString *str = [[NSBundle mainBundle] pathForResource:emojiName ofType:@"mp3"];
    NSURL *presetUrl = [NSURL URLWithString:str];
    if ([fileManager fileExistsAtPath:[url path]]) {
        return url;
    } else if ([fileManager fileExistsAtPath:[mp3Url path]]) {
        return mp3Url;
    } else if ([fileManager fileExistsAtPath:str]) {
        return presetUrl;
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

- (void)saveEmojiTTSString:(Emoji *)tempEmoji {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory
                                                     inDomains:NSUserDomainMask] firstObject];
    NSString *plistPath = [[documentsDirectory URLByAppendingPathComponent:@"Emoji.plist"] path];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[NSDictionary dictionaryWithContentsOfFile:plistPath]];
    
    NSMutableDictionary *emojiDict = [dict objectForKey:[tempEmoji.emojiName substringFromIndex:[tempEmoji.emojiName length] - 2]];
    [emojiDict setObject:tempEmoji.ttsString forKey:@"ttsstring"];
    [dict writeToFile:plistPath atomically:YES];
}

@end
