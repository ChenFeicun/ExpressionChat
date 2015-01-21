//
//  TTSManager.m
//  BDSSpeechSynthesizerSample
//
//  Created by 邢瑞峰 on 14/12/18.
//  Copyright (c) 2014年 百度. All rights reserved.
//

#import "TTSManager.h"

static id instance = nil;

@implementation TTSManager
+ (instancetype)sharedInstance {
    //dispatch_once_t 一般用来写单例
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    //$(inherited) $(PROJECT_DIR)/ExpressionChat $(PROJECT_DIR) /Users/XRF/Downloads/Baidu-TTS-SDK-iOS-1.1.0/BDSSpeechSynthesizer_DevPack
    return instance;
}

+ (instancetype)newInstance {
    return [[self alloc] init];
}

- (instancetype)init {
    
    if (self = [super init]) {
        self.synthesizer = [[BDSSpeechSynthesizer alloc] initSynthesizer:@"holder" delegate:self];
        [self setParams];
    }
    return self;
}

- (void)speak:(NSString *)speakString
{
    if (![speakString  isEqual: @""]) {
        int ret = [self.synthesizer speak:speakString];
        if (ret != 0) {
            //output ret
            NSLog(@"%i", ret);
        }
    }
}

- (void)synthesize:(NSString *)speakString
{
    if (![speakString  isEqual: @""]) {
        int ret = [self.synthesizer synthesize:speakString];
        if (ret != 0) {
            //output ret
            NSLog(@"%i", ret);
        }
    }
}

- (void)setParams
{
    // 此处需要将setApiKey:withSecretKey:方法的两个参数替换为你在百度开发者中心注册应用所得到的apiKey和secretKey
    [self.synthesizer setApiKey:@"OxeD4aBHm99FTSV3mfxNjMGy" withSecretKey:@"rGDdRSHeL7hAPjsQiTGXo1khi74q4woE"];
    [self.synthesizer setParamForKey:BDS_PARAM_TEXT_ENCODE value:BDS_TEXT_ENCODE_UTF8];
    [self.synthesizer setParamForKey:BDS_PARAM_SPEAKER value:BDS_SPEAKER_FEMALE];
    [self.synthesizer setParamForKey:BDS_PARAM_VOLUME value:@"9"];
    [self.synthesizer setParamForKey:BDS_PARAM_SPEED value:@"5"];
    [self.synthesizer setParamForKey:BDS_PARAM_PITCH value:@"5"];
    [self.synthesizer setParamForKey:BDS_PARAM_AUDIO_ENCODE value:BDS_AUDIO_ENCODE_MP3];
    [self.synthesizer setParamForKey:BDS_PARAM_AUDIO_RATE value:BDS_AUDIO_BITRATE_MP3_24K];
    //[self.synthesizer setAudioSessionCategory:AVAudioSessionCategoryPlayback];
}
- (void)synthesizerNewDataArrived:(BDSSpeechSynthesizer *)speechSynthesizer data:(NSData *)newData isLastData:(BOOL)lastDataFlag
{
    NSLog(@"123");
    
}
@end
