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
@property (nonatomic, retain) TipView *tipView;

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

- (void)show:(BOOL)isCorrect {
    //1 可以使通知在键盘上 但在IOS7上index 1 会闪退
    // NSLog(@"%d", [[[UIApplication sharedApplication] windows] count]);
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    CGPoint center = window.center;
    CGFloat TOAST_WH = window.frame.size.width * 3 / 7;
    
    _toastView = [[UIView alloc] initWithFrame:CGRectMake(center.x - TOAST_WH / 2, center.y - TOAST_WH / 2,  TOAST_WH, TOAST_WH)];
    _toastView.backgroundColor = [UIColor blackColor];
    _toastView.layer.cornerRadius = 10;
    _toastView.clipsToBounds = YES;
    _toastView.alpha = 0.7;
    
    NSString *imgName;
    if (isCorrect) {
        imgName = @"correct.png";
    } else {
        imgName = @"warning.png";
    }
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(TOAST_WH / 6, 0, TOAST_WH * 2 / 3, TOAST_WH * 2 / 3)];
    imgView.image = [UIImage imageNamed:imgName];
    [_toastView addSubview:imgView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, TOAST_WH * 2 / 3, TOAST_WH, TOAST_WH / 3)];
    label.backgroundColor = [UIColor clearColor];
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
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    [self loadingView];
    [window addSubview:_toastView];
}

- (void)loading:(UIView *)parentView {
    [self loadingView];
    [parentView addSubview:_toastView];
}

- (void)loadingView {
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
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
    label.backgroundColor = [UIColor clearColor];
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

+ (Toast *)makeTip {
    Toast *toast = [[Toast alloc] init];
    return toast;
}

- (void)pageTip:(NSString *)top andCenter:(NSString *)center andBottom:(NSString *)bottom {
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    _tipView = [[TipView alloc] initWithFrame:window.frame];
    _tipView.backgroundColor = [UIColor grayColor];
    _tipView.alpha = 0.7;
    
    UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] applicationFrame].origin.y, _tipView.frame.size.width, 40)];
    topLabel.backgroundColor = [UIColor clearColor];
    topLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    topLabel.textAlignment = NSTextAlignmentCenter;
    topLabel.text = top;
    topLabel.textColor = [UIColor whiteColor];
    
    UILabel *centerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (_tipView.frame.size.height - 40) / 2, _tipView.frame.size.width, 40)];
    centerLabel.backgroundColor = [UIColor clearColor];
    centerLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    centerLabel.textAlignment = NSTextAlignmentCenter;
    centerLabel.text = center;
    centerLabel.textColor = [UIColor whiteColor];
    
    UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _tipView.frame.size.height - 40, _tipView.frame.size.width, 40)];
    bottomLabel.backgroundColor = [UIColor clearColor];
    bottomLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    bottomLabel.text = bottom;
    bottomLabel.textColor = [UIColor whiteColor];
    
    [_tipView addSubview:topLabel];
    [_tipView addSubview:centerLabel];
    [_tipView addSubview:bottomLabel];
    
    [window addSubview:_tipView];
}


- (void)chatPageTip:(CGFloat)y {
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    _tipView = [[TipView alloc] initWithFrame:window.frame];
    _tipView.backgroundColor = [UIColor grayColor];
    _tipView.alpha = 0.7;
    
    UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] applicationFrame].origin.y, _tipView.frame.size.width, 40)];
    topLabel.backgroundColor = [UIColor clearColor];
    topLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    topLabel.textAlignment = NSTextAlignmentCenter;
    topLabel.text = @"查看离线消息";
    topLabel.textColor = [UIColor whiteColor];
    
    UILabel *centerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (_tipView.frame.size.height - 40) / 2, _tipView.frame.size.width, 40)];
    centerLabel.backgroundColor = [UIColor clearColor];
    centerLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    centerLabel.textAlignment = NSTextAlignmentCenter;
    centerLabel.text = @"向右滑动返回主界面";
    centerLabel.textColor = [UIColor whiteColor];
    
    UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, _tipView.frame.size.width, 40 * 2)];
    bottomLabel.backgroundColor = [UIColor clearColor];
    bottomLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    //设置换行
    bottomLabel.lineBreakMode = NSLineBreakByCharWrapping;
    bottomLabel.numberOfLines = 0;
    bottomLabel.text = @"短按即发送\n长按为表情录制2秒音频";
    bottomLabel.textColor = [UIColor whiteColor];
    
    [_tipView addSubview:topLabel];
    [_tipView addSubview:centerLabel];
    [_tipView addSubview:bottomLabel];
    
    [window addSubview:_tipView];

}

@end

@interface TipView()
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) BOOL isTap;
@end

@implementation TipView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _isTap = NO;
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHappened:)];
        _tapGesture.delegate = self;
        [self addGestureRecognizer:_tapGesture];
        _timer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(disappear) userInfo:nil repeats:NO];
    }
    return self;
}

- (void)remove {
    [_timer invalidate];
    [self removeFromSuperview];
}

- (void)disappear {
    if (!_isTap) {
        [self remove];
    }
}

- (void)tapHappened:(UITapGestureRecognizer *)tap {
    _isTap = YES;
    [self remove];
}
@end