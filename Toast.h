//
//  Toast.h
//  ExpressionChat
//
//  Created by Feicun on 14/11/5.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface Toast : NSObject

+ (Toast *)makeToast:(NSString *)text;
+ (Toast *)makeTip;
- (void)show:(BOOL)isCorrect;
- (void)loading;
- (void)loading:(UIView *)parentView;
- (void)endLoading;
- (void)pageTip:(NSString *)top andCenter:(NSString *)center andBottom:(NSString *)bottom;
- (void)chatPageTip:(CGFloat)y;
@end

@interface TipView : UIView <UIGestureRecognizerDelegate>

@end