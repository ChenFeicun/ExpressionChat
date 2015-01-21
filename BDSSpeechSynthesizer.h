//
//  BDSSpeechSynthesizer.h
//  BDSSpeechSynthesizer
//
//  Created by  段弘 on 13-11-23.
//  Copyright (c) 2013年 百度. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDSSpeechSynthesizerDelegate.h"

/**
 * @brief 日志级别枚举类型
 */
typedef enum BDSLogLevel {
    BDS_PUBLIC_LOG_OFF = 0,
    BDS_PUBLIC_LOG_ERROR = 1,
    BDS_PUBLIC_LOG_WARN = 2,
    BDS_PUBLIC_LOG_INFO = 3,
    BDS_PUBLIC_LOG_DEBUG = 4,
    BDS_PUBLIC_LOG_VERBOSE = 5,
} BDSLogLevel;

// 错误码
/** 合成器错误域 */
FOUNDATION_EXPORT NSString * const BDS_SYNTHESIZER_ERROR_DOMAIN;

/** 合成器错误列表 */
enum BDSSynthesizerError {
    /** 没有设置认证信息 */
    BDS_SYNTHESIZER_NO_VERFIFY_INFO = 1001,
    /** 初始化参数错误 */
    BDS_SYNTHESIZER_INIT_PARAM_ERROR,
    /** 合成器尚未初始化 */
    BDS_SYNTHESIZER_UNINITIALIZED_ERROR,
    /** 传入文本为空 */
    BDS_SYNTHESIZER_EMPTY_TEXT_ERROR,
    /** 传入文本过长 */
    BDS_SYNTHESIZER_TOO_LONG_TEXT_ERROR,
    /** 播放器未开始播放 */
    BDS_SYNTHESIZER_PLAYER_NOT_STARTED_ERROR
};

/** 网络错误域 */
FOUNDATION_EXPORT NSString * const BDS_NETWORK_ERROR_DOMAIN;

/** 网络错误列表 */
enum BDSNetworkError {
    /** 合成器请求数据成功 */
    BDS_REQUEST_SUCCESS = 0,
    /** 没有网络连接 */
    BDS_NETWORK_NOT_CONNECTED = 2000,
    /** 连接失败 */
    BDS_CONNECT_ERROR = 2001,
    /** 服务器数据解析错误 */
    BDS_RESPONSE_PARSE_ERROR = 2002
};

/** 服务器返回错误域 */
FOUNDATION_EXPORT NSString * const BDS_SERVER_RETURN_ERROR_DOMAIN;

/** 服务器返回错误列表 */
enum BDSServerReturnError {
    /** 参数错误 */
    BDS_PARAM_ERROR = 4501,
    /** 文本编码不支持 */
    BDS_TEXT_ENCODE_NOT_SUPPORTED = 4502,
    /** 认证错误 */
    BDS_VERIFY_ERROR = 4503,
    /** 获取access token失败 */
    BDS_GET_ACCESS_TOKEN_FAILED = 4001
};

/** 参数错误列表 */
enum BDSParamError {
    BDS_PARAM_VALID_KV = 0,
    BDS_PARAM_KEY_INVALID,
    BDS_PARAM_VALUE_INVALID
};

// 合成器配置参数

/** 认证参数，产品ID，与apiKey和secretKey二选一 */
FOUNDATION_EXPORT NSString * const BDS_PARAM_PID;

/** 语言类型，当前支持取值BDS_LANGUAGE_ZH（中文）和BDS_LANGUAGE_EN（英文） */
FOUNDATION_EXPORT NSString * const BDS_PARAM_LANGUAGE;
/** 语言类型，中文 */
FOUNDATION_EXPORT NSString * const BDS_LANGUAGE_ZH;
/** 语言类型，英文 */
FOUNDATION_EXPORT NSString * const BDS_LANGUAGE_EN;

/** 文本编码，默认编码类型为UTF8 */
FOUNDATION_EXPORT NSString * const BDS_PARAM_TEXT_ENCODE;
/** 文本编码，GB2312/GBK */
FOUNDATION_EXPORT NSString * const BDS_TEXT_ENCODE_GBK;
/** 文本编码，BIG5 */
FOUNDATION_EXPORT NSString * const BDS_TEXT_ENCODE_BIG5;
/** 文本编码，UTF8 */
FOUNDATION_EXPORT NSString * const BDS_TEXT_ENCODE_UTF8;

