//
//  EmojiSoundCell.m
//  ExpressionChat
//
//  Created by Feicun on 14/11/11.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import "EmojiSoundCell.h"


@interface EmojiSoundCell()

@property (nonatomic, strong) UILongPressGestureRecognizer *gesture;
@property (nonatomic, strong) UIView *pointVIew;
@end

@implementation EmojiSoundCell
#define CELL_PADDING 8

- (instancetype)init {
    if (self = [super init]) {
        [self configureCell];
    }
    return self;
}

- (instancetype)initWithEmojiName:(NSString *)emojiName {
    if (self = [super init]) {
        self.emojiName = emojiName;
        [self configureCell];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configureCell];
}

- (void)triggerRecorder {
    [self configureCell];
}

- (void)showPointView {
    self.pointVIew.hidden = NO;
}

- (void)configureCell {
    CGRect pointFrame = CGRectMake(0, self.frame.size.height - CELL_PADDING / 2, CELL_PADDING / 2, CELL_PADDING / 2);
    self.pointVIew = [[UIView alloc] initWithFrame:pointFrame];
    self.pointVIew.backgroundColor = [[UIColor alloc] initWithRed:0 green:188.0 / 255.0 blue:212.0 / 255.0 alpha:1.0];
    self.pointVIew.hidden = YES;
    
    [self addSubview:self.pointVIew];
    
    if (!self.contentView.backgroundColor)
        self.contentView.backgroundColor = [UIColor clearColor];    
    self.gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHappened:)];
    self.gesture.minimumPressDuration = 1.0f;
    self.gesture.numberOfTouchesRequired = 1;
    self.gesture.delegate = self;
    [self.contentView addGestureRecognizer:self.gesture];
}

- (void)gestureHappened:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(recordCell:)]) {
            [self.delegate recordCell:self];
        }
    } 
}

@end

//@implementation Emoji
//
//- (instancetype)initWithEmojiName:(NSString *)emojiName {
//    if (self = [super init]) {
//        self.emojiName = emojiName;
//        emojiName = [emojiName substringFromIndex:emojiName.length - 2];
//        NSString *avosName = [@"audio_" stringByAppendingString:emojiName];
//        self.avosName = [avosName stringByAppendingString:@".amr"];
//    }
//    return self;
//}
//
//@end