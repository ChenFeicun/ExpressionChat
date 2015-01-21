//
//  TTSManager.h
//  BDSSpeechSynthesizerSample
//
//  Created by 邢瑞峰 on 14/12/18.
//  Copyright (c) 2014年 百度. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import "BDSSpeechSynthesizer.h"
#import "BDSSpeechSynthesizerDelegate.h"

@interface TTSManager : NSObject <BDSSpeechSynthesizerDelegate>
@property (nonatomic, retain) BDSSpeechSynthesizer *synthesizer;
+ (instancetype)sharedInstance;
+ (instancetype)newInstance;
- (void)speak:(NSString *)speakString;
- (void)synthesize:(NSString *)speakString;
- (void)setParams;
@end
