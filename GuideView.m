//
//  GuideView.m
//  ExpressionChat
//
//  Created by 彭征新 on 15/1/7.
//  Copyright (c) 2015年 Feicun. All rights reserved.
//

#import "GuideView.h"
@interface GuideView () {
    NSMutableArray *guideArray;
    UILabel *noticeText;
}
@end

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@implementation GuideView 

+(GuideView *) initWithArray {
    GuideView *guideView = [[super alloc]init];
    guideView->guideArray = [[NSMutableArray alloc] init];
    guideView->noticeText = [[UILabel alloc] init];
    return guideView;
}

//添加上方和下方的遮板
-(void)guideViewForView:(UIView *)supperView andTop:(CGFloat)top andBottom:(CGFloat)bottom {
    //上方遮板
    UIView * topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, top)];
    //下方遮板
    UIView * bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, bottom, SCREEN_WIDTH, SCREEN_HEIGHT - bottom)];
    
    topView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    
    [self->guideArray addObject:bottomView];
    [self->guideArray addObject:topView];
    
    [supperView addSubview:topView];
    [supperView addSubview:bottomView];
    
    //添加点击手势 点击黑色区域就消失
    UITapGestureRecognizer *shadowTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapShadowView:)];
    shadowTap.delegate = self;
    [topView addGestureRecognizer:shadowTap];
    [bottomView addGestureRecognizer:shadowTap];
   // return self->guideArray;
}

- (void)tapShadowView:(UITapGestureRecognizer *)sender {
    [self removeAll];
}
//添加四方遮板
-(void)guideViewForView:(UIView *)supperView withFrame:(CGRect)frame andStepIndex:(int)stepIndex {
    UIView *topView, *bottomView, *leftView, *rightView;
    if (stepIndex == 0) {
        topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 5)];
        //下方遮板
        bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height + 40 + 5, frame.size.width, SCREEN_HEIGHT - frame.size.height - 40)];
        //左侧遮板
        leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        //右侧遮板
        rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        
        [self->guideArray insertObject:rightView atIndex:0];
        [self->guideArray insertObject:leftView atIndex:0];
        [self->guideArray insertObject:bottomView atIndex:0];
        [self->guideArray insertObject:topView atIndex:0];
 
        for (UIView *view in self->guideArray) {
            view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
            [supperView addSubview:view];
        }

    } else {
        topView = guideArray[0];
        bottomView = guideArray[1];
        leftView = guideArray[2];
        rightView = guideArray[3];
        
        if (stepIndex == 1) {
            topView.frame = CGRectMake(0, 0, SCREEN_WIDTH, frame.origin.y);
            bottomView.frame = CGRectMake(0, frame.origin.y + frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT - frame.origin.y - frame.size.height);
            leftView.frame = CGRectMake(0, frame.origin.y, frame.origin.x, frame.size.height);
            rightView.frame = CGRectMake(frame.origin.x + frame.size.width, frame.origin.y, SCREEN_WIDTH - frame.origin.x - frame.size.width, frame.size.height);
        } else if (stepIndex == 2) {
            [UIView animateWithDuration:0.5 animations:^{
                topView.frame = CGRectMake(0, 0, SCREEN_WIDTH, frame.origin.y);
                bottomView.frame = CGRectMake(0, frame.origin.y + frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT - frame.origin.y - frame.size.height);
                leftView.frame = CGRectMake(0, frame.origin.y, frame.origin.x, frame.size.height);
                rightView.frame = CGRectMake(frame.origin.x + frame.size.width, frame.origin.y, SCREEN_WIDTH - frame.origin.x - frame.size.width, frame.size.height);
            }];

        }
    }

//    if ([self->guideArray count] != 0) {
//        [UIView animateWithDuration:0.5 animations:^{
//            UIView *topView = guideArray[0];
//            UIView *bottomView = guideArray[1];
//            UIView *leftView = guideArray[2];
//            UIView *rightView = guideArray[3];
//            topView.frame = CGRectMake(0, 0, SCREEN_WIDTH, frame.origin.y);
//            bottomView.frame = CGRectMake(0, frame.origin.y + frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT - frame.origin.y - frame.size.height);
//            leftView.frame = CGRectMake(0, frame.origin.y, frame.origin.x, frame.size.height);
//            rightView.frame = CGRectMake(frame.origin.x + frame.size.width, frame.origin.y, SCREEN_WIDTH - frame.origin.x - frame.size.width, frame.size.height);
//        }];
//
//    } else {
//        //上侧遮板
//        UIView * topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, frame.origin.y)];
//        //下方遮板
//        UIView * bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.origin.y + frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT - frame.origin.y - frame.size.height)];
//        //左侧遮板
//        UIView * leftView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.origin.y, frame.origin.x, frame.size.height)];
//        //右侧遮板
//        UIView * rightView = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x + frame.size.width, frame.origin.y, SCREEN_WIDTH - frame.origin.x - frame.size.width, frame.size.height)];
//        
//        [self->guideArray insertObject:rightView atIndex:0];
//        [self->guideArray insertObject:leftView atIndex:0];
//        [self->guideArray insertObject:bottomView atIndex:0];
//        [self->guideArray insertObject:topView atIndex:0];
//
//    }
//    //上方遮板
//    
}

//清楚所有遮板
-(void)removeAll {
    for (UIView *view in self->guideArray) {
        [view removeFromSuperview];
    }
    
    [noticeText removeFromSuperview];
}

//添加提示性文字
-(void)noticeTextForView:(UIView *)supperView withText:(NSString *)str {
    CGRect frame = CGRectMake(0, supperView.frame.size.height / 2 - 20, supperView.frame.size.width, 40);
    noticeText.frame = frame;

    noticeText.text = str;
    noticeText.textAlignment = NSTextAlignmentCenter;
    noticeText.textColor = [UIColor whiteColor];
    noticeText.numberOfLines = 0;
    [noticeText setFont:[UIFont boldSystemFontOfSize:20]];
    
    [supperView addSubview:noticeText];
    
}
@end
