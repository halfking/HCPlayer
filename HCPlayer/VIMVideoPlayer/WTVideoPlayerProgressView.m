//
//  WTVideoPlayerProgressView.m
//  Wutong
//
//  Created by HUANGXUTAO on 15/11/22.
//  Copyright © 2015年 HUANGXUTAO. All rights reserved.
//

#import "WTVideoPlayerProgressView.h"
#import <hccoren/base.h>
#import <HCBaseSystem/VDCItem.h>
#import <HCBaseSystem/VDCManager.h>
#import "player_config.h"

//#import "CHYSlider.h"
#define TAG_SCROLLRECT 98342

@implementation WTVideoPlayerProgressView
{
    BOOL needGradient_;
    BOOL isBuilded_;
    //    CHYSlider * slider_;
    BOOL isHandleHidden;
    //    UIProgressView * slider_;
    BOOL isRefreshing_;
    BOOL isCacheRefreshing_;
    CGPoint lastPoint_;
    CGFloat hideSeconds_;
    
    CGFloat progressStartPos_; //进度条的起始位置
    CGFloat progressLength_; //进度条的长度
    CGFloat lastTouchPoint_;
    
    dispatch_queue_t touchEventQueue_;
    
    BOOL isCanMove_;
    NSInteger objectMovingID_;
    CGPoint touchPointStart_;
    BOOL isMoving_;
    BOOL needPlaying_;
    CGFloat lastSecondsBeMoving_;
}
@synthesize totalSeconds,seconds;
@synthesize handleView;
@synthesize CacheKey;

