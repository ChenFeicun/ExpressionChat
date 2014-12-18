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
    [self shakeView:view
          withTimes:10
          direction:1
       currentTimes:0
          withDelta:5
           andSpeed:0.04
     shakeDirection:ShakeDirectionHorizontal];
}

+ (void)shakeView:(UIView *)view withTimes:(int)times direction:(int)direction currentTimes:(int)current withDelta:(CGFloat)delta andSpeed:(NSTimeInterval)interval shakeDirection:(ShakeDirection)shakeDirection
{
    [UIView animateWithDuration:interval animations:^{
        view.transform = (shakeDirection == ShakeDirectionHorizontal) ? CGAffineTransformMakeTranslation(delta * direction, 0) : CGAffineTransformMakeTranslation(0, delta * direction);
    } completion:^(BOOL finished) {
        if(current >= times) {
            view.transform = CGAffineTransformIdentity;
            return;
        }
        [self shakeView:view
               withTimes:(times - 1)
           direction:direction * -1
        currentTimes:current + 1
           withDelta:delta
            andSpeed:interval
      shakeDirection:shakeDirection];
    }];
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
    [view setBackgroundColor:[[UIColor alloc] initWithRed:195.0 / 255.0 green:195.0 / 255.0 blue:195.0 / 255.0 alpha:1.0]];
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
