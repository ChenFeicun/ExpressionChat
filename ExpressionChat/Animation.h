//
//  Animation.h
//  ExpressionChat
//
//  Created by Feicun on 14/10/29.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ShakeDirection) {
    ShakeDirectionHorizontal = 0,
    ShakeDirectionVertical
};

@interface Animation : NSObject
+ (void)shakeView:(UIView *)view;
+ (void)moveViewForEditing:(UIView *)view orNot:(BOOL)editingOrNot;
+ (void)setBackgroundColorWithGrey:(UIView *)view;
+ (void)setBackgroundColorWithDark:(UIView *)view;
+ (void)setBackgroundColorWithLight:(UIView *)view;
+ (void)setBackgroundColorWithWhite:(UIView *)view;

@end
