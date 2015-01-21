//
//  BDSSpeechSynthesizerDelegate.h
//  BDSSpeechSynthesizer
//
//  Created by  段弘 on 13-11-23.
//  Copyright (c) 2013年 百度. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BDSSpeechSynthesizer;

@protocol BDSSpeechSynthesizerDelegate <NSObject>

/**
 * @brief 合成器开始工作
 *
 * @param speechSynthesizer 合成器对象
 */
@optional
- (void)synthesizerStartWorking:(BDSSpeechSynthesizer *)speechSynthesizer;

/**
 * @brief 合成器开始朗读
 *
 * @param speechSynthesizer 合成器对象
 */
- (void)synthesizerSpeechStart:(BDSSpeechSynthesizer *)speechSynthesizer;

/**
 * @brief 新的语音数据已经合成
 *
 * @param speechSynthesizer 合成器对象
 * @param data 语音数据
 * @param lastDataFlag 是否是最后一段数据
 */
- (void)synthesizerNewDataArrived:(BDSSpeechSynthesizer *)speechSynthesizer data:(NSData *)newData isLastData:(BOOL)lastDataFlag;

/**
 * @brief 缓冲进度已更新
 *
 * @param speechSynthesizer 合成器对象
 * @param progress 已缓冲的进度，取值范围[0.0, 1.0]
 */
- (void)synthesizerBufferProgressChanged:(BDSSpeechSynthesizer *)speechSynthesizer progress:(float)newProgress;

/**
 * @brief 播放进度已更新
 *
 * @param speechSynthesizer 合成器对象
 * @param progress 已播放进度，取值范围[0.0, 1.0]
 */
- (void)synthesizerSpeechProgressChanged:(BDSSpeechSynthesizer *)speechSynthesizer progress:(float)newProgress;

/**
 * @brief 当前已缓冲到的文本长度已更新
 *
 * @param speechSynthesizer 合成器对象
 * @param length 以缓冲到的文本偏移量，取值范围[0, [text length]]
 */
- (void)synthesizerTextBufferedLengthChanged:(BDSSpeechSynthesizer *)speechSynthesizer length:(int)newLength;

/**
 * @brief 朗读已暂停
 *
 * @param speechSynthesizer 合成器对象
 */
- (void)synthesizerSpeechDidPaused:(BDSSpeechSynthesizer *)speechSynthesizer;

/**
 * @brief 朗读已继续
 *
 * @param speechSynthesizer 合成器对象
 */
- (void)synthesizerSpeechDidResumed:(BDSSpeechSynthesizer *)speechSynthesizer;

/**
 * @brief 已取消
 *
 * @param speechSynthesizer 合成器对象
 */
- (void)synthesizerDidCanceled:(BDSSpeechSynthesizer *)speechSynthesizer;

/**
 * @brief 朗读完成
 *
 * @param speechSynthesizer 合成器对象
 */
- (void)synthesizerSpeechDidFinished:(BDSSpeechSynthesizer *)speechSynthesizer;

/**
 * @brief 合成器发生错误
 *
 * @param speechSynthesizer 合成器对象
 * @param error 错误对象
 */
- (void)synthesizerErrorOccurred:(BDSSpeechSynthesizer *)speechSynthesizer error:(NSError *)error;

@end