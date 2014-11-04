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
- (NSDictionary *)readEmojiInfo;
- (NSDictionary *)readVoiceInfo;
- (SystemSoundID)getSoundIdByVoicePath:(NSString *)content;
- (void)createSystemSoundID;

@end
