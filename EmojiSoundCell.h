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
@property (nonatomic, strong) NSString *emojiName;
@property (nonatomic) NSInteger emojiNum;
@property (nonatomic, assign) id<EmojiSoundCellDelegate> delegate;

- (void)triggerRecorder;
- (void)showPointView;
@end


//@interface Emoji : NSObject
//
//@property (nonatomic) BOOL isRecord;
//@property (nonatomic, strong) NSURL *soundURL;
//@property (nonatomic, strong) NSString *emojiName;
//@property (nonatomic, strong) NSData *emojiData;
////AVOS上保存的URL和ObjectId和名字
//@property (nonatomic, strong) NSString *avosName;
//@property (nonatomic, strong) NSString *avosURL;
//@property (nonatomic, strong) NSString *avosID;
//
//- (instancetype)initWithEmojiName:(NSString *)emojiName;
//
//@end