- (id)initWithFrame:(CGRect)frame needGradient:(BOOL)needGradient
{
    if(self = [super initWithFrame:frame])
    {
        needGradient_ = needGradient;
        if (frame.size.width>frame.size.height) {
            [self setOrientation:Horizontal];
        }else{
            [self setOrientation:Vertical];
        }
        [self initSlider];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        if (frame.size.width>frame.size.height) {
            [self setOrientation:Horizontal];
        }else{
            [self setOrientation:Vertical];
        }
        needGradient_ = NO;
        [self initSlider];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        if (self.frame.size.width>self.frame.size.height) {
            [self setOrientation:Horizontal];
        }else{
            [self setOrientation:Vertical];
        }
        [self initSlider];
    }
    return self;
}
-(void)initSlider {
    isHandleHidden = NO;
    
    totalSeconds = 60;
    seconds = 0;
    CacheKey= nil;
    lastPoint_ = CGPointZero;
    hideSeconds_ = 5;
    progressLength_ = self.frame.size.width;
    
    _isCommentBtnShow = YES;
    
    self.trackBGView = [[UIView alloc] init];
    self.trackBGView.alpha = 0.3;
    self.playProgressView = [[UIView alloc] init];
    self.playProgressView.alpha = 0.3;
    self.cachingView = [[UIView alloc]init];
    self.cachingView.alpha = 0.3;
    
    {
        self.backMaskView = [[UIView alloc]initWithFrame:self.bounds];
        self.backMaskView.backgroundColor = [UIColor blackColor];
        self.backMaskView.alpha = 0.5;
        [self addSubview:self.backMaskView];
        
        self.gradientLayer = [self buildVerticalGradientLayer:YES];
        self.gradientLayer.frame = self.bounds;
        [self.layer addSublayer:self.gradientLayer];
        
        if (!needGradient_) {
            self.backMaskView.hidden = NO;
            self.gradientLayer.hidden = YES;
        } else {
            self.backMaskView.hidden = YES;
            self.gradientLayer.hidden = NO;
        }
    }
    
    {
        
        handleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"HCPlayer.bundle/progress_icon.png"]];
        handleView.backgroundColor = [UIColor clearColor];
        //        handleView.layer.cornerRadius = SLIDER_viewCornerRadius;
        //        handleView.layer.masksToBounds = YES;
    }
    //    if(self.orientation == Vertical)
    //    {
    //        self.handleView.frame = CGRectMake(SLIDER_borderWidth, 0-SLIDER_handleWidth/2, self.frame.size.width-SLIDER_borderWidth*2, SLIDER_handleWidth);
    //        self.backgroundView.frame =  CGRectMake((self.frame.size.width - SLIDER_progressHeight)/2,
    //                                                self.frame.size.height,
    //                                                SLIDER_progressHeight,
    //                                                0);
    //    }
    //    else
    {
        CGFloat left = 5;
        CGFloat top = 0;
        CGFloat height = self.frame.size.height;
        CGFloat width = self.frame.size.width;
        CGFloat widthForBtn = height >=50?50:height;
        
        progressLength_ -= left;
        
        {
            //guide
            self.GuideAudioBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.GuideAudioBtn.frame = CGRectMake(left, (height - 30)/2.0f, 60, 30);
            [self.GuideAudioBtn setImage:[UIImage imageNamed:@"HCPlayer.bundle/singopen.png"] forState:UIControlStateNormal];
            [self.GuideAudioBtn setImage:[UIImage imageNamed:@"HCPlayer.bundle/singclose.png"] forState:UIControlStateSelected];
            [self.GuideAudioBtn addTarget:self action:@selector(openGuideAudio:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.GuideAudioBtn];
            left += 60+15;
            progressLength_ -= 60+15;
        }
        
        {
            //播放
            self.playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.playOrPauseBtn.frame = CGRectMake(left, top, widthForBtn, widthForBtn);
            [self.playOrPauseBtn setImage:[UIImage imageNamed:@"HCPlayer.bundle/play_icon.png"] forState:UIControlStateNormal];
            [self.playOrPauseBtn setImage:[UIImage imageNamed:@"HCPlayer.bundle/pause_icon.png"] forState:UIControlStateSelected];
            [self.playOrPauseBtn addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.playOrPauseBtn];
            left += widthForBtn+15;
            progressLength_ -= widthForBtn+15;
        }
        
        CGFloat rightMargin = width;
        //显示录音按钮
        {
            //录音
            self.RecordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.RecordBtn.frame = CGRectMake(rightMargin - 50-10, (height - 50)/2.0f, 50, 50);
            [self.RecordBtn setImage:[UIImage imageNamed:@"HCPlayer.bundle/microphone2.png"] forState:UIControlStateNormal];
            [self.RecordBtn setImage:[UIImage imageNamed:@"HCPlayer.bundle/microphone2.png"] forState:UIControlStateSelected];
            [self.RecordBtn addTarget:self action:@selector(willRecord:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.RecordBtn];
            if(self.isRecordButtonShow)
            {
                progressLength_ -= 10 + 50;
                rightMargin -= 50+10;
            }
            else
            {
                self.RecordBtn.hidden = YES;
            }
        }
        
        {
            //放大缩小
            self.MaxMinSizeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.MaxMinSizeBtn.frame = CGRectMake( rightMargin - widthForBtn - 10, top, widthForBtn, widthForBtn);
            [self.MaxMinSizeBtn setImage:[UIImage imageNamed:@"HCPlayer.bundle/fullscreen_icon.png"] forState:UIControlStateNormal];
            [self.MaxMinSizeBtn setImage:[UIImage imageNamed:@"HCPlayer.bundle/narrow_icon.png"] forState:UIControlStateSelected];
            [self.MaxMinSizeBtn addTarget:self action:@selector(doFullScreenOrNot:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.MaxMinSizeBtn];
            rightMargin -= widthForBtn  +15;
            progressLength_ -=  widthForBtn + 15;
        }
        
        //   弹幕
        {
            //放大缩小
            self.commentShowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.commentShowBtn.frame = CGRectMake( rightMargin - widthForBtn - 10, top, widthForBtn, widthForBtn);
            [self.commentShowBtn setImage:[UIImage imageNamed:@"HCPlayer.bundle/open_danmu.png"] forState:UIControlStateNormal];
            [self.commentShowBtn setImage:[UIImage imageNamed:@"HCPlayer.bundle/close_danmu.png"] forState:UIControlStateSelected];
            [self.commentShowBtn addTarget:self action:@selector(showCommentsOrNot:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.commentShowBtn];
            rightMargin -= widthForBtn  +15;
            progressLength_ -=  widthForBtn + 15;
        }
        
        //total seconds
        UIFont * textFont = FONT_STANDARD(11);
        NSDictionary *attributes = @{NSFontAttributeName: textFont};
        CGSize lableSize = [ @"00:00" sizeWithAttributes:attributes];
        lableSize.width += 5;
        
        {
            self.totalSecondsLabel = [[UILabel alloc]initWithFrame:CGRectMake(rightMargin - lableSize.width,(height - lableSize.height)/2.0f , lableSize.width, lableSize.height)];
            self.totalSecondsLabel.text = [CommonUtil getTimeStringOfTimeInterval:self.totalSeconds];
            self.totalSecondsLabel.backgroundColor = [UIColor clearColor];
            self.totalSecondsLabel.textColor = [UIColor whiteColor];//COLOR_CC;
            //self.totalSecondsLabel.shadowColor = COLOR_CF;
            //self.totalSecondsLabel.shadowOffset = CGSizeMake(0, 1);
            self.totalSecondsLabel.font = textFont;
            self.totalSecondsLabel.textAlignment = NSTextAlignmentRight;
            [self addSubview:self.totalSecondsLabel];
            progressLength_ -= lableSize.width + 10;
        }
        
        {
            self.currentSecondsLabel = [[UILabel alloc]initWithFrame:CGRectMake(left,(height - lableSize.height)/2.0f , lableSize.width, lableSize.height)];
            self.currentSecondsLabel.text = [CommonUtil getTimeStringOfTimeInterval:0];
            self.currentSecondsLabel.backgroundColor = [UIColor clearColor];
            self.currentSecondsLabel.textColor = [UIColor whiteColor];//COLOR_CC;
            //self.currentSecondsLabel.shadowColor = COLOR_CF;
            //self.currentSecondsLabel.shadowOffset = CGSizeMake(0, 1);
            self.currentSecondsLabel.font = textFont;
            self.currentSecondsLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:self.currentSecondsLabel];
            
            left += lableSize.width + 10;
            progressLength_ -= lableSize.width + 10;
            progressStartPos_ = left;
        }
        
        self.handleView.frame = CGRectMake( progressStartPos_ - SLIDER_handleWidth/2.0f,
                                           //                                           SLIDER_borderWidth,
                                           (height - SLIDER_handleWidth)/2.0f,
                                           SLIDER_handleWidth,
                                           SLIDER_handleWidth);
        //                                           height - SLIDER_borderWidth*2);
        self.trackBGView.frame = CGRectMake(progressStartPos_, (height - SLIDER_progressHeight)/2.0f,progressLength_, SLIDER_progressHeight);
    }
    [self addSubview:self.trackBGView];
    [self addSubview:self.cachingView];
    [self addSubview:self.playProgressView];
    
    [self addSubview:self.handleView];
    
    [self setSeconds:0.0 withAnimation:NO completion:nil];
    
    
    [self buildPanRec];
    
    //    [self setValue:0.0 withAnimation:NO completion:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCachingStatus:) name:NT_CACHEPROGRESS object:nil];
}
- (void)changeFrame:(CGRect)pframe
{
    self.frame = pframe;
    CGFloat left = 5;
    CGFloat top = 0;
    CGFloat height = self.frame.size.height;
    CGFloat width = self.frame.size.width;
    CGFloat widthForBtn = height >=50?50:height;
    CGFloat progressTop =  (height - SLIDER_progressHeight)/2.0f;
    CGFloat rightMargin = width;
    CGFloat cachingPosXRate = self.trackBGView.frame.size.width>0?self.cachingView.frame.size.width / self.trackBGView.frame.size.width:0;
    
    progressLength_ = width;
    progressStartPos_ = 0;
    
    progressLength_ -= left;
    if (!needGradient_)
        self.backMaskView.frame = self.bounds;
    else
        self.gradientLayer.frame = self.bounds;
    
    if(self.isGuidAudioShow && (self.GuideAudioBtn && self.GuideAudioBtn.hidden==NO)){
        self.GuideAudioBtn.frame = CGRectMake(left, (height - 30)/2.0f, 60, 30);
        left += 60+15;
        progressLength_ -= 60+15;
    }
    else
    {
        [self setGuidAudio:NO];
    }
    if(self.playOrPauseBtn.hidden==NO){
        self.playOrPauseBtn.frame = CGRectMake(left, top, widthForBtn, widthForBtn);
        left += widthForBtn+15;
        progressLength_ -= widthForBtn+15;
    }
    
    
    
    //显示录音按钮
    if(self.isRecordButtonShow)
    {
        //录音
        self.RecordBtn.frame = CGRectMake(rightMargin - 50-10, (height - 50)/2.0f, 50, 50);
        progressLength_ -= 10 + 50;
        rightMargin -= 50+10;
    }
    else
    {
        self.RecordBtn.hidden = YES;
    }
    
    {
        //放大缩小
        self.MaxMinSizeBtn.frame = CGRectMake( rightMargin - widthForBtn, top, widthForBtn, widthForBtn);
        
        if(self.isCommentBtnShow)
        {
            progressLength_ -=  widthForBtn + 10;
            rightMargin -= widthForBtn;
        }
        else
        {
            progressLength_ -=  widthForBtn + 10;
        rightMargin -= widthForBtn +10;
        }
        
    }
    if(self.isCommentBtnShow)
    {
        //弹幕
        self.commentShowBtn.frame = CGRectMake(rightMargin - widthForBtn, (height - widthForBtn)/2.0f, widthForBtn, widthForBtn);
        progressLength_ -= 15 + widthForBtn;
        rightMargin -= widthForBtn +15;
    }
    else
    {
        self.commentShowBtn.hidden = YES;
    }

    //total seconds
    UIFont * textFont = FONT_STANDARD(11);
    NSDictionary *attributes = @{NSFontAttributeName: textFont};
    CGSize lableSize = [ @"00:00" sizeWithAttributes:attributes];
    lableSize.width += 5;
    
    {
        self.totalSecondsLabel.frame = CGRectMake(rightMargin - lableSize.width,(height - lableSize.height)/2.0f , lableSize.width, lableSize.height);
        progressLength_ -= lableSize.width + 10;
    }
    
    
    {
        self.currentSecondsLabel.frame = CGRectMake(left,(height - lableSize.height)/2.0f , lableSize.width, lableSize.height);
        
        left += lableSize.width + 10;
        progressLength_ -= lableSize.width + 10;
        progressStartPos_ = left;
    }
    
    
    
    
    self.handleView.frame = CGRectMake( progressStartPos_ - SLIDER_handleWidth/2.0f + seconds/totalSeconds * progressLength_,
                                       //                                           SLIDER_borderWidth,
                                       (height - SLIDER_handleWidth)/2.0f,
                                       SLIDER_handleWidth,
                                       SLIDER_handleWidth);
    
    //    self.handleView.frame = CGRectMake( progressStartPos_ -SLIDER_handleWidth/2,
    //                                       SLIDER_borderWidth,
    //                                       SLIDER_handleWidth,
    //                                       height - SLIDER_borderWidth*2);
    self.trackBGView.frame = CGRectMake(progressStartPos_, progressTop,progressLength_, SLIDER_progressHeight);
    
    self.cachingView.frame = CGRectMake(progressStartPos_, progressTop, cachingPosXRate * progressLength_ , SLIDER_progressHeight);
    self.playProgressView.frame = CGRectMake(progressStartPos_, progressTop, seconds/totalSeconds * progressLength_, SLIDER_progressHeight);
    
}
- (void)setHandleView:(UIView *)pHandleView
{
    if(!pHandleView) return;
    
    CGRect orgFrame = self.handleView.frame;
    CGRect newFrame = pHandleView.frame;
    newFrame.origin.x = orgFrame.origin.x + (orgFrame.size.width - newFrame.size.width)/2.0f;
    newFrame.origin.y = orgFrame.origin.y + (orgFrame.size.height - newFrame.size.height)/2.0f;
    
    
    PP_RELEASE(handleView);
    handleView = PP_RETAIN(pHandleView);
    handleView.frame = newFrame;
}
- (void)showCachingStatus:(NSNotification *)notification
{
    if(isCacheRefreshing_) return;
    isCacheRefreshing_ = YES;
    VDCItem * item = notification.object;
    if(item && item.contentLength>0 && [item.key isEqualToString:CacheKey])
    {
        CGFloat multiX = (CGFloat)item.downloadBytes/item.contentLength;
        if(multiX >1 ) multiX = 1;
        else if(multiX <0) multiX = 0;
        CGPoint point;
        switch (self.orientation) {
            case Vertical:
                point = CGPointMake(0, (1- multiX) * progressLength_);
                break;
            case Horizontal:
                point = CGPointMake(multiX * progressLength_, 0);
                break;
            default:
                break;
        }
        if([NSThread isMainThread])
        {
            [self changeDownloadProgressViewWithPoint:point];
            isCacheRefreshing_ = NO;
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^(void)
                           {
                               [self changeDownloadProgressViewWithPoint:point];
                               isCacheRefreshing_ = NO;
                           });
        }
    }
}
- (void)setIsPlaying:(BOOL)isPlayingA
{
    if([NSThread isMainThread])
    {
        _isPlaying = isPlayingA;
        if(isPlayingA)
        {
            self.playOrPauseBtn.selected = YES;
        }
        else
        {
            self.playOrPauseBtn.selected = NO;
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self setIsPlaying:isPlayingA];
                       });
    }
    
}
- (void)setIsCommentShow:(BOOL)isShowA
{
    if([NSThread isMainThread])
    {
        if(isShowA)
        {
            self.commentShowBtn.selected = YES;
        }
        else
        {
            self.commentShowBtn.selected = NO;
        }
//        BOOL isShow = self.commentShowBtn.isSelected;
//        if(self.delegate && [self.delegate respondsToSelector:@selector(videoProgress:showComments:)])
//        {
//            [self.delegate videoProgress:self showComments:isShow];
//        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self setIsCommentShow:isShowA];
                       });
    }
}
- (void)setIsCommentBtnShow:(BOOL)isShowA
{
    if([NSThread isMainThread])
    {
        if(isShowA != self.commentShowBtn.hidden) return;
        
        if(isShowA)
        {
            self.commentShowBtn.hidden = NO;
        }
        else
        {
            self.commentShowBtn.hidden = YES;
        }
        [self changeFrame:self.frame];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self setIsCommentBtnShow:isShowA];
                       });
    }
}
- (void)setIsFullScreen:(BOOL)isFullScreenA
{
    if([NSThread isMainThread])
    {
        _isFullScreen = isFullScreenA;
        if(isFullScreenA)
        {
            self.MaxMinSizeBtn.selected = YES;
            //self.backMaskView.hidden = NO;
            //            if (!needGradient_)
            //                self.backMaskView.hidden = NO;
            //            else
            //                self.gradientLayer.hidden = NO;
        }
        else
        {
            self.MaxMinSizeBtn.selected = NO;
            //self.backMaskView.hidden = YES;
            //            if (!needGradient_)
            //                self.backMaskView.hidden = YES;
            //            else
            //                self.gradientLayer.hidden = YES;
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self setIsFullScreen:isFullScreenA];
                       });
    }
}
- (void)setSeconds:(CGFloat)aseconds withAnimation:(bool)isAnimate completion:(void (^)(BOOL finished))completion
{
    //    NSAssert((aseconds >= 0.0)&&(aseconds <= totalSeconds), @"Value must be between 0.0 and 1.0");
    CGFloat orgSeconds = seconds;
    if (aseconds < 0) {
        seconds = 0;
    }
    
    if (aseconds > totalSeconds) {
        seconds = totalSeconds;
    }
    else
    {
        seconds = aseconds;
    }
    if(isRefreshing_) return;
    isRefreshing_ = YES;
    CGPoint point;
    //    switch (self.orientation) {
    //        case Vertical:
    //            point = CGPointMake(0, (1-seconds/totalSeconds) * progressLength_);
    //            break;
    //        case Horizontal:
    point = CGPointMake(seconds/totalSeconds * progressLength_, 0);
    //            break;
    //        default:
    //            break;
    //    }
    if(fabs(point.x - lastPoint_.x) >= 0.5|| fabs(orgSeconds - seconds)>=1)
    {
        lastPoint_ = point;
    }
    else
    {
        isRefreshing_ = NO;
        return;
    }
    //    NSLog(@"progress... %.2f   --- > %.2f",aseconds,totalSeconds);
    if([NSThread isMainThread])
    {
        if(isAnimate) {
            __weak __typeof(self)weakSelf = self;
            
            [UIView animateWithDuration:SLIDER_animationSpeed animations:^ {
                [weakSelf changeStarForegroundViewWithPoint:point];
                
            } completion:^(BOOL finished) {
                isRefreshing_ = NO;
                if (completion) {
                    completion(finished);
                }
            }];
        } else {
            [self changeStarForegroundViewWithPoint:point];
            isRefreshing_ = NO;
        }
        if(seconds>=0)
            self.currentSecondsLabel.text = [CommonUtil getTimeStringOfTimeInterval:seconds];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           if(isAnimate) {
                               __weak __typeof(self)weakSelf = self;
                               
                               [UIView animateWithDuration:SLIDER_animationSpeed animations:^ {
                                   [weakSelf changeStarForegroundViewWithPoint:point];
                                   
                               } completion:^(BOOL finished) {
                                   isRefreshing_ = NO;
                                   if (completion) {
                                       completion(finished);
                                   }
                               }];
                           } else {
                               [self changeStarForegroundViewWithPoint:point];
                               isRefreshing_ = NO;
                           }
                           if(seconds>=0)
                               self.currentSecondsLabel.text = [CommonUtil getTimeStringOfTimeInterval:seconds];
                       });
    }
    
    
}
#pragma mark - Touch Events
- (void)willRecord:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(videoProgress:willRecode:)])
    {
        [self.delegate videoProgress:self willRecode:YES];
    }
}
- (void)openGuideAudio:(id)sender
{
    if([NSThread isMainThread])
    {
        [self.GuideAudioBtn setSelected:!self.GuideAudioBtn.isSelected];
        BOOL disableGuide = self.GuideAudioBtn.isSelected;
        if(self.delegate && [self.delegate respondsToSelector:@selector(videoProgress:openGuideAudio:)])
        {
            [self.delegate videoProgress:self openGuideAudio:!disableGuide];
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self openGuideAudio:nil];
                       });
    }
}
- (void)playOrPause:(id)sender
{
    if([NSThread isMainThread])
    {
        [self.playOrPauseBtn setSelected:!self.playOrPauseBtn.isSelected];
        BOOL isPlay = self.playOrPauseBtn.isSelected;
        if(isPlay)
        {
            if(self.delegate && [self.delegate respondsToSelector:@selector(videoProgress:playBegin:)])
            {
                [self.delegate videoProgress:self playBegin:seconds];
            }
        }
        else
        {
            if(self.delegate && [self.delegate respondsToSelector:@selector(videoProgress:pause:)])
            {
                [self.delegate videoProgress:self pause:seconds];
            }
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self playOrPause:nil];
                       });
    }
}
- (void)showCommentsOrNot:(id)sender
{
    if([NSThread isMainThread])
    {
        [self.commentShowBtn setSelected:!self.commentShowBtn.isSelected];
        BOOL isShow = self.commentShowBtn.isSelected;
            if(self.delegate && [self.delegate respondsToSelector:@selector(videoProgress:showComments:)])
            {
                [self.delegate videoProgress:self showComments:isShow];
            }
       
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self showCommentsOrNot:nil];
                       });
    }
}

