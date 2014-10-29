//
//  Animation.m
//  ExpressionChat
//
//  Created by Feicun on 14/10/29.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import "Animation.h"

@implementation Animation

+ (void)shakeView:(UIView *)view {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.duration = 0.5f;
    animation.autoreverses = YES;
    CGPoint left = CGPointMake(view.center.x - 10, view.center.y);
    CGPoint right = CGPointMake(view.center.x + 10, view.center.y);
    NSArray *array = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:view.center], [NSValue valueWithCGPoint:left], [NSValue valueWithCGPoint:view.center],[NSValue valueWithCGPoint:right], [NSValue valueWithCGPoint:view.center],[NSValue valueWithCGPoint:left], [NSValue valueWithCGPoint:view.center], [NSValue valueWithCGPoint:right], [NSValue valueWithCGPoint:view.center], [NSValue valueWithCGPoint:left], nil];
    animation.values = array;
    [view.layer addAnimation:animation forKey:@"position"];
}

@end
