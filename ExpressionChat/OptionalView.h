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
- (void)confrimTTS:(NSString *)ttsString;
- (void)closeTTS;

@end

@interface OptionalView : UIView<UITextFieldDelegate, UIGestureRecognizerDelegate>
@property (nonatomic) BOOL menuActive;
@property (nonatomic) CGRect tempFrame;
@property (nonatomic, assign) id<OptionalViewDelegate> delegate;
@property (nonatomic, strong) UITextField *ttsEditView;
@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, strong) UIView *blueView;
@property (nonatomic, strong) UIButton *emojiView;
@property (nonatomic, strong) UIButton *rcdView;
@property (nonatomic, strong) UIButton *ttsView;
@property (nonatomic, strong) UIButton *clearView;
@property (nonatomic, strong) UIButton *checkView;
@property (nonatomic, strong) UIView *pointView;
- (id)initWithOriginalFrame:(CGRect)frame;
-(void)showOptionView:(NSString *)emojiIndex frame:(CGRect)frame isHidden:(BOOL)isHidden;
-(void)hiddenttsEditView;
-(void)showttsEditView:(NSString *)ttsString;
-(void)disAppearOptionalView;
-(void)hiddenPointView;
-(void)showPointView;
@end
