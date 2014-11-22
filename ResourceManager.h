//
//  ResourceManager.h
//  ExpressionChat
//
//  Created by Feicun on 14/11/1.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ResourceManager : NSObject

+ (instancetype)sharedInstance;
@property (nonatomic, strong) NSMutableArray *emojiArray;
- (NSDictionary *)readEmojiInfo;
- (NSDictionary *)readVoiceInfo;
- (NSMutableArray *)emojiSoundInfo;
- (void)removeAllSoundFile;
- (void)removeSoundFileByUrl:(NSURL *)url;
- (NSURL *)dataWriteToFile:(NSString *)emojiName withData:(NSData *)data;
//- (SystemSoundID)getSoundIdByVoicePath:(NSString *)content;
//- (void)createSystemSoundID;

@end
