//
//  RecordAudio.m
//  JuuJuu
//
//  Created by xiaoguang huang on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "RecordAudio.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "amrFileCodec.h"

@implementation RecordAudio


- (void)dealloc {
    [recorder dealloc];
	recorder = nil;
	recordedTmpFile = nil;
    [avPlayer stop];
    [avPlayer release];
    avPlayer = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        //Instanciate an instance of the AVAudioSession object.
        AVAudioSession * audioSession = [AVAudioSession sharedInstance];
        //Setup the audioSession for playback and record. 
        //We could just use record and then switch it to playback leter, but
        //since we are going to do both lets set it up once.
        //[audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: &error];
    
        //UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        //AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof (audioRouteOverride), &audioRouteOverride);
        //ovrd  spkr
        
        [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
        //Activate the session
        if (!error) {
            [audioSession setActive:YES error: &error];
        }
        
    }
    return self;
}

- (NSURL *) stopRecord {
    NSURL *url = [[NSURL alloc]initWithString:recorder.url.absoluteString];
    [recorder stop];
    [recorder release];
    recorder =nil;
    return [url autorelease];
}

+ (NSTimeInterval) getAudioTime:(NSData *) data {
    NSError * error;
    AVAudioPlayer*play = [[AVAudioPlayer alloc] initWithData:data error:&error];
    NSTimeInterval n = [play duration];
    [play release];
    return n;
}

//0 播放 1 播放完成 2出错
- (void)sendStatus:(int)status {
    
    if ([self.delegate respondsToSelector:@selector(recordStatus:)]) {
        [self.delegate recordStatus:status];
    }
    
    if (status!=0) {
        if (avPlayer!=nil) {
            if (![avPlayer isPlaying]) {
                [avPlayer stop];
                [avPlayer release];
                avPlayer = nil;
               // NSLog(@"结束播放!!!!!!!!");
            }
        }
    }
}

- (void)stopPlay {
    if (avPlayer!=nil) {
        [avPlayer stop];
        [avPlayer release];
        avPlayer = nil;
        [self sendStatus:1];
    }
}

- (NSData *)decodeAmr:(NSData *)data{
    if (!data) {
        return data;
    }

    return DecodeAMRToWAVE(data);
}

- (void)play:(NSData*) data{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
	//Setup the AVAudioPlayer to play the file that we just recorded.

    //NSLog(@"start decode");
    NSData *o = [self decodeAmr:data];
    //NSLog(@"end decode");
    avPlayer = [[AVAudioPlayer alloc] initWithData:o error:&error];
    avPlayer.delegate = self;
	[avPlayer prepareToPlay];
    [avPlayer setVolume:1.0];
	if(![avPlayer play]){
        [self sendStatus:1];
    } else {
        [self sendStatus:0];
    }
}

- (void)playMp3:(NSData*) data{
    //Setup the AVAudioPlayer to play the file that we just recorded.
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];

    avPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
    avPlayer.delegate = self;
    [avPlayer prepareToPlay];
    [avPlayer setVolume:1.0];
    if(![avPlayer play]){
        [self sendStatus:1];
    } else {
        [self sendStatus:0];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self sendStatus:1];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    [self sendStatus:2];
}

- (void) startRecord {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
    //Begin the recording session.
    //Error handling removed.  Please add to your own code.
    
    //Setup the dictionary object with all the recording settings that this 
    //Recording sessoin will use
    //Its not clear to me which of these are required and which are the bare minimum.
    //This is a good resource: http://www.totodotnet.net/tag/avaudiorecorder/
    //		NSMutableDictionary* recordSetting = [[NSMutableDictionary alloc] init];
    //		[recordSetting setValue :[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:AVFormatIDKey];
    //		[recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey]; 
    //		[recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
//    NSDictionary *recordSetting =
//    [[NSDictionary alloc] initWithObjectsAndKeys:
//     
//     [NSNumber numberWithFloat:8000.00], AVSampleRateKey,
//     
//     [NSNumber numberWithInt:kAudioFormatiLBC], AVFormatIDKey,
//     
//     [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
//     
//     [NSNumber numberWithInt:AVAudioQualityMax], AVEncoderAudioQualityKey,
//     
//     nil];
    
        NSDictionary *recordSetting = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey, 
                                       //[NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                       [NSNumber numberWithFloat:8000.00], AVSampleRateKey,
                                       [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                       //  [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)], AVChannelLayoutKey,
                                       [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                       [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                       [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                       [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                       nil];
    
    //Now that we have our settings we are going to instanciate an instance of our recorder instance.
    //Generate a temp file for use by the recording.
    //This sample was one I found online and seems to be a good choice for making a tmp file that
    //will not overwrite an existing one.
    //I know this is a mess of collapsed things into 1 call.  I can break it out if need be.
    recordedTmpFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"caf"]]];
    //NSLog(@"Using File called: %@",recordedTmpFile);

    
    //Setup the recorder to use this file and record to it.
    recorder = [[ AVAudioRecorder alloc] initWithURL:recordedTmpFile settings:recordSetting error:&error];
    //NSLog(@"1");
    //Use the recorder to start the recording.
    //Im not sure why we set the delegate to self yet.  
    //Found this in antother example, but Im fuzzy on this still.
    [recorder setDelegate:self];
    //We call this to start the recording process and initialize 
    //the subsstems so that when we actually say "record" it starts right away.
    [recorder prepareToRecord];
     //   NSLog(@"2");
    //Start the actual Recording
    recorder.meteringEnabled = YES;
    [recorder record];
     //   NSLog(@"3");
    //There is an optional method for doing the recording for a limited time see 
    //[recorder recordForDuration:(NSTimeInterval) 10]
}

- (float)getPeakPower {
    [recorder updateMeters];
    //发送updateMeters消息来刷新平均和峰值功率。此计数是以对数刻度计量的，-160表示完全安静，0表示最大输入值
    //float averagePower = [recorder averagePowerForChannel:0];
    float peakPower = [recorder peakPowerForChannel:0];
    //转换最高分贝值，范围是0到1。0最小，1最大。
    const float ALPHA = 0.05;
    float peakPowerForChannel = pow(10, (ALPHA * peakPower));
    //lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults;
    return peakPowerForChannel;
}

@end