- (void)doFullScreenOrNot:(id)sender
{
    if([NSThread isMainThread])
    {
        [self.MaxMinSizeBtn setSelected:self.isFullScreen];
        //        BOOL doMin = self.MaxMinSizeBtn.isSelected;
        if(self.delegate && [self.delegate respondsToSelector:@selector(videoProgress:willFullScreen:)])
        {
            [self.delegate videoProgress:self willFullScreen:!self.isFullScreen];
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self doFullScreenOrNot:nil];
                       });
    }
}
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"touch started ________");
//    [super touchesBegan:touches withEvent:event];
//
//    UITouch *touch = [touches anyObject];
//    CGPoint point = [touch locationInView:self];
//
//    if(point.x < progressStartPos_ || point.x > progressStartPos_ + progressLength_)
//    {
//        return;
//    }
//    else
//    {
////        lastPoint_ = CGPointMake(seconds/totalSeconds * progressLength_, 0);
////        lastTouchPoint_ = point.x;
//    }
//
////    if(self.delegate && [self.delegate respondsToSelector:@selector(videoProgress:progressChanged:)])
////    {
////        [self.delegate videoProgress:self progressChanged:-1];
////    }
//}
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [touches anyObject];
//    CGPoint point = [touch locationInView:self];
//    NSLog(@"movied:%@",NSStringFromCGPoint(point));
//    switch (self.orientation) {
//        case Vertical:
//            point.y -= progressStartPos_;
//            if (!(point.y < 0) && !(point.y > progressLength_)) {
//                [self changeStarForegroundViewWithPoint:point];
//            }
//            break;
//        case Horizontal:
//
////            point.x = lastPoint_.x + point.x - lastTouchPoint_ - progressStartPos_;
//            point.x -= progressStartPos_;
//            if (!(point.x < 0) && !(point.x > progressLength_)) {
//                [self changeStarForegroundViewWithPoint:point];
//            }
//            break;
//        default:
//            break;
//    }
//
//    if ((point.x >= 0) && point.x <= progressLength_-SLIDER_handleWidth) {
//        if (self.delegate && [self.delegate respondsToSelector:@selector(videoProgress:progressChanged:)]) {
//            [self.delegate videoProgress:self progressChanged:seconds];
//        }
//    }
//    hideSeconds_ = 5;
//}

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [touches anyObject];
//    CGPoint point = [touch locationInView:self];
//    NSLog(@"move end:%@",NSStringFromCGPoint(point));
//    if(point.x < progressStartPos_ || point.x > progressStartPos_ + progressLength_)
//    {
//        return;
//    }
//
////    __weak __typeof(self)weakSelf = self;
//
//    //    [UIView animateWithDuration:SLIDER_animationSpeed animations:^ {
//    switch (self.orientation) {
//        case Vertical:
//            point.y -= progressStartPos_;
//            if (!(point.y < 0) && !(point.y > progressLength_)) {
//                [self changeStarForegroundViewWithPoint:point];
//            }
//            break;
//        case Horizontal:
//            point.x -= progressStartPos_;
//            if (!(point.x < 0) && !(point.x > progressLength_)) {
//                [self changeStarForegroundViewWithPoint:point];
//            }
//            break;
//        default:
//            break;
//    }
//
//    //    [weakSelf changeStarForegroundViewWithPoint:point];
//
//    if ((point.x >= 0) && point.x <= progressLength_) {
//        if(self.delegate && [self.delegate respondsToSelector:@selector(videoProgress:playBegin:)])
//        {
//            NSLog(@"touch ended 2________");
//            [self.delegate videoProgress:self playBegin:seconds];
//        }
//    }
//}

