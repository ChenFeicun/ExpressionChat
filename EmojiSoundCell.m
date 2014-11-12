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

@end

@implementation EmojiSoundCell

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
    
}

- (void)configureCell {
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

@implementation Emoji

- (instancetype)initWithEmojiName:(NSString *)emojiName {
    if (self = [super init]) {
        self.emojiName = emojiName;
        self.soundPath = nil;
        self.isRecord = NO;
    }
    return self;
}

@end