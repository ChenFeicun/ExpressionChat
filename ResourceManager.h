//
//  ResourceManager.h
//  ExpressionChat
//
//  Created by Feicun on 14/11/1.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
@class Emoji;
@interface ResourceManager : NSObject

+ (instancetype)sharedInstance;
@property (nonatomic, strong) NSMutableArray *emojiArray;
- (NSDictionary *)readEmojiInfo;
- (NSMutableArray *)emojiSoundInfo;
- (void)removeAllSoundFile;
- (void)removeSoundFileByIndex:(NSInteger)Index;
- (void)removeSoundFileByUrl:(NSURL *)url;
- (NSURL *)dataWriteToFile:(NSString *)emojiName withData:(NSData *)data;
- (NSURL *)dataWriteToFileMp3:(NSString *)emojiName withData:(NSData *)data;
- (void)saveEmojiTTSString:(Emoji *)tempEmoji;
//- (SystemSoundID)getSoundIdByVoicePath:(NSString *)content;
//- (void)createSystemSoundID;

@end
