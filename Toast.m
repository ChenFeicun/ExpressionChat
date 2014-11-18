//
//  Toast.m
//  ExpressionChat
//
//  Created by Feicun on 14/11/5.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import "Toast.h"
#import <UIKit/UIKit.h>

@interface Toast()

@property (nonatomic, copy) NSString *toastLabelText;
@property (nonatomic, retain) UILabel *toastLabel;

@end

@implementation Toast

#define TOAST_HEIGHT 40

- (instancetype)initWithText:(NSString *)text {
    if (self = [super init]) {
        _toastLabelText = text;
    }
    return self;
}

+ (Toast *)makeToast:(NSString *)text {
    Toast *toast = [[Toast alloc] initWithText:text];
    return toast;
}

- (void)show {
    //1 可以使通知在键盘上
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    CGPoint center = window.center;
    _toastLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, center.y,  window.frame.size.width, TOAST_HEIGHT)];
    _toastLabel.backgroundColor = [UIColor redColor];
    _toastLabel.font = [UIFont systemFontOfSize:14];
    _toastLabel.textAlignment = NSTextAlignmentCenter;
    _toastLabel.text = _toastLabelText;
    _toastLabel.alpha = 0;
    
    [window addSubview:_toastLabel];
    
    [UIView animateWithDuration:1.0f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _toastLabel.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            _toastLabel.alpha = 0;
        } completion:^(BOOL finished) {
            [_toastLabel removeFromSuperview];
        }];
    }];
}

@end


