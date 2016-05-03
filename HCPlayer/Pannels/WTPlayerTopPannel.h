//
//  WTPlayerTopPannel.h
//  maiba
//
//  Created by HUANGXUTAO on 15/12/24.
//  Copyright © 2015年 seenvoice.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HCBaseSystem/UIWebImageViewN.h>
#import "WTPlayerControlPannel.h"

@interface WTPlayerTopPannel : UIView
{
    BOOL isBuild_;
    VDCItem * localVDCItem_;
    
    UIView * bgView_;
    CAGradientLayer *gradientLayer_;
    
    SevenSwitch * leaderSwitch_;
    UIButton * leaderButton_;
    UIButton * likeButton_;
    UIButton * cacheButton_;
    UIButton * shareButton_;
    
    UIButton * commentButton_;
    UIButton * moreButton_;
    UIButton * returnButton_;
    UIButton * previewButton_;
    UIButton * resingButton_;
    UIButton * cancelPreviewButton_;
    
    UIButton * reportButton_;//举报
    
    UILabel * titleLabel_;
    
    UILabel * likeTitle_;
    UILabel * cacheTitle_;
    UILabel * cacheProgressLabel_;
    UILabel * shareTitle_;
    UILabel * commentTitle_;
    
//    UIView * rightMenuContainer_;
    UIImageView *rightMenuArrow_;
    UIButton *editButton_;
    UIButton *barrageButton_;
    UIButton *shareButton2_;

    UIView * cacheContainer_;
    UIImageView * cacheIcon_;
    UITapGestureRecognizer * cacheGesture_ ;
    
    UIView * redDot_;
    UILabel * progressTime_;
    
    BOOL isPlayMode_;//是否用于播放或录制
    BOOL isInPreview_;//是否正在预览中
    
    CGFloat currentSeconds_;
    BOOL isDotSplash_;//红点是否闪烁
    
    UIWebImageViewN * userHeadPortrait_;
  
}
@property (nonatomic,PP_WEAK) NSObject <WTPlayerControlPannelDelegate> * delegate;
//@property (nonatomic,PP_WEAK) NSObject <WTVideoPlayerProgressDelegate> * progressDelegate;
@property (nonatomic,PP_STRONG,readonly) MTV * MTVItem;
@property (nonatomic,PP_STRONG,readonly) MTV * SampleItem;
@property (nonatomic,assign,setter=setUseGuidAudio:,getter=getUseGuidAudio) BOOL UseGuidAudio;

@property (nonatomic,assign) BOOL ShowCommentsButton;
@property (nonatomic,assign) BOOL ShowLikes;
@property (nonatomic,assign) BOOL ShowGuideAudio;
@property (nonatomic,assign) BOOL ShowMore;
@property (nonatomic,assign) BOOL ShowTitle;
@property (nonatomic,assign) BOOL ShowReturn;
@property (nonatomic,assign) BOOL ShowShare;
@property (nonatomic,assign) BOOL ShowCache;
@property (nonatomic,assign) BOOL ShowPreview;
@property (nonatomic,assign) BOOL ShowResing;
@property (nonatomic,assign) BOOL ShowEdit;
@property (nonatomic,assign) BOOL ShowCommentSwitch;
@property (nonatomic,assign) BOOL ShowBigCache;
@property (nonatomic,assign) BOOL ShowUserAvatar;
@property (nonatomic,PP_STRONG) UIView * rightMenuContainer;

@property (nonatomic,assign) BOOL isCommentsShow;

- (instancetype)initWithPara:(CGRect)frame playMode:(BOOL)isPlayMode;

- (void) setMTVItem:(MTV *)MTVItem sample:(MTV*)sampleItem;

- (void)setPannelMode:(BOOL)isPlay;
- (void)setCanPreview:(BOOL)canPreview;
- (void)setCommentCount:(int)commentCount;

- (void)changeFrame:(CGRect)frame;
- (void)buildViews:(CGRect)frame;

- (void)setPlaySeconds:(CGFloat)seconds;
- (void)setDotSplash:(BOOL)canSplash;
- (void)setCacheStatus:(BOOL)caching textColor:(UIColor*)color text:(NSString *)text percent:(CGFloat)percent;
- (void)setCacheCompleted:(BOOL)animates;

- (void)setUseGuidAudio:(BOOL)useGuideAudio;
- (BOOL)getUseGuidAudio;
- (void)hideGuidAudio;
- (void)showGuidAudio;
- (void)refreshGuidAudio;
- (void)hideWithAnimates:(BOOL)animates;

- (void)hideCommentButton;
- (void)showCommentButton;
- (void)hideCacheButton;
- (void)showCacheButton;

- (void)hideRightMenu:(id)sender animates:(BOOL)animates;
- (BOOL) isRightMenuShow;

- (void)showButtonsWhenPlay;
- (void)showButtonsWhenPause;
- (void)showLikeStatus;

- (void)readyToRelease;
@end
