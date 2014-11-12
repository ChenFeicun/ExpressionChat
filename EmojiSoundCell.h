//
//  EmojiSoundCell.h
//  ExpressionChat
//
//  Created by Feicun on 14/11/11.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EmojiSoundCell;
@protocol EmojiSoundCellDelegate <NSObject>

- (void)recordCell:(EmojiSoundCell *)cell;

@end

@interface EmojiSoundCell : UICollectionViewCell <UIGestureRecognizerDelegate>

@property (nonatomic) BOOL isRecord;
@property (nonatomic, strong) NSString *soundPath;
@property (nonatomic, strong) NSString *emojiName;
@property (nonatomic) NSInteger emojiNum;
@property (nonatomic, assign) id<EmojiSoundCellDelegate> delegate;

- (void)triggerRecorder;

@end


@interface Emoji : NSObject

@property (nonatomic) BOOL isRecord;
@property (nonatomic, strong) NSString *soundPath;
@property (nonatomic, strong) NSString *emojiName;

- (instancetype)initWithEmojiName:(NSString *)emojiName;

@end