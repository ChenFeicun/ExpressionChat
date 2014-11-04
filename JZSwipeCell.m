//
// JZSwipeCell.m
//
// Copyright (C) 2013 Jeremy Zedell
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is furnished
// to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "JZSwipeCell.h"

static CGFloat const kIconHorizontalPadding = 10;
static CGFloat const kMaxBounceAmount = 8;
static CGFloat const kDefaultIconSize = 40;
@interface JZSwipeCell()

@property (nonatomic, strong) UIPanGestureRecognizer *gesture;
@property (nonatomic, assign) CGFloat dragStart;
@property (nonatomic, assign) JZSwipeType currentSwipe;
@end

@implementation JZSwipeCell

- (id)init
{
	self = [super init];
    if (self) {
		[self configureCell];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		[self configureCell];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self ) {
		[self configureCell];
	}
	
	return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self configureCell];
}

- (void)prepareForReuse
{
	[super prepareForReuse];
	self.contentView.center = CGPointMake(self.contentView.frame.size.width / 2, self.contentView.center.y);
	self.currentSwipe = JZSwipeTypeNone;
}

#pragma mark - Public methods

- (void)triggerSwipeWithType:(JZSwipeType)type
{
    if ([self.delegate respondsToSelector:@selector(swipeCell:triggeredSwipeWithType:)])
        [self.delegate swipeCell:self triggeredSwipeWithType:type];
    self.dragStart = CGFLOAT_MIN;
	//[self runSwipeAnimationForType:type];
}

#pragma mark - Private methods

- (void)configureCell
{
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	
	if (!self.contentView.backgroundColor)
		self.contentView.backgroundColor = [UIColor clearColor];
	
    if (!self.icon)
    {
        self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kDefaultIconSize, kDefaultIconSize)];
        [self addSubview:self.icon];
    }
    
	self.gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHappened:)];
	self.gesture.delegate = self;
	[self.contentView addGestureRecognizer:self.gesture];
	
	self.defaultBackgroundColor = [UIColor clearColor];
	
	if (!self.backgroundView)
	{
		self.backgroundView = [[UIView alloc] init];
		self.backgroundView.backgroundColor = self.defaultBackgroundColor;
	}
}

- (void)gestureHappened:(UIPanGestureRecognizer *)sender
{
	CGPoint translatedPoint = [sender translationInView:self];
	switch (sender.state)
	{
		case UIGestureRecognizerStatePossible:
			
			break;
		case UIGestureRecognizerStateBegan:
			self.dragStart = sender.view.center.x;
			break;
		case UIGestureRecognizerStateChanged:
			self.contentView.center = CGPointMake(self.dragStart + translatedPoint.x, self.contentView.center.y);
			CGFloat diff = translatedPoint.x;
			
			JZSwipeType originalSwipe = self.currentSwipe;
			
            //需要添加 alpha的改变
            if (diff > 0) {
                if (diff >= self.contentView.bounds.size.width / 2) {
                    self.currentSwipe = JZSwipeTypeLongRight;
                } else {
                    self.currentSwipe = JZSwipeTypeNone;
                }
            } else if (diff < 0)  {
                if (diff <= -self.contentView.bounds.size.width / 2) {
                    self.currentSwipe = JZSwipeTypeLongLeft;
                } else {
                    self.currentSwipe = JZSwipeTypeNone;
                }
            }
            
			if (originalSwipe != self.currentSwipe)
			{
				if ([self.delegate respondsToSelector:@selector(swipeCell:swipeTypeChangedFrom:to:)])
					[self.delegate swipeCell:self swipeTypeChangedFrom:originalSwipe to:self.currentSwipe];
			}
			
			break;
		case UIGestureRecognizerStateEnded:
			if (self.currentSwipe != JZSwipeTypeNone)
                [self runSwipeAnimationForType:self.currentSwipe];
			else
				[self runBounceAnimationFromPoint:translatedPoint];
			break;
		case UIGestureRecognizerStateCancelled:
			
			break;
		case UIGestureRecognizerStateFailed:
			
			break;
	}
}


- (void)runSwipeAnimationForType:(JZSwipeType)type
{
    CGFloat newIconCenterX = 0;
    CGFloat newViewCenterX = 0;
    CGFloat iconAlpha = 1;
    
    if ([self isRightSwipeType:type])
    {
        self.icon.center = CGPointMake(self.contentView.center.x - ((self.contentView.frame.size.width / 2) + (self.icon.frame.size.width / 2) + kIconHorizontalPadding), self.contentView.frame.size.height / 2);
        newIconCenterX = self.frame.size.width + (self.icon.frame.size.width / 2) + kIconHorizontalPadding;
        newViewCenterX = newIconCenterX + (self.contentView.frame.size.width / 2) + (self.icon.frame.size.width / 2) + kIconHorizontalPadding;
    }
    else if ([self isLeftSwipeType:type])
    {
        self.icon.center = CGPointMake(self.contentView.center.x + (self.contentView.frame.size.width / 2) + (self.icon.frame.size.width / 2) + kIconHorizontalPadding, self.contentView.frame.size.height / 2);
        newIconCenterX = -((self.icon.frame.size.width / 2) + kIconHorizontalPadding);
        newViewCenterX = newIconCenterX - ((self.contentView.frame.size.width / 2) + (self.icon.frame.size.width / 2) + kIconHorizontalPadding);
    }
    else
    {
        // non-bouncing swipe type none (unused)
        newIconCenterX = self.icon.center.x;
        newViewCenterX = self.dragStart;
        iconAlpha = 0;
    }
    
    [UIView animateWithDuration:0.25 delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.icon.center = CGPointMake(newIconCenterX, self.contentView.frame.size.height / 2);
                         self.contentView.center = CGPointMake(newViewCenterX, self.contentView.center.y);
                         self.icon.alpha = iconAlpha;
                     } completion:^(BOOL finished) {
                         if ([self.delegate respondsToSelector:@selector(swipeCell:triggeredSwipeWithType:)])
                             [self.delegate swipeCell:self triggeredSwipeWithType:type];
                         self.dragStart = CGFLOAT_MIN;
                     }];
}

- (void)runBounceAnimationFromPoint:(CGPoint)point
{
	CGFloat diff = point.x;
	CGFloat pct = diff / (self.icon.frame.size.width + (kIconHorizontalPadding * 2));
	CGFloat bouncePoint = pct * kMaxBounceAmount;
	CGFloat bounceTime1 = 0.25;
	CGFloat bounceTime2 = 0.15;
	
	[UIView animateWithDuration:bounceTime1 animations:^{
        self.contentView.center = CGPointMake(self.dragStart - bouncePoint, self.contentView.center.y);
        self.icon.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:bounceTime2 animations:^{
            self.contentView.center = CGPointMake(self.dragStart, self.contentView.center.y);
        } completion:^(BOOL finished) {
											  
        }];
    }];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
		return YES;
	
	CGPoint translation = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:self];
    return fabs(translation.y) < fabs(translation.x);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return self.gesture.state == UIGestureRecognizerStatePossible;
}

#pragma mark - Helper methods

- (BOOL)isRightSwipeType:(JZSwipeType)type
{
	return type == JZSwipeTypeLongRight;
}

- (BOOL)isLeftSwipeType:(JZSwipeType)type
{
	return type == JZSwipeTypeLongLeft;
}

@end