#pragma mark - Change Slider Foreground With Point
//此处的Point为相对于进度起始点的位置
- (void)changeDownloadProgressViewWithPoint:(CGPoint)point {
    CGPoint p = point;
    
    switch (self.orientation) {
        case Vertical: {
            if (p.y < 0) {
                p.y = 0;
            }
            
            if (p.y > progressLength_) {
                p.y = progressLength_;
            }
            seconds = (1- p.x / progressLength_) * totalSeconds;
            if(seconds>totalSeconds) seconds  = totalSeconds;
            
            self.cachingView.frame = CGRectMake((self.frame.size.width - SLIDER_progressHeight)/2,
                                                progressStartPos_,
                                                SLIDER_progressHeight,
                                                p.y - progressStartPos_);
        }
            break;
        case Horizontal: {
            if (p.x < 0) {
                p.x = 0;
            }
            
            if (p.x > progressLength_) {
                p.x = progressLength_;
            }
            
            seconds = p.x / progressLength_ * totalSeconds;
            if(seconds>totalSeconds) seconds  = totalSeconds;
            self.cachingView.frame = CGRectMake(progressStartPos_, (self.frame.size.height - SLIDER_progressHeight)/2.0f, p.x, SLIDER_progressHeight);
        }
            break;
        default:
            break;
    }
}
- (void)changeStarForegroundViewWithPoint:(CGPoint)point {
    CGPoint p = point;
    
    switch (self.orientation) {
        case Vertical: {
            //            if (p.y < 0) {
            //                p.y = 0;
            //            }
            //
            //            if (p.y > progressLength_) {
            //                p.y = progressLength_;
            //            }
            //            seconds = (1- p.x / progressLength_) * totalSeconds;
            //            if(seconds>totalSeconds) seconds  = totalSeconds;
            //
            //            self.foregroundView.frame = CGRectMake((self.frame.size.width - SLIDER_progressHeight)/2,
            //                                                   progressStartPos_ + progressLength_ - p.y,
            //                                                   SLIDER_progressHeight,
            //                                                   p.y);;
            //
            //            if (!isHandleHidden) {
            //                if (self.foregroundView.frame.origin.y <= 0) {
            //                    self.handleView.frame = CGRectMake(SLIDER_borderWidth, 0 -SLIDER_handleWidth/2.0f, self.frame.size.width-SLIDER_borderWidth*2, SLIDER_handleWidth);
            //                }else if (self.foregroundView.frame.origin.y >= self.frame.size.height) {
            //                    self.handleView.frame = CGRectMake(SLIDER_borderWidth, self.frame.size.height-SLIDER_handleWidth/2, self.frame.size.width-SLIDER_borderWidth*2, SLIDER_handleWidth);
            //                }else{
            //                    self.handleView.frame = CGRectMake(SLIDER_borderWidth, self.frame.origin.y-SLIDER_handleWidth/2, self.frame.size.width-SLIDER_borderWidth*2, SLIDER_handleWidth);
            //                }
            //            }
        }
            break;
        case Horizontal: {
            if (p.x < 0) {
                p.x = 0;
            }
            
            if (p.x > progressLength_) {
                p.x = progressLength_;
            }
            
            seconds = p.x / progressLength_ * totalSeconds;
            if(seconds>totalSeconds) seconds  = totalSeconds;
            
            
            //播放进度
            self.playProgressView.frame = CGRectMake(progressStartPos_, (self.frame.size.height - SLIDER_progressHeight)/2.0f, p.x, SLIDER_progressHeight);
            
            if (!isHandleHidden) {
                if (self.playProgressView.frame.size.width <= 0)
                {
                    self.handleView.frame = CGRectMake( progressStartPos_ - SLIDER_handleWidth/2.0f,
                                                       //                                           SLIDER_borderWidth,
                                                       (self.frame.size.height - SLIDER_handleWidth)/2.0f,
                                                       SLIDER_handleWidth,
                                                       SLIDER_handleWidth);
                    
                    //                    self.handleView.frame = CGRectMake(progressStartPos_ - SLIDER_handleWidth/2,
                    //                                                       SLIDER_borderWidth,
                    //                                                       SLIDER_handleWidth,
                    //                                                       self.frame.size.height-SLIDER_borderWidth *2);
                }
                //                else if (self.foregroundView.frame.size.width >= progressLength_)
                //                {
                //                    self.handleView.frame = CGRectMake(progressStartPos_ + self.foregroundView.frame.size.width-SLIDER_handleWidth/2,
                //                                                       SLIDER_borderWidth,
                //                                                       SLIDER_handleWidth,
                //                                                       self.frame.size.height-SLIDER_borderWidth*2);
                //                }
                else
                {
                    //                    self.handleView.frame = CGRectMake(progressStartPos_ + self.playProgressView.frame.size.width-SLIDER_handleWidth/2,
                    //                                                       SLIDER_borderWidth,
                    //                                                       SLIDER_handleWidth,
                    //                                                       self.frame.size.height-SLIDER_borderWidth*2);
                    
                    self.handleView.frame = CGRectMake( progressStartPos_ + self.playProgressView.frame.size.width-SLIDER_handleWidth/2,
                                                       (self.frame.size.height - SLIDER_handleWidth)/2.0f,
                                                       SLIDER_handleWidth,
                                                       SLIDER_handleWidth);
                }
            }
        }
            break;
        default:
            break;
    }
}
- (void) setTotalSeconds:(CGFloat)atotalSeconds
{
    if(atotalSeconds<=0 || isnan(atotalSeconds)) return;
    totalSeconds = atotalSeconds;
    
    self.totalSecondsLabel.text = [CommonUtil getTimeStringOfTimeInterval:atotalSeconds];
}

