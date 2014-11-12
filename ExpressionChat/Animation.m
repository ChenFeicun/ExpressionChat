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

+ (void)moveViewForEditing:(UIView *)view orNot:(BOOL)editingOrNot{
    CGFloat move = editingOrNot ? 50 : -50;
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        CGRect frame = view.frame;
        frame.origin.y -= move;
        view.frame = frame;
    } completion:^(BOOL finished) {
        ;
    }];
}

+ (void)setBackgroundColorWithGrey:(UIView *)view {
    [view setBackgroundColor:[[UIColor alloc] initWithRed:117.0 / 255.0 green:117.0 / 255.0 blue:117.0 / 255.0 alpha:1.0]];
}

+ (void)setBackgroundColorWithDark:(UIView *)view {
    [view setBackgroundColor:[[UIColor alloc] initWithRed:0 green:188.0 / 255.0 blue:212.0 / 255.0 alpha:1.0]];
}

+ (void)setBackgroundColorWithLight:(UIView *)view {
    [view setBackgroundColor:[[UIColor alloc] initWithRed:245.0 / 255.0 green:245.0 / 255.0 blue:245.0 / 255.0 alpha:1.0]];
}

+ (void)setBackgroundColorWithWhite:(UIView *)view {
    [view setBackgroundColor:[[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
}

@end
