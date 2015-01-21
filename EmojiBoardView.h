//
//  EmojiBoardView.h
//  ExpressionChat
//
//  Created by Feicun on 14/11/23.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FACE_COUNT_ALL  74

#define FACE_COUNT_ROW  3

#define FACE_COUNT_CLU  7

#define FACE_COUNT_PAGE ( FACE_COUNT_ROW * FACE_COUNT_CLU )

#define EMOJI_BOARD_WIDTH [UIScreen mainScreen].bounds.size.width

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define FACE_ICON_SIZE (EMOJI_BOARD_WIDTH / FACE_COUNT_CLU)

#define RATIO (EMOJI_BOARD_WIDTH / 320)

#define PADDING_SIZE (10 * RATIO)

@class EmojiCellView;

@protocol EmojiCellDelegate <NSObject>

- (void)longPressEmojiCell:(EmojiCellView *)cellView;

@optional
- (void)clickEmojiCell:(EmojiCellView *)cellView;

@end

@interface EmojiBoardView : UIView <UIScrollViewDelegate, EmojiCellDelegate>

@property (nonatomic, assign) id<EmojiCellDelegate> delegate;

@end


@interface EmojiCellView : UIView <UIGestureRecognizerDelegate>
@property NSString *emojiIndex;
@property (nonatomic, assign) id<EmojiCellDelegate> delegate;
- (id)initWithFrame:(CGRect)frame andImgIndex:(NSString *)imgIndex;
- (void)showPointView;
- (void)hidePointView;
- (BOOL)isPointViewHide;
@end

@interface Emoji : NSObject

@property (nonatomic) BOOL isRecord;
@property (nonatomic, strong) NSURL *soundURL;
@property (nonatomic, strong) NSString *emojiName;
@property (nonatomic, strong) NSData *emojiData;
//AVOS上保存的URL和ObjectId和名字
@property (nonatomic, strong) NSString *avosName;
@property (nonatomic, strong) NSString *avosURL;
@property (nonatomic, strong) NSString *avosID;
//TTS
@property (nonatomic, strong) NSString *ttsString;

- (instancetype)initWithEmojiName:(NSString *)emojiName;

@end