- (void) show:(BOOL)animates autoHide:(BOOL)autoHide
{
    if([NSThread isMainThread])
    {
    if(self.alpha==1 && self.hidden==NO)
    {
        hideSeconds_ = 10;
        if(autoHide)
            [self checkHideProgress];
        return;
    }
    if(animates)
    {
        self.alpha = 0;
        self.hidden = NO;
        [UIView animateWithDuration:0.35 animations:^(void)
         {
             self.alpha = 1;
         } completion:^(BOOL finished)
         {
             
         }];
    }
    else
    {
        self.alpha = 1;
        self.hidden = NO;
    }
    hideSeconds_ = 10;
    if(autoHide)
        [self checkHideProgress];
    if(self.delegate && [self.delegate respondsToSelector:@selector(videoProgress:didHidden:)])
    {
        [self.delegate videoProgress:self didHidden:NO];
    }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(),^(void)
                       {
                           [self show:animates autoHide:autoHide];
                       }
        );
    }
}
- (void)checkHideProgress
{
    __weak WTVideoPlayerProgressView * weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        hideSeconds_ --;
        if(hideSeconds_<=0)
        {
            [weakSelf hide:YES];
        }
        else
        {
            [self checkHideProgress];
        }
    });
}
- (void) hide:(BOOL)animates
{
    if(self.hidden) return;
    if(self.alpha==0)
    {
        self.hidden= YES;
        self.alpha = 1;
        return;
    }
    if(animates)
    {
        self.alpha = 1;
        self.hidden = NO;
        
        [UIView animateWithDuration:0.35 animations:^(void)
         {
             self.alpha = 0;
         } completion:^(BOOL finished)
         {
             self.hidden = YES;
             self.alpha = 1;
         }];
    }
    else
    {
        self.alpha = 1;
        self.hidden = YES;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(videoProgress:didHidden:)])
    {
        [self.delegate videoProgress:self didHidden:YES];
    }
}
#pragma mark - Other methods
- (CGFloat)getProgressWidth
{
    return progressLength_;
}
-(void)setOrientation:(PR_Orientation)orientation {
    _orientation = orientation;
}

