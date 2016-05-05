//
//  WTVideoPlayerProgressView.h
//  Wutong
//
//  Created by HUANGXUTAO on 15/11/22.
//  Copyright © 2015年 HUANGXUTAO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <hccoren/base.h>

#define SLIDER_handleWidth 50.0 // handle width
#define SLIDER_borderWidth 1.0 // size of border under the slider
#define SLIDER_viewCornerRadius 15.0 // view corners radius
#define SLIDER_animationSpeed 0.1 // speed when slider change position on tap
#define SLIDER_progressHeight 2

#define SLIDER_BUTTONWIDTH 50
#define SLIDER_TIMEWIDTH 50

@class WTVideoPlayerProgressView;

typedef enum{
    Vertical,
    Horizontal
} PR_Orientation;


@protocol WTVideoPlayerProgressDelegate <NSObject>

@optional
- (void)videoProgress:(WTVideoPlayerProgressView *)progressView progressChanged:(CGFloat)seconds;
- (void)videoProgress:(WTVideoPlayerProgressView *)progressView pause:(CGFloat)seconds;
- (void)videoProgress:(WTVideoPlayerProgressView *)progressView playBegin:(CGFloat)seconds;
- (void)videoProgress:(WTVideoPlayerProgressView *)progressView Seek:(CGFloat)seconds;
- (void)videoProgress:(WTVideoPlayerProgressView *)progressView willFullScreen:(BOOL)fullScreen;
- (void)videoProgress:(WTVideoPlayerProgressView *)progressView didHidden:(BOOL)hidden;
- (void)videoProgress:(WTVideoPlayerProgressView *)progressView openGuideAudio:(BOOL)isOpen;
- (void)videoProgress:(WTVideoPlayerProgressView *)progressView willRecode:(BOOL)record;

- (BOOL)videoProgress:(WTVideoPlayerProgressView *)progressView isPlaying:(BOOL)isPlaying;
- (BOOL)videoProgress:(WTVideoPlayerProgressView *)progressView showComments:(BOOL)isPlaying;
@end

@interface WTVideoPlayerProgressView : UIView
@property (nonatomic, strong) CAGradientLayer * gradientLayer; //背景渐变
@property (nonatomic, strong) UIView * backMaskView;    //背景半透明块
@property (nonatomic, strong) UIView * playProgressView; //播放进度条
@property (nonatomic, strong) UIView * cachingView; //缓存进度条
@property (nonatomic, strong) UIView * handleView;  //进度块
@property (nonatomic, strong) UIView * trackBGView; //背景轨
@property (nonatomic, strong) UIButton * playOrPauseBtn;
@property (nonatomic, strong) UIButton * MaxMinSizeBtn;
@property (nonatomic, strong) UIButton * GuideAudioBtn;
@property (nonatomic, strong) UIButton * RecordBtn;
@property (nonatomic, strong) UIButton * commentShowBtn; //弹幕开关

@property (nonatomic, strong) UILabel * currentSecondsLabel;
@property (nonatomic, strong) UILabel * totalSecondsLabel;

//@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) PR_Orientation orientation;

@property (nonatomic,weak) id<WTVideoPlayerProgressDelegate> delegate;
@property (nonatomic,assign,readonly) CGFloat seconds;
@property (nonatomic,assign) CGFloat totalSeconds;
@property (nonatomic,assign) BOOL isPlaying;
@property (nonatomic,assign) BOOL isFullScreen;
@property (nonatomic,assign) BOOL isGuidAudioShow;
@property (nonatomic,assign) BOOL isCommentShow; //是否显示弹幕
@property (nonatomic,assign) BOOL isCommentBtnShow; //是否显示弹幕选择按钮

@property (nonatomic,assign,setter=setIsRecordButtonShow:) BOOL isRecordButtonShow;
@property (nonatomic,PP_STRONG) NSString * CacheKey;

- (CGFloat) getProgressWidth;

- (id)initWithFrame:(CGRect)frame needGradient:(BOOL)needGradient;

-(void)setColorsForBackground:(UIColor *)bCol foreground:(UIColor *)fCol caching:(UIColor *)cCol handle:(UIColor *)hCol border:(UIColor *)brdrCol;
-(void)removeRoundCorners:(BOOL)corners removeBorder:(BOOL)border;
-(void)hideHandle;

- (void)changeFrame:(CGRect)pframe;

- (void) show:(BOOL)animates autoHide:(BOOL)autoHide;
- (void) hide:(BOOL)animates;
- (void) setSeconds:(CGFloat)seconds withAnimation:(bool)isAnimate completion:(void (^)(BOOL finished))completion ;

- (void) setGuidAudio:(BOOL)isGuideOpen;
- (BOOL) useGuideAudio;

- (void) readyToRelease;
@end