/** 朗读语速，取值范围[0, 9]，数值越大语速越快 */
FOUNDATION_EXPORT NSString * const BDS_PARAM_SPEED;
/** 音调，取值范围[0, 9]，数值越大音调越高 */
FOUNDATION_EXPORT NSString * const BDS_PARAM_PITCH;
/** 音量，取值范围[0, 9]，数值越大音量越大 */
FOUNDATION_EXPORT NSString * const BDS_PARAM_VOLUME;

/** 音频格式，支持bv/amr/opus/mp3，对应取值BDS_AUDIO_ENCODE_BV
 *  BDS_AUDIO_ENCODE_AMR，BDS_AUDIO_ENCODE_OPUS，
 *  BDS_AUDIO_ENCODE_MP3
 */
FOUNDATION_EXPORT NSString * const BDS_PARAM_AUDIO_ENCODE;
/** 音频格式，bv */
FOUNDATION_EXPORT NSString * const BDS_AUDIO_ENCODE_BV;
/** 音频格式，amr */
FOUNDATION_EXPORT NSString * const BDS_AUDIO_ENCODE_AMR;
/** 音频格式，opus */
FOUNDATION_EXPORT NSString * const BDS_AUDIO_ENCODE_OPUS;
/** 音频格式，mp3 */
FOUNDATION_EXPORT NSString * const BDS_AUDIO_ENCODE_MP3;

/** 音频比特率，各音频格式支持的比特率详见随后参数 */
FOUNDATION_EXPORT NSString * const BDS_PARAM_AUDIO_RATE;
/** bv 16k比特率 */
FOUNDATION_EXPORT NSString * const BDS_AUDIO_BITRATE_BV_16K;
/** amr 6.6k比特率 */
FOUNDATION_EXPORT NSString * const BDS_AUDIO_BITRATE_AMR_6K6;
/** amr 8.85k比特率 */
FOUNDATION_EXPORT NSString * const BDS_AUDIO_BITRATE_AMR_8K85;
/** amr 12.65k比特率 */
FOUNDATION_EXPORT NSString * const BDS_AUDIO_BITRATE_AMR_12K65;
/** amr 14.25k比特率 */
FOUNDATION_EXPORT NSString * const BDS_AUDIO_BITRATE_AMR_14K25;
/** amr 15.85k比特率 */
FOUNDATION_EXPORT NSString * const BDS_AUDIO_BITRATE_AMR_15K85;
/** amr 18.25k比特率 */
FOUNDATION_EXPORT NSString * const BDS_AUDIO_BITRATE_AMR_18K25;
/** amr 19.85k比特率 */
FOUNDATION_EXPORT NSString * const BDS_AUDIO_BITRATE_AMR_19K85;
/** amr 23.05k比特率 */
FOUNDATION_EXPORT NSString * const BDS_AUDIO_BITRATE_AMR_23K05;
/** amr 23.85k比特率 */
FOUNDATION_EXPORT NSString * const BDS_AUDIO_BITRATE_AMR_23K85;
/** opus 8k比特率 */
FOUNDATION_EXPORT NSString * const BDS_AUDIO_BITRATE_OPUS_8K;
/** opus 16k比特率 */
FOUNDATION_EXPORT NSString * const BDS_AUDIO_BITRATE_OPUS_16K;
/** opus 18k比特率 */
FOUNDATION_EXPORT NSString * const BDS_AUDIO_BITRATE_OPUS_18K;
/** opus 20k比特率 */
FOUNDATION_EXPORT NSString * const BDS_AUDIO_BITRATE_OPUS_20K;
/** opus 24k比特率 */
FOUNDATION_EXPORT NSString * const BDS_AUDIO_BITRATE_OPUS_24K;
/** opus 32k比特率 */
FOUNDATION_EXPORT NSString * const BDS_AUDIO_BITRATE_OPUS_32K;
/** mp3 8k比特率 */
FOUNDATION_EXPORT NSString * const BDS_AUDIO_BITRATE_MP3_8K;
/** mp3 11k比特率 */
FOUNDATION_EXPORT NSString * const BDS_AUDIO_BITRATE_MP3_11K;
/** mp3 16k比特率 */
FOUNDATION_EXPORT NSString * const BDS_AUDIO_BITRATE_MP3_16K;
/** mp3 24k比特率 */
FOUNDATION_EXPORT NSString * const BDS_AUDIO_BITRATE_MP3_24K;
/** mp3 32k比特率 */
FOUNDATION_EXPORT NSString * const BDS_AUDIO_BITRATE_MP3_32K;

