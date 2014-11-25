//
//  EmojiBoardView.m
//  ExpressionChat
//
//  Created by Feicun on 14/11/23.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import "EmojiBoardView.h"
#import "ResourceManager.h"

@implementation EmojiBoardView {
    UIScrollView *emojiScrollView;
    UIPageControl *emojiPageControl;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //NSLog(@"%f", FACE_ICON_SIZE);
        self.backgroundColor = [UIColor colorWithRed:245.0 / 255.0 green:245.0 / 255.0 blue:245.0 / 255.0 alpha:1];
        //表情盘
        emojiScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, EMOJI_BOARD_WIDTH, frame.size.height)];
        emojiScrollView.pagingEnabled = YES;
        emojiScrollView.contentSize = CGSizeMake((FACE_COUNT_ALL / FACE_COUNT_PAGE + 1) * EMOJI_BOARD_WIDTH, frame.size.height - 20);
        emojiScrollView.showsHorizontalScrollIndicator = NO;
        emojiScrollView.showsVerticalScrollIndicator = NO;
        emojiScrollView.delegate = self;
        
        for (int i = 1; i <= FACE_COUNT_ALL; i++) {
            //计算每一个表情按钮的坐标和在哪一屏
            CGFloat x = (((i - 1) % FACE_COUNT_PAGE) % FACE_COUNT_CLU) * FACE_ICON_SIZE + ((i - 1) / FACE_COUNT_PAGE * EMOJI_BOARD_WIDTH);
            CGFloat y = (((i - 1) % FACE_COUNT_PAGE) / FACE_COUNT_CLU) * FACE_ICON_SIZE;

            EmojiCellView *cellView = [[EmojiCellView alloc] initWithFrame:CGRectMake( x, y, FACE_ICON_SIZE, FACE_ICON_SIZE) andImgIndex:[NSString stringWithFormat:@"%02d", i]];
            cellView.delegate = self;
            [emojiScrollView addSubview:cellView];
//            EmojiImgView *emjImgView = [[EmojiImgView alloc] initWithFrame:CGRectMake( x, y, FACE_ICON_SIZE, FACE_ICON_SIZE)];
//           
//            emjImgView.emojiIndex = [NSString stringWithFormat:@"%02d", i];
//            emjImgView.image = [UIImage imageNamed:[@"emoji_" stringByAppendingString:emjImgView.emojiIndex]];
//            emjImgView.delegate = self;
//            [emojiScrollView addSubview:emjImgView];
//            [emojiScrollView sendSubviewToBack:emjImgView];
//            EmojiButton *emojiButton = [[EmojiButton alloc] initWithFrame:CGRectMake( x, y, FACE_ICON_SIZE, FACE_ICON_SIZE)];
//            emojiButton.buttonIndex = [NSString stringWithFormat:@"%02d", i];
//            emojiButton.delegate = self;
//            [emojiButton addTarget:self action:@selector(clickEmojiButton:) forControlEvents:UIControlEventTouchUpInside];
//            
//            [emojiButton setImage:[UIImage imageNamed:[@"emoji_" stringByAppendingString:emojiButton.buttonIndex]] forState:UIControlStateNormal];
//            
//            [emojiScrollView addSubview:emojiButton];
//        
            Emoji *emj = [[ResourceManager sharedInstance].emojiArray objectAtIndex:(i - 1)];
            if (emj.isRecord) {
                [cellView showPointView];
            }
        }
        
        //添加PageControl
        emojiPageControl = [[UIPageControl alloc]initWithFrame:CGRectMake((EMOJI_BOARD_WIDTH - 100) / 2, FACE_ICON_SIZE * 3, 100, 20)];
        emojiPageControl.currentPageIndicatorTintColor = [[UIColor alloc] initWithRed:0 green:188.0 / 255.0 blue:212.0 / 255.0 alpha:1.0];
        emojiPageControl.pageIndicatorTintColor = [[UIColor alloc] initWithRed:117.0 / 255.0 green:117.0 / 255.0 blue:117.0 / 255.0 alpha:1.0];
        [emojiPageControl addTarget:self action:@selector(pageChange:) forControlEvents:UIControlEventValueChanged];
        
        emojiPageControl.numberOfPages = FACE_COUNT_ALL / FACE_COUNT_PAGE + 1;
        emojiPageControl.currentPage = 0;
        [self addSubview:emojiPageControl];
        
        //添加键盘View
        [self addSubview:emojiScrollView];
        
    }
    return self;
}

//停止滚动的时候
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [emojiPageControl setCurrentPage:emojiScrollView.contentOffset.x / EMOJI_BOARD_WIDTH];
    [emojiPageControl updateCurrentPageDisplay];
}

- (void)pageChange:(id)sender {
    
    [emojiScrollView setContentOffset:CGPointMake(emojiPageControl.currentPage * EMOJI_BOARD_WIDTH, 0) animated:YES];
    [emojiPageControl setCurrentPage:emojiPageControl.currentPage];
}

- (void)recordEmojiCell:(EmojiCellView *)cellView{
    if ([self.delegate respondsToSelector:@selector(recordEmojiCell:)]) {
        [self.delegate recordEmojiCell:cellView];
    }
}
//
- (void)clickEmojiCell:(EmojiCellView *)cellView {
    //cellView.backgroundColor = [UIColor colorWithRed:245.0 / 255.0 green:245.0 / 255.0 blue:245.0 / 255.0 alpha:1];
    if ([self.delegate respondsToSelector:@selector(clickEmojiCell:)]) {
        [self.delegate clickEmojiCell:cellView];
    }
}