-(void)setColorsForBackground:(UIColor *)bCol foreground:(UIColor *)fCol caching:(UIColor *)cCol handle:(UIColor *)hCol border:(UIColor *)brdrCol
{
    //if (!needGradient_) {
    self.backgroundColor = [UIColor clearColor];
    self.backMaskView.backgroundColor = [UIColor blackColor];
    //}
    
    self.playProgressView.backgroundColor = fCol;
    self.handleView.backgroundColor = hCol;
    self.cachingView.backgroundColor = cCol;
    self.trackBGView.backgroundColor = bCol;// [UIColor yellowColor];
    [self.layer setBorderColor:brdrCol.CGColor];
}

-(void)removeRoundCorners:(BOOL)corners removeBorder:(BOOL)borders {
    if (corners) {
        self.layer.cornerRadius = 0.0;
        self.layer.masksToBounds = YES;
    }
    if (borders) {
        [self.layer setBorderWidth:0.0];
    }
}

-(void)hideHandle {
    self.handleView.hidden = YES;
    isHandleHidden = YES;
    [self.handleView removeFromSuperview];
}
- (void)setIsGuidAudioShow:(BOOL)isGuidAudioShow
{
    _isGuidAudioShow = isGuidAudioShow;
    if(!isGuidAudioShow)
    {
        self.GuideAudioBtn.hidden = YES;
    }
    else
    {
        self.GuideAudioBtn.hidden = NO;
    }
}
- (void)setGuidAudio:(BOOL)isGuideOpen
{
    [self.GuideAudioBtn setSelected:!isGuideOpen];
    if(!self.isGuidAudioShow)
    {
        self.GuideAudioBtn.hidden = YES;
    }
    else
    {
        self.GuideAudioBtn.hidden = NO;
    }
}
- (BOOL)useGuideAudio
{
    return !self.GuideAudioBtn.isSelected;
}
- (void)setIsRecordButtonShow:(BOOL)pisRecordButtonShow
{
    _isRecordButtonShow = pisRecordButtonShow;
    if(self.RecordBtn)
    {
        if(self.RecordBtn.hidden==NO) return;
        else
            self.RecordBtn.hidden = NO;
    }
    else
    {
        
    }
    //外面会主动调用，因此不需要再处理
    //    [self changeFrame:self.frame];
}