/** 发音人，目前支持女声BDS_SPEAKER_FEMALE和男声BDS_SPEAKER_MALE */
FOUNDATION_EXPORT NSString * const BDS_PARAM_SPEAKER;
/** 发音人，女声 */
FOUNDATION_EXPORT NSString * const BDS_SPEAKER_FEMALE;
/** 发音人，男声 */
FOUNDATION_EXPORT NSString * const BDS_SPEAKER_MALE;

/** (暂不支持)数字发音方式，取值0，1 */
FOUNDATION_EXPORT NSString * const BDS_PARAM_NUM_PRON;
/** (暂不支持)英文发音方式，取值0，1 */
FOUNDATION_EXPORT NSString * const BDS_PARAM_ENG_PRON;
/** (暂不支持)发音风格 */
FOUNDATION_EXPORT NSString * const BDS_PARAM_STYLE;
/** (暂不支持)背景音 */
FOUNDATION_EXPORT NSString * const BDS_PARAM_BACKGROUND;
/** (暂不支持)领域 */
FOUNDATION_EXPORT NSString * const BDS_PARAM_TERRITORY;
/** (暂不支持)标点符号读法 */
FOUNDATION_EXPORT NSString * const BDS_PARAM_PUNC;

@interface BDSSpeechSynthesizer : NSObject

/**
 * @brief 初始化语音合成器
 *
 * @param params 初始化参数，主要包括app认证信息
 * @param delegate 代理对象，负责处理合成器各类事件
 *
 * @return 合成器对象
 */
- (BDSSpeechSynthesizer *)initSynthesizer:(NSString *)params
                                 delegate:(id<BDSSpeechSynthesizerDelegate>)delegate;

/**
 * @brief 设置合成器参数，key-value形式，具体key和value的取值见开发手册
 *
 * @param key 参数键
 * @param value 参数值
 *
 * @return 错误码
 */
- (int)setParamForKey:(NSString *)key value:(NSString *)value;

/**
 * @brief 设置认证信息
 *
 * @param apiKey 在百度开发者中心注册应用获得
 * @param secretKey 在百度开发者中心注册应用获得
 */
- (void)setApiKey:(NSString *)apiKey withSecretKey:(NSString *)secretKey;

/**
 * @brief 设置AudioSessionCategory类型
 *
 * @param category AudioSessionCategory类型，取值参见AVAudioSession Class Reference
 */
- (void)setAudioSessionCategory:(NSString *)category;

/**
 * @brief 开始文本合成但不朗读，开发者需要通过BDSSpeechSynthesizerDelegate的
 *        synthesizerNewDataArrived:data:isLastData:方法传回的数据自行播放
 *
 * @param text 需要语音合成的文本
 */
- (int)synthesize:(NSString *)text;

/**
 * @brief 开始文本合成并朗读
 *
 * @param text 需要朗读的文本
 */
- (int)speak:(NSString *)text;

/**
 * @brief 取消本次合成并停止朗读
 */
- (void)cancel;

/**
 * @brief 暂停文本朗读
 */
- (int)pause;

/**
 * @brief 继续文本朗读
 */
- (int)resume;

/**
 * @brief 获取错误码对应的描述
 *
 * @param errorCode 错误码
 *
 * @return 错误描述信息
 */
- (NSString *)errorDescriptionForCode:(NSInteger)errorCode;

/**
 * @brief 设置日志级别
 *
 * @param logLevel 日志级别
 */
+ (void)setLogLevel:(BDSLogLevel)logLevel;

/**
 * @brief 获取当前日志级别
 *
 * @return 日志级别
 */
+ (BDSLogLevel)logLevel;

@end
