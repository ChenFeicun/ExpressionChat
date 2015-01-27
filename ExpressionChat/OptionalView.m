//
//  OptionalView.m
//  ExpressionChat
//
//  Created by 邢瑞峰 on 14/12/26.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import "OptionalView.h"
#import "EmojiBoardView.h"
#import "Animation.h"

@interface OptionalView()



@end

@implementation OptionalView

static BOOL editingOrNot = YES;

- (id)initWithOriginalFrame:(CGRect)frame {
    CGRect maxFrame = CGRectMake(0, 0, EMOJI_BOARD_WIDTH, SCREEN_HEIGHT);
    self = [super initWithFrame:maxFrame];
    if (self) {
        self.frame = maxFrame;
        self.shadowView = [[UIView alloc] initWithFrame:maxFrame];
        //self.shadowView.alpha = 0.4;
        self.shadowView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *shadowTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapShadowView:)];
        shadowTap.delegate = self;
        [self.shadowView addGestureRecognizer:shadowTap];
        [self addSubview:self.shadowView];
        
        self.menuActive = NO;
        
        self.ttsEditView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT / 2 - (40 * 3 / 2), EMOJI_BOARD_WIDTH, 40 * 3)];
        self.ttsEditView.hidden = YES;
        
        UITextField *editView = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, EMOJI_BOARD_WIDTH, 40)];
        [Animation setBackgroundColorWithLight:editView];
        editView.textAlignment = NSTextAlignmentCenter;
        editView.font = [UIFont boldSystemFontOfSize:17];
        editView.placeholder = @"请输入需要转化的文字";
        editView.delegate = self;
        editView.returnKeyType = UIReturnKeyDone;
        editView.tag = 97;
   
        UIButton *confrimButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 40, EMOJI_BOARD_WIDTH, 40)];
        [confrimButton setTitle:@"确认" forState:UIControlStateNormal];
        [confrimButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [Animation setBackgroundColorWithDark:confrimButton];
        [confrimButton addTarget:self action:@selector(saveTTSString:) forControlEvents:UIControlEventTouchUpInside];
        confrimButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        confrimButton.tag = 99;
        [confrimButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 80, EMOJI_BOARD_WIDTH, 40)];
        [closeButton setTitle:@"取消" forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [Animation setBackgroundColorWithDark:closeButton];
        [closeButton addTarget:self action:@selector(UndoTTSString:) forControlEvents:UIControlEventTouchUpInside];
        closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        closeButton.tag = 98;
        
        [self.ttsEditView addSubview:editView];
        [self.ttsEditView addSubview:closeButton];
        [self.ttsEditView addSubview:confrimButton];
        
        [self addSubview:self.ttsEditView];
        
        self.blueView = [[UIView alloc] initWithFrame:frame];
        [Animation setBackgroundColorWithDark:self.blueView];
        [self addSubview:self.blueView];
        
        CGRect smallFrame = CGRectMake(PADDING_SIZE,PADDING_SIZE, FACE_ICON_SIZE - PADDING_SIZE * 2, FACE_ICON_SIZE - PADDING_SIZE * 2);
        
        self.emojiView = [[UIButton alloc] initWithFrame:smallFrame];//[[UIImageView alloc] initWithFrame:smallFrame];
        [self.emojiView addTarget:self action:@selector(tapEmojiView:) forControlEvents:UIControlEventTouchUpInside];
        
        
        CGFloat pointSize = 5 * RATIO;
        self.pointView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - pointSize, pointSize, pointSize)];
        self.pointView.backgroundColor = [UIColor whiteColor];
        [self.blueView addSubview:self.pointView];
        
        self.rcdView = [self getButtonWithFrameAndImage:smallFrame imageName:@"record"];
        [self.rcdView addTarget:self action:@selector(tapRcdView:) forControlEvents:UIControlEventTouchUpInside];
        
        self.ttsView = [self getButtonWithFrameAndImage:smallFrame imageName:@"text"];
        [self.ttsView addTarget:self action:@selector(tapTtsView:) forControlEvents:UIControlEventTouchUpInside];
        
        self.clearView = [self getButtonWithFrameAndImage:smallFrame imageName:@"delete"];
        [self.clearView addTarget:self action:@selector(tapClearView:) forControlEvents:UIControlEventTouchUpInside];
        
        self.checkView = [self getButtonWithFrameAndImage:smallFrame imageName:@"play"];
        [self.checkView addTarget:self action:@selector(tapCheckView:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.blueView addSubview:self.rcdView];
        [self.blueView addSubview:self.ttsView];
        [self.blueView addSubview:self.clearView];
        [self.blueView addSubview:self.checkView];
        [self.blueView addSubview:self.emojiView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        //键盘将隐藏事件监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self saveTTSString:(UIButton*)[self viewWithTag:99]];
    return YES;
}

- (void)handleKeyboardWillShow:(NSNotification *)notification {
    if (editingOrNot) {
        [Animation moveViewForEditing:self.ttsEditView orNot:editingOrNot];
        editingOrNot = !editingOrNot;
    }
    
}

- (void)handleKeyboardWillHide:(NSNotification *)notification {
    if (!editingOrNot) {
        [Animation moveViewForEditing:self.ttsEditView orNot:editingOrNot];
        editingOrNot = !editingOrNot;
    }
}


- (void)showOptionView:(NSString *)emojiIndex frame:(CGRect)frame isHidden:(BOOL)isHidden
{
    CGFloat correctX = frame.origin.x;
    while (correctX>=EMOJI_BOARD_WIDTH) {
        correctX = correctX - EMOJI_BOARD_WIDTH;
    }
    frame.origin.x = correctX;
    self.blueView.frame = frame;
    self.tempFrame = frame;
    self.pointView.hidden = isHidden;
    
    [self.emojiView setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"emoji_%@.png", emojiIndex]] forState:UIControlStateNormal];
    
    CGRect longFrame = CGRectMake(0, frame.origin.y, EMOJI_BOARD_WIDTH, frame.size.height);
    int multiple = round(frame.origin.x/frame.size.width);
    //int multiple = multipleWithSeven%7;
    CGFloat imgWidth = frame.size.height - PADDING_SIZE * 2;
    CGFloat pointSize = 5 * RATIO;
    CGRect emojiFrame = CGRectMake(frame.origin.x+PADDING_SIZE,PADDING_SIZE,imgWidth,imgWidth);
    CGRect pointFrame = CGRectMake(frame.origin.x, frame.size.height - pointSize, pointSize, pointSize);
    CGRect rcdFrame = CGRectMake(PADDING_SIZE, PADDING_SIZE, imgWidth, imgWidth);
    CGRect ttsFrame = CGRectMake(PADDING_SIZE, PADDING_SIZE, imgWidth, imgWidth);
    CGRect checkFrame = CGRectMake(PADDING_SIZE, PADDING_SIZE, imgWidth, imgWidth);
    CGRect clearFrame = CGRectMake(PADDING_SIZE, PADDING_SIZE, imgWidth, imgWidth);
    
    if (multiple == 2 || multiple == 3 || multiple == 4) {
        rcdFrame = CGRectMake(PADDING_SIZE+FACE_ICON_SIZE*(multiple-2), PADDING_SIZE, imgWidth, imgWidth);
        ttsFrame = CGRectMake(PADDING_SIZE+FACE_ICON_SIZE*(multiple-1), PADDING_SIZE, imgWidth, imgWidth);
        checkFrame = CGRectMake(PADDING_SIZE+FACE_ICON_SIZE*(multiple+1), PADDING_SIZE, imgWidth, imgWidth);
        clearFrame = CGRectMake(PADDING_SIZE+FACE_ICON_SIZE*(multiple+2), PADDING_SIZE, imgWidth, imgWidth);
    }else if (multiple == 0 || multiple == 1){
        if (multiple == 0) {
            rcdFrame = CGRectMake(PADDING_SIZE+FACE_ICON_SIZE, PADDING_SIZE, imgWidth, imgWidth);
        }else if (multiple == 1){
            rcdFrame = CGRectMake(PADDING_SIZE+FACE_ICON_SIZE * 2, PADDING_SIZE, imgWidth, imgWidth);
        }
        ttsFrame = CGRectMake(PADDING_SIZE+FACE_ICON_SIZE*(multiple + 2), PADDING_SIZE, imgWidth, imgWidth);
        checkFrame = CGRectMake(PADDING_SIZE+FACE_ICON_SIZE*(multiple + 3), PADDING_SIZE, imgWidth, imgWidth);
        clearFrame = CGRectMake(PADDING_SIZE+FACE_ICON_SIZE*(multiple + 4), PADDING_SIZE, imgWidth, imgWidth);
    }else if (multiple == 5 || multiple == 6){
        if (multiple == 5) {
            clearFrame = CGRectMake(PADDING_SIZE+FACE_ICON_SIZE*4, PADDING_SIZE, imgWidth, imgWidth);
        }else if (multiple == 6){
            clearFrame = CGRectMake(PADDING_SIZE+FACE_ICON_SIZE*5, PADDING_SIZE, imgWidth, imgWidth);
        }
        rcdFrame = CGRectMake(PADDING_SIZE+FACE_ICON_SIZE*(multiple - 4), PADDING_SIZE, imgWidth, imgWidth);
        ttsFrame = CGRectMake(PADDING_SIZE+FACE_ICON_SIZE*(multiple - 3), PADDING_SIZE, imgWidth, imgWidth);
        checkFrame = CGRectMake(PADDING_SIZE+FACE_ICON_SIZE*(multiple - 2), PADDING_SIZE, imgWidth, imgWidth);
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.blueView.frame = longFrame;
        self.emojiView.frame = emojiFrame;
        self.pointView.frame = pointFrame;
        self.rcdView.frame = rcdFrame;
        self.ttsView.frame = ttsFrame;
        self.checkView.frame = checkFrame;
        self.clearView.frame = clearFrame;
    }];
    self.menuActive = YES;
    [self isRecord:!isHidden];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //string就是此时输入的那个字符textField就是此时正在输入的那个输入框返回YES就是可以改变输入框的值NO相反

    NSString *toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    
    if (self.ttsEditView == textField)  //判断是否时我们想要限定的那个输入框
    {
        if ([toBeString length] > 12) { //如果输入框内容大于20则弹出警告
            return NO;
        }
    }
    return YES;
}

