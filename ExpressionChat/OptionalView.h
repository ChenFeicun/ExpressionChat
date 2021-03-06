//
//  OptionalView.h
//  ExpressionChat
//
//  Created by 邢瑞峰 on 14/12/26.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol OptionalViewDelegate <NSObject>
@optional
- (void)tapRcdButton;
- (void)tapTTSButton;
- (void)tapClearButton;
- (void)tapCheckButton;
- (void)tapShadowArea;
- (void)confrimTTS:(NSString *)ttsString;
- (void)closeTTS;

@end

@interface IconBtn : UIButton
-(instancetype)initWithFrame:(CGRect)frame imgName:(NSString *)imgName;
-(void)disableBtn;
-(void)enableBtn;
@end

@interface OptionalView : UIView<UITextFieldDelegate, UIGestureRecognizerDelegate>
@property (nonatomic) BOOL menuActive;
@property (nonatomic) CGRect tempFrame;
@property (nonatomic, assign) id<OptionalViewDelegate> delegate;
@property (nonatomic, strong) UIView *ttsEditView;
@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, strong) UIView *blueView;
@property (nonatomic, strong) UIButton *emojiView;
@property (nonatomic, strong) IconBtn *rcdView;
@property (nonatomic, strong) IconBtn *ttsView;
@property (nonatomic, strong) IconBtn *clearView;
@property (nonatomic, strong) IconBtn *checkView;
@property (nonatomic, strong) UIView *pointView;
- (id)initWithOriginalFrame:(CGRect)frame;
-(void)showOptionView:(NSString *)emojiIndex frame:(CGRect)frame isHidden:(BOOL)isHidden;
-(void)hiddenttsEditView;
-(void)showttsEditView:(NSString *)ttsString;
-(void)disAppearOptionalView;
-(void)hiddenPointView;
-(void)showPointView;

-(void)isRecord:(BOOL)isRecord;
-(void)ttsBegin;
-(void)ttsrcdEnd:(BOOL)isRecord;
-(void)rcdBegin;
@end