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
@property (nonatomic, retain) UIView *toastView;

@end

@implementation Toast

//#define TOAST_HEIGHT 40

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
    CGFloat TOAST_WH = window.frame.size.width * 3 / 7;
//    if (_toastLabelText.length * 15 > TOAST_WH) {
//        TOAST_WH = _toastLabelText.length * 15;
//    }
    
    _toastView = [[UIView alloc] initWithFrame:CGRectMake(center.x - TOAST_WH / 2, center.y - TOAST_WH / 2,  TOAST_WH, TOAST_WH)];
    _toastView.backgroundColor = [UIColor blackColor];
    _toastView.layer.cornerRadius = 10;
    _toastView.clipsToBounds = YES;
    _toastView.alpha = 0.7;
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(TOAST_WH / 6, 0, TOAST_WH * 2 / 3, TOAST_WH * 2 / 3)];
    imgView.image = [UIImage imageNamed:@"warning.png"];
    [_toastView addSubview:imgView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, TOAST_WH * 2 / 3, TOAST_WH, TOAST_WH / 3)];
    label.font = [UIFont boldSystemFontOfSize:15.0f];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = _toastLabelText;
    label.textColor = [UIColor whiteColor];
    [_toastView addSubview:label];
    
    [window addSubview:_toastView];
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(dismissToast:) userInfo:nil repeats:NO];
}

- (void)dismissToast:(NSTimer *)timer {
    [timer invalidate];
    [_toastView removeFromSuperview];
}

- (void)loading {
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    [self loadingView];
    [window addSubview:_toastView];
}

- (void)loading:(UIView *)parentView {
    [self loadingView];
    [parentView addSubview:_toastView];
}

- (void)loadingView {
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    CGPoint center = window.center;
    _toastView = [[UIView alloc] initWithFrame:window.frame];
    _toastView.backgroundColor = [UIColor grayColor];
    _toastView.alpha = 0.7;
    
    CGFloat TOAST_WH = window.frame.size.width * 3 / 7;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(center.x - TOAST_WH / 2, center.y - TOAST_WH / 2,TOAST_WH, TOAST_WH)];
    
    view.backgroundColor = [UIColor blackColor];
    view.layer.cornerRadius = 10;
    view.clipsToBounds = YES;
    
    UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(TOAST_WH / 6, 0, TOAST_WH * 2 / 3, TOAST_WH * 2 / 3)];
    [aiView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    //[aiView setCenter:CGPointMake(center.x, center.y)];
    [aiView startAnimating];
    [view addSubview:aiView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, TOAST_WH * 2 / 3, TOAST_WH, TOAST_WH / 3)];
    label.font = [UIFont boldSystemFontOfSize:17.0f];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = _toastLabelText;
    label.textColor = [UIColor whiteColor];
    [view addSubview:label];
    //[aiView startAnimating];
    //view.alpha = 0.7;
    
    [_toastView addSubview:view];
}

- (void)endLoading {
    [_toastView removeFromSuperview];
}
@end