-(UIButton *)getButtonWithFrameAndImage:(CGRect)frame imageName:(NSString *)imageName
{
    UIButton *newButton = [[UIButton alloc] initWithFrame:frame];
    [newButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [newButton setTitle:@"" forState:UIControlStateNormal];
    return newButton;
}

- (void)tapShadowView:(UITapGestureRecognizer *)sender {
    if (self.menuActive) {
        [self disAppearOptionalView];
        [self.delegate tapShadowArea];
    }
}

- (void)tapEmojiView:(UIButton *)sender {
    if (self.menuActive) {
        [self disAppearOptionalView];
        [self.delegate tapShadowArea];
    }
}

- (void)tapRcdView:(UIButton *)sender {
    if (self.menuActive) {
        self.menuActive = NO;
        [self.delegate tapRcdButton];
    }
}

- (void)tapTtsView:(UIButton *)sender {
    if (self.menuActive) {
        self.menuActive = NO;
        [self.delegate tapTTSButton];
    }
}

- (void)tapClearView:(UIButton *)sender {
    if (self.menuActive) {
        self.menuActive = NO;
        [self.delegate tapClearButton];
    }
}

- (void)tapCheckView:(UIButton *)sender {
    if (self.menuActive) {
        self.menuActive = NO;
        [self.delegate tapCheckButton];
    }
}

- (void)saveTTSString:(UIButton *)sender {
    [(UITextField *)[self.ttsEditView viewWithTag:97] resignFirstResponder];
    [self.delegate confrimTTS:((UITextField *)[self.ttsEditView viewWithTag:97]).text];
}

- (void)UndoTTSString:(UIButton *)sender {
    [(UITextField *)[self.ttsEditView viewWithTag:97] resignFirstResponder];
    [self.delegate closeTTS];
    [self hiddenttsEditView];
}

- (void)hiddenttsEditView {
    self.ttsEditView.hidden = YES;
}

- (void)showttsEditView:(NSString *)ttsString {
    ((UITextField *)[self.ttsEditView viewWithTag:97]).text = ttsString;
    self.ttsEditView.hidden = NO;
}

- (void)hiddenPointView {
    self.pointView.hidden = YES;
}

- (void)showPointView {
    self.pointView.hidden = NO;
}

- (void)disAppearOptionalView {
    self.menuActive = NO;
    CGFloat imgWidth = FACE_ICON_SIZE - PADDING_SIZE * 2;
    CGFloat pointSize = 5 * RATIO;
    CGRect pointFrame = CGRectMake(0, FACE_ICON_SIZE - pointSize, pointSize, pointSize);
    CGRect zeroFrame = CGRectMake(PADDING_SIZE, PADDING_SIZE, imgWidth, imgWidth);
    [UIView animateWithDuration:0.2 animations:^{
        self.blueView.frame = self.tempFrame;
        self.emojiView.frame = zeroFrame;
        self.pointView.frame = pointFrame;
        self.rcdView.frame = zeroFrame;
        self.ttsView.frame = zeroFrame;
        self.checkView.frame = zeroFrame;
        self.clearView.frame = zeroFrame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)isRecord:(BOOL)isRecord {
    if (isRecord) {
        self.clearView.enabled = YES;
        self.checkView.enabled = YES;
    }else{
        self.clearView.enabled = NO;
        self.checkView.enabled = NO;
    }
}

- (void)ttsBegin {
    self.ttsView.enabled = YES;
    self.rcdView.enabled = NO;
    self.clearView.enabled = NO;
    self.checkView.enabled = NO;
}

- (void)ttsrcdEnd:(BOOL)isRecord {
    self.ttsView.enabled = YES;
    self.rcdView.enabled = YES;
    [self isRecord:isRecord];
}

- (void)rcdBegin {
    self.rcdView.enabled = YES;
    self.ttsView.enabled = NO;
    self.clearView.enabled = NO;
    self.checkView.enabled = NO;
}

@end
