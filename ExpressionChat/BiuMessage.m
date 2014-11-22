//
//  Message.m
//  ExpressionChat
//
//  Created by Feicun on 14/11/18.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import "BiuMessage.h"
#import "NotifyMsg.h"

@implementation BiuMessage

- (instancetype)initWithAudioID:(NSString *)audioID audioName:(NSString *)audioName audioUrl:(NSString *)audioUrl fromName:(NSString *)fromName resName:(NSString *)resName resXRatio:(float)resXRatio type:(NSInteger)type {
    if (self = [super init]) {
        _audioID = audioID;
        _audioName = audioName;
        _audioUrl = audioUrl;
        _fromName = fromName;
        _resName = resName;
        _resXRatio = resXRatio;
        _type = type;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _resName = [dict objectForKey:@"resName"];
        _resXRatio = [[dict objectForKey:@"resXRatio"] floatValue];
        _type = [[dict objectForKey:@"type"] integerValue];
        _fromName = [dict objectForKey:@"fromName"];
        if (_type == 1) {
            _audioID = [dict objectForKey:@"audioID"];
            _audioName = [dict objectForKey:@"audioName"];
            _audioUrl = [dict objectForKey:@"audioUrl"];
        }
    }
    return self;
}

- (instancetype)initWithNotifyMsg:(NotifyMsg *)msg {
    if (self = [super init]) {
        NSLog(@"%@", msg.xratio);
        _resXRatio = [msg.xratio floatValue];
        _resName = msg.resname;
        _type = [msg.type integerValue];
        if (_type == 1) {
            _audioID = msg.audioid;
            _audioName = msg.audioname;
            _audioUrl = msg.audiourl;
        }
    }
    return self;
}

@end
