//
//  Toast.h
//  ExpressionChat
//
//  Created by Feicun on 14/11/5.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Toast : NSObject

+ (Toast *)makeToast:(NSString *)text;
- (void)show;

@end