@end
//
//@interface EmojiButton()
//@property (nonatomic, strong) UILongPressGestureRecognizer *gesture;
//@property (nonatomic, strong) UIView *pointView;
//@end
//@implementation EmojiButton
//
//
//- (id)initWithFrame:(CGRect)frame {
//    
//    self = [super initWithFrame:frame];
//    CGFloat pointSize = 5 * RATIO;
//    self.pointView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - pointSize, pointSize, pointSize)];
//    self.pointView.backgroundColor = [[UIColor alloc] initWithRed:0 green:188.0 / 255.0 blue:212.0 / 255.0 alpha:1.0];
//    self.pointView.hidden = YES;
//    [self addSubview:self.pointView];
//    
//    if (self) {
//        self.gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHappened:)];
//        self.gesture.minimumPressDuration = 1.0f;
//        self.gesture.numberOfTouchesRequired = 1;
//        self.gesture.delegate = self;
//        [self addGestureRecognizer:self.gesture];
//    }
//    return self;
//}
//
//- (void)gestureHappened:(UILongPressGestureRecognizer *)sender {
//    if (sender.state == UIGestureRecognizerStateBegan) {
//        if ([self.delegate respondsToSelector:@selector(recordEmojiCell:)]) {
//            //[self.delegate recordEmojiCell:self];
//        }
//    }
//}
//
//- (void)showPointView {
//    self.pointView.hidden = NO;
//}
//
//@end
//
//
//
//@interface EmojiImgView()
//@property (nonatomic, strong) UILongPressGestureRecognizer *gesture;
//
//@property (nonatomic, strong) UIView *pointView;
//@end
//@implementation EmojiImgView
//
//- (id)initWithFrame:(CGRect)frame {
//    
//    self = [super initWithFrame:frame];
//    if (self) {
//       
//        CGFloat pointSize = 5 * RATIO;
//        self.pointView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - pointSize, pointSize, pointSize)];
//        self.pointView.backgroundColor = [[UIColor alloc] initWithRed:0 green:188.0 / 255.0 blue:212.0 / 255.0 alpha:1.0];
//    
//        self.pointView.hidden = YES;
//        [self addSubview:self.pointView];
//        self.userInteractionEnabled = YES;
//        self.gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHappened:)];
//        self.gesture.minimumPressDuration = 1.0f;
//        self.gesture.numberOfTouchesRequired = 1;
//        self.gesture.delegate = self;
//        [self addGestureRecognizer:self.gesture];
//    }
//    return self;
//}
//
//- (void)gestureHappened:(UILongPressGestureRecognizer *)sender {
//    if (sender.state == UIGestureRecognizerStateBegan) {
//        if ([self.delegate respondsToSelector:@selector(recordEmojiCell:)]) {
//            //[self.delegate recordEmojiCell:self];
//        }
//    }
//}
//
//- (void)showPointView {
//    self.pointView.hidden = NO;
//}
//

//@end

@interface EmojiCellView()
@property (nonatomic, strong) UILongPressGestureRecognizer *gesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIView *pointView;
@end

@implementation EmojiCellView

- (id)initWithFrame:(CGRect)frame andImgIndex:(NSString *)imgIndex{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.emojiIndex = imgIndex;
        CGFloat pointSize = 5 * RATIO;
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING_SIZE, PADDING_SIZE, self.frame.size.width - PADDING_SIZE * 2, self.frame.size.height - PADDING_SIZE * 2)];
        imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"emoji_%@.png", imgIndex]];
        [self addSubview:imgView];
        
        self.pointView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - pointSize, pointSize, pointSize)];
        self.pointView.backgroundColor = [[UIColor alloc] initWithRed:0 green:188.0 / 255.0 blue:212.0 / 255.0 alpha:1.0];
        
        self.pointView.hidden = YES;
        [self addSubview:self.pointView];
        self.gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHappened:)];
        self.gesture.minimumPressDuration = 1.0f;
        self.gesture.numberOfTouchesRequired = 1;
        self.gesture.delegate = self;
        [self addGestureRecognizer:self.gesture];
        
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHappened:)];
        self.tapGesture.numberOfTapsRequired = 1;
        self.tapGesture.delegate = self;
        [self addGestureRecognizer:self.tapGesture];
    }
    return self;
}

- (void)gestureHappened:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(recordEmojiCell:)]) {
            [self.delegate recordEmojiCell:self];
        }
    }
}

- (void)tapHappened:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        //self.backgroundColor =  [[UIColor alloc] initWithRed:117.0 / 255.0 green:117.0 / 255.0 blue:117.0 / 255.0 alpha:1.0];
        if ([self.delegate respondsToSelector:@selector(clickEmojiCell:)]) {
            [self.delegate clickEmojiCell:self];
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self setBackgroundColor:[[UIColor alloc] initWithRed:117.0 / 255.0 green:117.0 / 255.0 blue:117.0 / 255.0 alpha:1.0]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self setBackgroundColor:[UIColor colorWithRed:245.0 / 255.0 green:245.0 / 255.0 blue:245.0 / 255.0 alpha:1]];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self setBackgroundColor:[UIColor colorWithRed:245.0 / 255.0 green:245.0 / 255.0 blue:245.0 / 255.0 alpha:1]];
}

- (void)showPointView {
    self.pointView.hidden = NO;
}

@end



@implementation Emoji

- (instancetype)initWithEmojiName:(NSString *)emojiName {
    if (self = [super init]) {
        self.emojiName = emojiName;
        emojiName = [emojiName substringFromIndex:emojiName.length - 2];
        NSString *avosName = [@"audio_" stringByAppendingString:emojiName];
        self.avosName = [avosName stringByAppendingString:@".amr"];
    }
    return self;
}

@end