- (CAGradientLayer *)buildVerticalGradientLayer:(BOOL)gradientDark
{
    //初始化渐变层
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    //gradientLayer.frame = view.bounds;
    //[view.layer addSublayer:gradientLayer];
    
    //设置渐变颜色方向
    if (gradientDark) {
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1);
    } else {
        gradientLayer.startPoint = CGPointMake(0, 1);
        gradientLayer.endPoint = CGPointMake(0, 0);
    }
    
    //设定颜色组
    gradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor,
                             (__bridge id)[UIColor colorWithWhite:0 alpha:0.5].CGColor];
    
    //设定颜色分割点
    gradientLayer.locations = @[@(0.0f) ,@(1.0f)];
    
    return gradientLayer;
}
#pragma mark - pan moving
-(void)buildPanRec
{
    self.userInteractionEnabled = YES;
    {
        UIPanGestureRecognizer * panRecognizer_ = [[UIPanGestureRecognizer alloc]initWithTarget:self
                                                                                         action:@selector(paningGestureReceive:)];
        panRecognizer_.delaysTouchesBegan = NO;
        panRecognizer_.delaysTouchesEnded = NO;
        panRecognizer_.cancelsTouchesInView = NO;
        [self addGestureRecognizer:panRecognizer_];
        PP_RELEASE(panRecognizer_);
    }
    {
        UITapGestureRecognizer * tapRec = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapRecReceive:)];
        [self addGestureRecognizer:tapRec];
        tapRec.numberOfTapsRequired = 1;
        PP_RELEASE(tapRec);
    }
    
}
- (void)tapRecReceive:(UITapGestureRecognizer*)rec {
    CGPoint point = [rec locationInView:self];
    NSLog(@"move end:%@",NSStringFromCGPoint(point));
    if(point.x < progressStartPos_ || point.x > progressStartPos_ + progressLength_)
    {
        return;
    }
    
    //    __weak __typeof(self)weakSelf = self;
    
    //    [UIView animateWithDuration:SLIDER_animationSpeed animations:^ {
    switch (self.orientation) {
        case Vertical:
            point.y -= progressStartPos_;
            if (!(point.y < 0) && !(point.y > progressLength_)) {
                [self changeStarForegroundViewWithPoint:point];
            }
            break;
        case Horizontal:
            point.x -= progressStartPos_;
            if (!(point.x < 0) && !(point.x > progressLength_)) {
                [self changeStarForegroundViewWithPoint:point];
            }
            break;
        default:
            break;
    }
    
    //    [weakSelf changeStarForegroundViewWithPoint:point];
    
    if ((point.x >= 0) && point.x <= progressLength_) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(videoProgress:playBegin:)])
        {
            NSLog(@"touch ended 2________");
            [self.delegate videoProgress:self playBegin:seconds];
        }
    }
}
- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer
{
    if(![self isFullScreen]) return;
    isCanMove_ = YES;
    
    CGPoint touchPoint = [recoginzer locationInView:self];
    if(isCanMove_)
    {
        [self moveWithPan:touchPoint state:recoginzer.state];
    }
}

