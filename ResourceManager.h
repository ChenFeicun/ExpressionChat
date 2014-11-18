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
- (void)removeSoundFile;
//- (SystemSoundID)getSoundIdByVoicePath:(NSString *)content;
//- (void)createSystemSoundID;

@end
