//
//  Message.h
//  ExpressionChat
//
//  Created by Feicun on 14/11/18.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NotifyMsg;

@interface BiuMessage : NSObject

@property (strong, nonatomic) NSString *audioID;
@property (strong, nonatomic) NSString *audioName;
@property (strong, nonatomic) NSString *audioUrl;
@property (strong, nonatomic) NSString *fromName;
@property (strong, nonatomic) NSString *resName;
@property (nonatomic) float resXRatio;
@property (nonatomic) NSInteger type;

- (instancetype)initWithAudioID:(NSString *)audioID audioName:(NSString *)audioName audioUrl:(NSString *)audioUrl fromName:(NSString *)fromName resName:(NSString *)resName resXRatio:(float)resXRatio type:(NSInteger)type;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithNotifyMsg:(NotifyMsg *)msg;
- (instancetype)initWithResName:(NSString *)resName resXRatio:(float)resXRatio type:(NSInteger)type;
@end
