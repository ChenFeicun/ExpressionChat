//
//  GuideView.h
//  ExpressionChat
//
//  Created by 彭征新 on 15/1/7.
//  Copyright (c) 2015年 Feicun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuideView : UIView <UIGestureRecognizerDelegate>
+(GuideView *) initWithArray;
-(void) guideViewForView:(UIView *)supperView andTop:(CGFloat)top andBottom:(CGFloat)bottom;

//添加四方遮板
-(void) guideViewForView:(UIView *)supperView withFrame:(CGRect)frame andStepIndex:(int)stepIndex;
//添加提示性文字
//-(void) noticeTextForView:(UIView *)supperView withFrame:(CGRect)frame andText:(NSString *)str textAlignment:(NSTextAlignment)alignment;
-(void)changeNoticeText:(NSString *)text;
-(void) removeAll;
@end