- (void)moveWithPan:(CGPoint)point  state:(UIGestureRecognizerState)state
{
    CGPoint touchPoint = point;// [recoginzer locationInView:KEY_WINDOW];
    
    if (state == UIGestureRecognizerStateBegan)
    {
        [self beginMoving:point];
    }
    else if (state == UIGestureRecognizerStateEnded){
        [self moveDone:point];
        return;
        // cancal panning, alway move to left side automatically
    }else if (state == UIGestureRecognizerStateCancelled){
        return;
    }
    
    if (isMoving_ && objectMovingID_>=0) {
        [self moveTrackObjectInView:touchPoint viewID:objectMovingID_];
    }
    else if(!isMoving_ && objectMovingID_<0)
    {
        NSInteger currentTag = [self locationViewMoving:point];
        if(currentTag>0)
        {
            [self beginMoving:point];
        }
    }
}
- (void)    beginMoving:(CGPoint)point
{
    objectMovingID_ = [self locationViewMoving:point];
    if(objectMovingID_<0)
    {
        isMoving_ = NO;
        return;
    }
    
    NSLog(@"begin move...");
    
    needPlaying_ = YES;
    if(self.delegate && [self.delegate respondsToSelector:@selector(videoProgress:isPlaying:)])
    {
        needPlaying_ = [self.delegate videoProgress:self isPlaying:YES];
    }
    touchPointStart_ = point;
    if(objectMovingID_ == TAG_SCROLLRECT)
    {
        lastSecondsBeMoving_ = seconds;
    }
    
    isMoving_ = YES;
}
- (void)moveDone:(CGPoint)point
{
    if(!isMoving_) return;
    NSLog(@"-----------move done---%d------",(int)objectMovingID_);
    if(objectMovingID_ == TAG_SCROLLRECT)
    {
        objectMovingID_ = -1;
        isMoving_ = NO;
        if(needPlaying_)
        {
            if(self.delegate && [self.delegate respondsToSelector:@selector(videoProgress:playBegin:)])
            {
                NSLog(@"touch ended 2________");
                [self.delegate videoProgress:self playBegin:seconds];
            }
        }
        return;
    }
}
- (void)    moveTrackObjectInView:(CGPoint)touchPoint viewID:(NSInteger)objectMovedTagID
{
    if(isMoving_==NO) return;
    
    if(objectMovedTagID == TAG_SCROLLRECT)
    {
        CGFloat targetPosx = touchPoint.x - touchPointStart_.x;
        CGFloat progressLength = [self getProgressWidth];
        if(progressLength <=0) return;
        
//        targetPosx += seconds /[self totalSeconds] * progressLength;
        CGPoint point = CGPointMake(targetPosx + lastSecondsBeMoving_ /[self totalSeconds] * progressLength, 0);
        NSLog(@"point change:%@ -- result:%@",NSStringFromCGPoint(touchPoint),NSStringFromCGPoint(point));
        
        if(point.x <0 ||point.x > progressLength_) return;
        
        [self changeStarForegroundViewWithPoint:point];

        if(self.delegate && [self.delegate respondsToSelector:@selector(videoProgress:Seek:)])
        {
            [self.delegate videoProgress:self Seek:seconds];
        }
        
    }
}
- (NSInteger)locationViewMoving:(CGPoint)point
{
    CGRect scrollRect = CGRectMake(0, 0, self.frame.size.width,self.frame.size.height);
    if(CGRectContainsPoint(scrollRect, point))
    {
        return TAG_SCROLLRECT;
    }
    return -1;
}
#pragma mark - ready release
- (void)readyToRelease
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    _delegate = nil;
    PP_RELEASE(CacheKey);
}

- (void)dealloc
{
    
    [self readyToRelease];
    
    PP_SUPERDEALLOC;
}

//-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//    NSLog(@"t point:%@",NSStringFromCGPoint(point));
//    return [super hitTest:point withEvent:event];
//}
@end
