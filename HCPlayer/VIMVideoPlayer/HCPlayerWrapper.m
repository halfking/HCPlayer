//
//  HCPlayerWrapper.m
//  HCPlayerTest
//
//  Created by HUANGXUTAO on 16/5/5.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import "HCPlayerWrapper.h"
#import <AVFoundation/AVFoundation.h>
#import <hccoren/base.h>
#import <HCBaseSystem/user_wt.h>
#import <HCBaseSystem/SNAlertView.h>
#import <HCBaseSystem/UIWebImageViewN.h>

#import <HCMVManager/VdcManager_full.h>

#import "MediaPlayer/MPMediaItem.h"
#import "MediaPlayer/MPNowPlayingInfoCenter.h"
#import "WTVideoPlayerView.h"
#import "WTVideoPlayerView(MTV).h"
#import "WTVideoPlayerProgressView.h"
#import "player_config.h"
#import "HCPlayerWrapper(Data).h"
#import "HCPlayerWrapper(Lyric).h"
#import "HCPlayerWrapper(Play).h"
#import "HCPlayerWrapper(background).h"

#import <HCBaseSystem/cmd_wt.h>
#import <HCBaseSystem/CMD_LikeOrNot.h>

#define TAG_SCROLLRECT 78654

@interface HCPlayerWrapper()<WTVideoPlayerViewDelegate,WTVideoPlayerProgressDelegate,WTPlayerControlPannelDelegate>
{
    BOOL subViewBuild_;
    UIButton *  centerPlayBtn_;      //视图中央的播放按钮
    CGFloat     centerPlayWidth_;   //中央按钮宽度
    
    UIWebImageViewN * cover_;
    CGFloat     progressHeight_;    //进度条高度
    CGFloat     playPannelHeight_;  //非全屏时，操作按钮在视频外，占用的高度
    
    BOOL isCanMove_;
    NSInteger objectMovingID_;
    CGPoint touchPointStart_;
    BOOL isMoving_;
    CGFloat lastSecondsBeMoving_;
    
    CGRect playFrameForPortrait_;
    
    UIPanGestureRecognizer * panRecognizer_;
    
    DeviceConfig * config_;
}

@end
static HCPlayerWrapper * _instanceDetailItem;
@implementation HCPlayerWrapper
#pragma mark - 初始化
+ (instancetype)shareObject
{
    DeviceConfig * config = [DeviceConfig config];
    @synchronized(config) {
        if(_instanceDetailItem)
        {
            return _instanceDetailItem;
        }
        else
        {
            return nil;
        }
    }
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        _instanceDetailItem = self;
        [self initData];
        [self buildViews:frame];
    }
    return self;
}
- (void)initData
{
    config_ = [DeviceConfig config];
    
    centerPlayWidth_ = 60;
    playPannelHeight_ = 0;
    bgTask_ = UIBackgroundTaskInvalid;
    
    userManager_ = [UserManager sharedUserManager];
    commentManager_ = [CommentViewManager new];
}
- (void)buildViews:(CGRect)frame
{
    if(subViewBuild_) return;
    CGSize containerSize = frame.size;
    {
        // 滚动时的播放按钮
        centerPlayBtn_ = [[UIButton alloc] initWithFrame:CGRectMake((containerSize.width-centerPlayWidth_)/2,
                                                                    (containerSize.height-centerPlayWidth_)/2,
                                                                    centerPlayWidth_, centerPlayWidth_)];
        
        [centerPlayBtn_ setImage:[UIImage imageNamed:@"HCPlayer.bundle/play2_icon"]
                        forState:UIControlStateNormal];
        [centerPlayBtn_ setImage:[UIImage imageNamed:@"HCPlayer.bundle/pause_icon"]
                        forState:UIControlStateSelected];
        [centerPlayBtn_ addTarget:self action:@selector(tempPlayPauseBtnClick:)
                 forControlEvents:UIControlEventTouchUpInside];
        //centerPlayBtn_.alpha = 1;
        [self addSubview:centerPlayBtn_];
    }
    // 封面
    {
        cover_ = [[UIWebImageViewN alloc] initWithFrame:CGRectMake(0, 0, containerSize.width, containerSize.height)];
        
        cover_.keepScale_ = YES;
        cover_.fastMode = NO;
        cover_.contentMode = UIViewContentModeScaleAspectFit;
        cover_.clipsToBounds = YES;
#warning need add holder image
        //            cover_.image = [UIImage imageNamed:PLAYERHOLDER];
        [self addSubview:cover_];
    }
    // 工具栏
    {
        CGRect toolFrame = CGRectMake(0, containerSize.height - progressHeight_, containerSize.width, progressHeight_);
        progressView_ = [[WTVideoPlayerProgressView alloc]initWithFrame:toolFrame needGradient:YES];
        
        [progressView_ setColorsForBackground:[UIColor whiteColor]
                                   foreground:COLOR_BA //[UIColor redColor] //COLOR_P1
                                      caching:[UIColor yellowColor] //COLOR_P2
                                       handle:[UIColor clearColor]
                                       border:[UIColor colorWithRed:0.0 green:205.0/255.0 blue:184.0/255.0 alpha:1.0]];
        
        [progressView_ setTotalSeconds:60];
        
        progressView_.isFullScreen = NO;
        progressView_.GuideAudioBtn.hidden = YES;
        [self addSubview:progressView_];
        
        [progressView_ changeFrame:toolFrame];
        
        progressView_.delegate = self;
    }
    //top pannel
    {
        CGRect toolFrame = CGRectMake(0, 0, containerSize.width, 40);
        maxPannel_ = [[WTPlayerTopPannel alloc]initWithFrame:toolFrame];
        
        [self addSubview:maxPannel_];
        maxPannel_.hidden = YES;
        maxPannel_.backgroundColor = [UIColor clearColor];
        maxPannel_.delegate = self;
    }
    //按钮栏
    {
        playPannel_ = [[WTPlayerControlPannel alloc]initWithFrame:CGRectMake(0, containerSize.height - playPannelHeight_, containerSize.width, playPannelHeight_)];
        playPannel_.backgroundColor = [UIColor clearColor];
        playPannel_.delegate = self;
    }
    
    {
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showProgressView:)];
        tap.enabled = YES;
        tap.numberOfTapsRequired = 1;
        tap.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tap];
    }
    
    subViewBuild_ = YES;
}
- (void)resizeViews:(CGRect)frame
{
    CGSize containerSize = frame.size;
    
    centerPlayBtn_.frame = CGRectMake((containerSize.width-centerPlayWidth_)/2,
                                      (containerSize.height-centerPlayWidth_)/2,
                                      centerPlayWidth_, centerPlayWidth_);
    cover_.frame = CGRectMake(0, 0, containerSize.width, containerSize.height);
    
    [progressView_ changeFrame:CGRectMake(0, containerSize.height - progressHeight_, containerSize.width, progressHeight_)];
    
    [maxPannel_ changeFrame:CGRectMake(0, 0, containerSize.width, 40)];
    
    [playPannel_ changeFrame:CGRectMake(0, containerSize.height - playPannelHeight_, containerSize.width, playPannelHeight_)];
    
    // 播放器
    [mplayer_ resizeViewToRect:cover_.frame andUpdateBounds:YES withAnimation:YES hidden:NO changed:nil];
}

- (void)showProgressView:(id)sender
{
    if([sender isKindOfClass:[UIGestureRecognizer class]])
    {
        UITapGestureRecognizer * tap = (UITapGestureRecognizer *)sender;
        CGPoint pos = [tap locationInView:self];
        NSLog(@"point:%@",NSStringFromCGPoint(pos));
        //        [self dismissKeyboard];
        
        if([progressView_ isHidden]==NO && [self isFullScreen])
        {
            CGRect pRect = [self convertRect:progressView_.frame fromView:progressView_.superview];
            CGRect mRect = [self convertRect:maxPannel_.frame fromView:maxPannel_.superview];
            if(CGRectContainsPoint(pRect, pos) || CGRectContainsPoint(mRect, pos))
            {
                return ;
            }
            //点击在右侧的地方
            if(maxPannel_.isRightMenuShow && maxPannel_.rightMenuContainer)
            {
                CGRect msRect = [self convertRect:maxPannel_.rightMenuContainer.frame
                                              fromView:maxPannel_.rightMenuContainer.superview];
                if(CGRectContainsPoint(msRect,pos))
                {
                    return;
                }
            }
        }
    }
    if([progressView_ isHidden])
    {
        [progressView_ show:YES autoHide:YES];
    }
    else
    {
        if([self isFullScreen])
        {
            if(maxPannel_ && [maxPannel_ isRightMenuShow])
            {
                [maxPannel_ hideRightMenu:nil animates:YES];
                return;
            }
        }
        [progressView_ hide:YES];
    }
}
#pragma mark - fullscreen
- (BOOL)isMVLandscape
{
    if(currentMTV_)
        return currentMTV_.IsLandscape;
    else
        return NO;
}
- (void)doFullScreen:(UIInterfaceOrientation)orientation
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    DeviceConfig * config_ = [DeviceConfig config];
    NSLog(@"landscape...");
    if(![self isFullScreen])
    {
        //        [self hidePopView:nil];
        [UIView animateWithDuration:0.35 animations:^(void)
         {
             self.transform = CGAffineTransformIdentity;
             
             //        if(!UIInterfaceOrientationIsLandscape(orientation))
             //        {
             CGFloat width = config_.Height;
             CGFloat height = config_.Width;
             
             if([self isMVLandscape])
             {
                 if(orientation == UIInterfaceOrientationLandscapeLeft)
                 {
                     self.transform = CGAffineTransformMakeRotation(0 - M_PI_2);
                 }
                 else
                     self.transform = CGAffineTransformMakeRotation(M_PI_2);
                 //        }
                 
                 self.bounds = CGRectMake(0.0, 0.0, config_.Height,config_.Width);
             }
             else
             {
                 width = config_.Width;
                 height = config_.Height;
             }
             playFrameForPortrait_ = self.frame;
             CGRect playFrame = CGRectMake(0, 0,width, height);
             
             CGFloat progressHeight = progressView_.frame.size.height;
             
             if(currentMTV_.AudioRemoteUrl && currentMTV_.AudioRemoteUrl.length>2)
             {
                 progressView_.GuideAudioBtn.hidden = NO;
             }
             else
             {
                 progressView_.GuideAudioBtn.hidden = YES;
             }
             if(![self currentItemIsSample])
             {
                 progressView_.isGuidAudioShow = NO;
             }
             
             
             progressView_.isRecordButtonShow = [self canShowRecordBtn];// && currentMtv_.IsLandscape; //只有横屏才能显示，否则位置不够
             
             [progressView_ changeFrame:CGRectMake(0, height - progressHeight, width, progressHeight)];
             progressView_.isFullScreen = YES;
             
             [self bringSubviewToFront:progressView_];
             
             [self addPanGestureRecognizer];
             
             self.frame = CGRectMake(0, 0,width , height );
             
             [mplayer_ resizeViewToRect:playFrame andUpdateBounds:YES withAnimation:NO hidden:NO changed:nil];
             
             cover_.frame = playFrame;
             
             [maxPannel_ setMTVItem:currentMTV_ sample:currentSample_];
             //             maxPannel_.MTVItem = currentMtv_;
             [maxPannel_ changeFrame:CGRectMake(0, 0, width, 40)];
             maxPannel_.hidden = NO;
             maxPannel_.ShowGuideAudio = NO;
//             authorInfoView_.hidden = YES;
//             tagsContainerView_.hidden = YES;
//             swipeContainerView_.hidden = YES;
             //             playerVisualEffectView_.hidden = YES;
             //             recordReminderView_.hidden = YES;
             playPannel_.hidden = YES;
//             returnBtn_.hidden = YES;
             //reportBtn_.hidden = YES;
//             commentSwitch_.hidden = YES;
             //             inputToolView_.hidden = YES;
             
             if([playPannel_ getUseGuidAudio])
             {
                 [progressView_ setGuidAudio:YES];
                 [maxPannel_ setUseGuidAudio:YES];
                 [maxPannel_ hideGuidAudio];
             }
             else
             {
                 [progressView_ setGuidAudio:NO];
                 [maxPannel_ setUseGuidAudio:NO];
                 [maxPannel_ hideGuidAudio];
             }
             
             
             NSLog(@"landscape height:%.1f",height);
//             [self showPlayOrPause:height];
             //centerPlayBtn_.center = mplayer_.center;
             
             //不显示歌词，因此注释。因为歌词已经合成到视频中
             //             [mplayer_ showLyric:currentMtv_.Lyric singleLine:YES container:mplayer_];
             
             if(!commentListView_)
             {
                 [self initCommentView];
             }
             else
             {
                 [commentManager_ setObject:currentMTV_.MTVID>0?HCObjectTypeMTV:HCObjectTypeSample objectID:(currentMTV_.MTVID>0?currentMTV_.MTVID:currentMTV_.SampleID)];
                 [self refreshComment];
             }
             
             [progressView_ show:YES autoHide:YES];
             
             [self bringToolBar2Front];
             
             // 判断要不要显示弹幕
             if (progressView_.isCommentShow && mplayer_ && mplayer_.playing) {
                 [self showComments];
             } else {
                 [self hideComments];
             }
             
             [self bringSubviewToFront:playPannel_];
             [self bringSubviewToFront:maxPannel_];
             [self bringSubviewToFront:progressView_];
             
             [self resetCommentsFrame:mplayer_.frame container:self textContainer:self.superview];
             
             //        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
             
             
             NSLog(@"player frame:%@",NSStringFromCGRect(mplayer_.frame));
         }];
    }
    else
    {
        if(currentMTV_.IsLandscape)
        {
            [UIView animateWithDuration:0.35 animations:^(void)
             {
                 if(orientation == UIInterfaceOrientationLandscapeLeft)
                     self.transform = CGAffineTransformMakeRotation(0 - M_PI_2);
                 else
                     self.transform = CGAffineTransformMakeRotation(M_PI_2);
                 self.bounds = CGRectMake(0.0, 0.0, config_.Height,config_.Width);
             }];
        }
    }
    //    else
    //    {
    //        self.view.transform = CGAffineTransformIdentity;
    //
    //        if(orientation == UIInterfaceOrientationPortraitUpsideDown)
    //        {
    //            self.view.transform = CGAffineTransformMakeRotation(0 - M_PI_2);
    //             [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:NO];
    //        }
    //        else if(orientation == UIInterfaceOrientationPortrait)
    //        {
    //            self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
    //             [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
    //        }
    //        //        else if(orientation == UIInterfaceOrientationLandscapeLeft)
    //        //        {
    //        //            self.view.transform = CGAffineTransformMakeRotation(0 - M_PI);
    //        //        }
    //        self.view.bounds = CGRectMake(0.0, 0.0, config_.Height,config_.Width);
    //    }
}
- (void)initCommentView
{
    if(!mplayer_) return;
    // 先注释掉
    //    if(!mplayer_)
    //    {
    //        CGRect playerFrame = [self getPlayerFrame];
    //        //        mplayer_ = [WTVideoPlayerView sharedWTVideoPlayerView];
    //        mplayer_ = [[WTVideoPlayerView alloc]initWithFrame:playerFrame];
    //    }
    [self initComments:self textContainer:self.superview inputTag:600 objectType:(currentMTV_.MTVID>0?HCObjectTypeMTV:HCObjectTypeSample) objectID:(currentMTV_.MTVID>0?currentMTV_.MTVID:currentMTV_.SampleID)];
    [self resetCommentsFrame:mplayer_.frame container:self textContainer:self.superview];
}
- (void)cancelFullScreen:(UIInterfaceOrientation)orientation
{
    //    if ([[HWindowStack shareObject] getLastVc] == self) {
    //        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    //    }
    
    if([self isFullScreen])
    {
        //        [self hidePopView:nil];
        DeviceConfig * config_ = [DeviceConfig config];
        self.transform = CGAffineTransformIdentity;
        self.bounds = CGRectMake(0.0, 0.0, config_.Width,config_.Height);
        
        CGRect playFrame = CGRectMake(0, 0, playFrameForPortrait_.size.width,
                                      playFrameForPortrait_.size.height - playPannelHeight_);
        
        CGFloat progressHeight = progressView_.frame.size.height;
        
        [self removeLyric];
        // [mplayer_ hideComments];
        
        progressView_.GuideAudioBtn.hidden = YES;
        progressView_.isRecordButtonShow = NO;
        
        [progressView_ changeFrame:CGRectMake(0, playFrameForPortrait_.size.height - progressHeight - playPannelHeight_, playFrameForPortrait_.size.width, progressHeight)];
        progressView_.isFullScreen = NO;
        
        [self removePanGestureRecognizer];
        
        self.frame = playFrameForPortrait_;
        
        [mplayer_ resizeViewToRect:playFrame andUpdateBounds:YES withAnimation:YES hidden:NO changed:nil];
        cover_.frame = playFrame;
        
        maxPannel_.hidden = YES;
        //        inputToolView_.hidden = NO;
//        authorInfoView_.hidden = NO;
//        tagsContainerView_.hidden = NO;
//        swipeContainerView_.hidden = NO;
        //        playerVisualEffectView_.hidden=NO;
        progressView_.hidden = NO;
        playPannel_.hidden = NO;
//        returnBtn_.hidden = NO;
        //reportBtn_.hidden = NO;
//        commentSwitch_.hidden = NO;
        [playPannel_ setMTVItem:currentMTV_ sample:currentSample_];
        
        if([maxPannel_ getUseGuidAudio])
        {
            playPannel_.useGuidAudio = YES;
        }
        else
        {
            playPannel_.useGuidAudio = NO;
        }
        
        NSLog(@"playframeforportain:%@",NSStringFromCGRect(playFrameForPortrait_));
        //计算可见区域
//        [self showPlayOrPause:playFrameForPortrait_.size.height + playFrameForPortrait_.origin.y];
        //centerPlayBtn_.center = mplayer_.center;
        
        [progressView_ show:YES autoHide:NO];
        
        [self bringToolBar2Front];
        
        [self bringSubviewToFront:playPannel_];
        [self bringSubviewToFront:maxPannel_];
        [self bringSubviewToFront:progressView_];
        
        
        // 判断要不要显示弹幕
//        if ([self isMaxWindowPlay]) {
            [self resetCommentsFrame:mplayer_.frame container:self textContainer:self.superview];
//        } else {
//            CGRect frame = mplayer_.frame;
//            frame.size.height = playerHeightMax_;
//            [self resetCommentsFrame:frame container:self textContainer:self.superview];
//            [self hideComments];
//        }
        
        [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
    }
    
    //    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    //    {
    //        self.view.transform = CGAffineTransformMakeRotation(0 - M_PI_2);
    //        self.view.bounds = CGRectMake(0.0, 0.0, config_.Width,config_.Height);
    //    }
}
#pragma mark - butons
- (void) showButtonsPause
{
    progressView_.isPlaying = NO;
    [progressView_ show:YES autoHide:NO];
    centerPlayBtn_.hidden = NO;
    [centerPlayBtn_ setSelected:NO];
}
- (void) showButtonsPlaying
{
    if([NSThread isMainThread])
    {
        progressView_.isPlaying = YES;
        [progressView_ show:YES autoHide:YES];
        [centerPlayBtn_ setSelected:YES];
        centerPlayBtn_.hidden = YES;
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self showButtonsPlaying];
                       });
    }
}
- (void) tempPlayPauseBtnClick:(id)sender
{
    if(centerPlayBtn_.isSelected)
    {
        [self pause];
    }
    else
    {
//        MTV * item = currentMTV_;
        if(mplayer_.playing)
        {
            [self showButtonsPlaying];
            return;
        }
        
//        if ([self currentItemIsSample])
//        {
////            NSString *downloadURL = [currentMTV_ getDownloadUrlOpeated:[DeviceConfig config].networkStatus
////                                                                userID:[userManager_ userID]];
////            [self stopCacheMTV:downloadURL];
//            [self play];
//            
//        }
//        //观看他人的MTV
//        else
//        {
            [self play];
//        }
    }
}
- (void)showProgressSync:(CGFloat)seconds
{
    [progressView_ setSeconds:seconds withAnimation:NO completion:nil];
    //    if(progressView_.isFullScreen && canShowComments_ && needRefreshComments_)
    //    {
    //        [self refreshCommentWithPlayerDurance];
    //    }
}
- (void)setTotalSeconds:(CGFloat)seconds
{
    progressView_.totalSeconds = seconds;
}
#pragma mark - 数据设置
- (BOOL) setPlayerData:(MTV *)item
{
    PP_RELEASE(currentMTV_);
    
    if(!item) return NO;
    
    currentMTV_ = PP_RETAIN(item);
    if([userManager_ enableCachenWhenPlaying])
    {
        if(!localFileVDCItem_)
        {
            localFileVDCItem_ = [[VDCManager shareObject]getVDCItemByMtv:currentMTV_ urlString:nil];
        }
        
        [progressView_ setCacheKey:localFileVDCItem_.key];
    }

 
        [maxPannel_ setMTVItem:currentMTV_ sample:currentSample_];
        [playPannel_ setMTVItem:currentMTV_ sample:currentSample_];
    if( currentMTV_.AudioRemoteUrl && currentMTV_.AudioRemoteUrl.length>2)
    {
        [playPannel_ setUseGuidAudio:YES];
        [progressView_ setGuidAudio:YES];
    }
    else
    {
        [playPannel_ setUseGuidAudio:NO];
        [progressView_ setGuidAudio:NO];
    }
    
    [progressView_ changeFrame:progressView_.frame];
    [progressView_ setTotalSeconds:currentMTV_.Durance];
    
    
    // 封面
    if (currentMTV_.CoverUrl && currentMTV_.CoverUrl.length > 0 )
    {
        [cover_ setImageWithURLString:currentMTV_.CoverUrl width:cover_.frame.size.width
                               height:cover_.frame.size.height
                                 mode:2
                 placeholderImageName:nil];
    }
    else
    {
        cover_.image = [UIImage imageNamed:@"HCPlayer.boundle/mtvcover_icon"];
    }
    
    if(leaderPlayer_)
    {
        [leaderPlayer_ stop];
        leaderPlayer_ = nil;
    }
    
    if(![item hasAudio])
    {
        [self videoPannel:nil guideChanged:NO];
    }

    return YES;
}
- (BOOL) setPlayerItem:(AVPlayerItem *)playerItem
{
    return NO;
}
- (BOOL) setPlayerUrl:(NSURL *)url
{
    return NO;
}



#pragma mark - 播放
- (void)pauseWithCache
{
    
}
- (void)pause
{
    [self showButtonsPause];
    [self pauseItemWithCoreEvents];
}
- (BOOL)playItem:(id)sender seconds:(CGFloat)seconds
{
    [self showButtonsPlaying];
    MTV * item = [self getCurrentMTV];
    currentPlaySeconds_ = 0;
    //    float lastLrcTime = 0;
#ifdef USE_CACHEPLAYING
    if([userManager_ enableCachenWhenPlaying])
    {
        if(!item.isCheckDownload)
        {
            [WTVideoPlayerView isDownloadCompleted:&item Sample:nil NetStatus:netStatus_ UserID:userInfo_.UserID];
        }
    }
#endif
    NSString * path = [item getMTVUrlString:[DeviceConfig config].networkStatus
                                     userID:[userManager_ userID] remoteUrl:nil];
    
    if(mplayer_ && [mplayer_ isCurrentPath:path])
    {
        [self showButtonsPlaying];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self playItemWithCoreEvents:seconds];
        });
        return YES;
    }
    else
    {
//        pauseUnexpected_ = NO;
        
        if([mplayer_ isCurrentMTV:item])
        {
            if(mplayer_ && [mplayer_ getCurrentUrl]) {
                [self showButtonsPlaying];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self playItemWithCoreEvents:seconds];
                });
                return YES;
            }
        }
        
        return [self updatePlayer:item seconds:seconds];
    }
    
}

//滚动的时候也会触发该事件
//更换当前播放的对像或者再次播放
//在此之前，请不要更新currentMtv对像
-(BOOL) updatePlayer:(MTV *)item seconds:(CGFloat)seconds
{
    __block NSString * path;
#ifdef USE_CACHEPLAYING
    if([userManager_ enableCachenWhenPlaying])
    {
        if(!item.isCheckDownload)
        {
            [WTVideoPlayerView isDownloadCompleted:&item Sample:nil NetStatus:config_.networkStatus  UserID:[userManager_ userID]];
        }
    }
#endif
    path = [item getMTVUrlString:config_.networkStatus userID:[userManager_ userID] remoteUrl:nil];
    
    if(path && path.length != 0)
    {
        //[self showHUDViewInThread];
        NSString * audioUrl = nil;
        //下载导唱的数据
        if([self currentItemIsSample] ||item.UserID==[userManager_ userID])
        {
            audioUrl = item.AudioRemoteUrl;
        }
        
        //        [[UMShareObject shareObject]event:@"PlayBegin" attributes:@{@"title":item.Title?item.Title:@"NoName",@"url":path}];
        if([HCFileManager isLocalFile:path] && [HCFileManager isExistsFile:path])
        {
            [self playLocalFile:item path:path audioUrl:audioUrl seconds:seconds play:YES];
        }
        else
        {
            if(![self playRemoteFile:item path:path audioUrl:audioUrl seconds:seconds])
            {
                return NO;
            }
        }
        if([self getCurrentMTV]!=item)
        {
//            [self setCurrentMTV:item];
        }
        
        //[self refreshButtonStateInThreadWithMTV:item];
        
        
        return YES;
    }
    else if(item)
    {
        NSLog(@"invalid item path(not found)");
        //        [self showMessage:MSG_ERROR msg:MSG_FILENOTFOUND];
        return NO;
    }
    else
    {
//        [self showMessage:MSG_ERROR msg:@"没有获取到正确的数据，请检查网络后重试!"];
        return NO;
    }
}

#pragma mark - progress delegate
//- (void)videoProgress:(WTVideoPlayerProgressView *)progressView playBegin:(CGFloat)seconds
//{
//    MTV * item = currentMtv_;
//    if(mplayer_.playing)
//    {
//        [mplayer_ pause];
//    }
//    NSLog(@"touch ended 3________");
//    if(mplayer_)
//    {
//        [mplayer_ showActivityView];
//    }
//    if (item.MTVID == 0)
//    {
//        NSString *downloadURL = [currentMtv_ getDownloadUrlOpeated:netStatus_ userID:userInfo_.UserID];
//        [self stopCacheMTV:downloadURL];
//        [self playItem:nil seconds:seconds];
//
//    }
//    //观看他人的MTV
//    else
//    {
//        [self playItem:nil seconds:seconds];
//    }
//    // needRefreshComments_ = YES;
//    if (mplayer_) [mplayer_ refreshCommentsView:seconds];
//}
- (void)videoProgress:(WTVideoPlayerProgressView *)progressView pause:(CGFloat)seconds
{
    //    if(seconds>=0)
    //    {
    //        [self pauseItem:nil];
    //    }
}
- (void)videoProgress:(WTVideoPlayerProgressView *)progressView progressChanged:(CGFloat)seconds
{
    
}
- (void)videoProgress:(WTVideoPlayerProgressView *)progressView willFullScreen:(BOOL)fullScreen
{
    //    NSLog(@"need full screen...%d",fullScreen);
    //    if(fullScreen)
    //    {
    //        [self doFullScreen:UIInterfaceOrientationLandscapeRight];
    //    }
    //    else
    //    {
    //        [self cancelFullScreen:UIInterfaceOrientationPortrait];
    //    }
}
- (void)videoProgress:(WTVideoPlayerProgressView *)progressView didHidden:(BOOL)hidden
{
    if(progressView.isFullScreen)
    {
        if(hidden)
        {
            [maxPannel_ hideRightMenu:nil animates:YES];
            [maxPannel_ hideWithAnimates:YES];
        }
        else
        {
            maxPannel_.hidden = hidden;
            [maxPannel_ hideRightMenu:nil animates:NO];
        }
    }
    else
    {
        //returnBtn_.hidden = hidden;
        maxPannel_.hidden = YES;
    }
    //    if (self.isPlaying) {
    //        if (centerPlayBtn_.isHidden == hidden) return;
    //
    //        if (hidden) {
    //            [UIView animateWithDuration:0.3f animations:^{
    //                centerPlayBtn_.alpha = 0;
    //            } completion:^(BOOL finished) {
    //                centerPlayBtn_.hidden = hidden;
    //                centerPlayBtn_.alpha = 1;
    //            }];
    //        } else {
    //            centerPlayBtn_.alpha = 0;
    //            [UIView animateWithDuration:0.3f animations:^{
    //                centerPlayBtn_.alpha = 1;
    //            } completion:^(BOOL finished) {
    //                centerPlayBtn_.hidden = hidden;
    //                centerPlayBtn_.alpha = 1;
    //            }];
    //        }
    //    }
}
- (void)videoProgress:(WTVideoPlayerProgressView *)progressView openGuideAudio:(BOOL)isOpen
{
    [self videoPannel:nil guideChanged:isOpen];
}
- (void)videoProgress:(WTVideoPlayerProgressView *)progressView willRecode:(BOOL)record
{
    if(record)
    {
        [self readyToRelease];
//        [mediaEditManager_ clear];
//        if(currentMtv_.UserID == userInfo_.UserID && userInfo_.UserID>0)
//        {
//            mediaEditManager_.mergeMTVItem = currentMtv_;
//        }
        //        NSString * url = [[HWindowStack shareObject]buildSingUrl:NO
        //                                                          source:@"cache"
        //                                                        sampleID:currentMtv_.SampleID
        //                                                     isLandscape:currentMtv_.IsLandscape?1:0];
        //        [[HWindowStack shareObject]openWindow:self urlString:url shouldOpenWeb:YES];
    }
}
- (BOOL)videoProgress:(WTVideoPlayerProgressView *)progressView isPlaying:(BOOL)isPlaying
{
    if(mplayer_ && mplayer_.playing)
        return YES;
    else
        return NO;
}
- (void)videoProgress:(WTVideoPlayerProgressView *)progressView Seek:(CGFloat)seconds
{
    if(mplayer_)
    {
        [mplayer_ seek:seconds accurate:YES];
    }
}
#pragma mark - share download....

- (void)videoPannel:(WTPlayerControlPannel *)pannelView doShare:(CGFloat)seconds
{
    //    if ([UserManager sharedUserManager].isLogin) {
    //        [self openShareView];
    //    }
    //    else{
    //        openTypeAfterLogin_ = 1;//分享
    //        [self openLoginView];
    //    }
}
- (void)videoPannel:(WTPlayerControlPannel *)pannelView guideChanged:(BOOL)isGuide
{
    if (isGuide) {
        leaderPlayer_.volume = 1;
    }
    else{
        leaderPlayer_.volume = 0;
    }
}
- (void)videoPannel:(WTPlayerControlPannel *)pannelView showComments:(BOOL)show{
    NSLog(@"need comments... 1 Or 0 -> %d",show);
//    [commentSwitch_ setOn:show];
    
    if (!mplayer_) return;
    if (show) {
        if(!commentListView_)
        {
            [self initCommentView];
        }
        [self showComments];
        [self refreshComment];
    } else {
        [self hideComments];
    }
}
- (void)videoPannel:(WTPlayerControlPannel *)pannelView editComments:(BOOL)show
{
    NSLog(@"show comment input....");
//    commentForWhen_ = (mplayer_?CMTimeGetSeconds([mplayer_ durationWhen]):0);
//    if([self isFullScreen])
//    {
//        [self cancelFullScreen:UIInterfaceOrientationPortrait];
//        //        if(!mplayer_.commentTextInput)
//        //        {
//        //            [self initCommentView];
//        //            [mplayer_ hideComments];
//        //        }
//    }
//    
    //    self.keyboardMode = keyboardModeNewInputView;
    //    [inputToolView_ registerKB:self];
    //
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        [inputToolView_ becomeFirstResponder];
    //        //        self.commentText.selectedTextRange = NSMakeRange(0, 0);
    //    });
    
    
    //    textView.selectedRange = NSMakeRange(0, 0);
    //    }
}
- (void)videoPannel:(WTPlayerControlPannel *)pannelView likeIt:(BOOL)isLike
{
    //    if (![self checkLoginStatus]) return;
    
    MTV * item = currentMTV_;
    CMD_CREATE(cmd, LikeOrNot, @"LikeOrNot");
    
    if(item.MTVID>0)
    {
        cmd.MtvID = item.MTVID;
    }
    else
    {
        cmd.MtvID = item.SampleID;
        cmd.ObjectType = HCObjectTypeSample;
    }
    cmd.ObjectUserID = item.UserID;
    cmd.IsLike = !isLike;
    cmd.CMDCallBack = ^(HCCallbackResult * result)
    {
        if(result.Code==0)
        {
            if (pannelView && pannelView == playPannel_) {
                [playPannel_ showLikeStatus];
            } else {
                [maxPannel_ showLikeStatus];
            }
            //            for (UIView * v in listView_.visibleItemViews) {
            //                if([v isKindOfClass:[RankView class]])
            //                {
            //                    RankView * vv = (RankView *)v;
            //                    [vv setConcernChanged:currentMtv_];
            //                }
            //            }
            
            if (currentMTV_.MTVID>0) {
                NSMutableDictionary *dic = [NSMutableDictionary new];
                [dic setValue:@(HCObjectTypeMTV) forKey:@"objecttype"];
                [dic setValue:@(currentMTV_.MTVID) forKey:@"objectid"];
                [dic setValue:@(!isLike) forKey:@"islike"];
                [[NSNotificationCenter defaultCenter] postNotificationName:NT_CHANGELIKESTATUS object:nil userInfo:dic];
            }
        }
    };
    [cmd sendCMD];
    
}
- (void)videoPannel:(WTPlayerControlPannel *)pannelView editMtv:(BOOL)edit
{
    NSLog(@"edit");
    if(!edit) return;
    if(self.delegate && [self.delegate respondsToSelector:@selector(videoPannel:editMtv:)])
    {
        [self pause];
        [self.delegate videoPannel:pannelView editMtv:edit];
        [self readyToRelease];
    }
//    if(edit)
//    {
//        [self readyToRelease];
    
//        [mediaEditManager_ clear];
//        mediaEditManager_.mergeMTVItem = [self getCurrentMTV];
        //        NSString * url = [[HWindowStack shareObject]buildSingUrl:NO source:@"cache" sampleID:currentMtv_.SampleID];
        
        
        //        NSString * url = [[HWindowStack shareObject]buildEditUrl:currentMtv_.MTVID isLandscape:mediaEditManager_.mergeMTVItem.IsLandscape?1:0];
        //        [[HWindowStack shareObject]openWindow:self urlString:url shouldOpenWeb:YES];
//    }
}
- (void)videoPannel:(WTPlayerControlPannel *)pannelView didReturn:(BOOL)isReturn
{
    [self cancelFullScreen:UIInterfaceOrientationPortrait];
}

#pragma mark - player delegate
- (void)videoPlayerViewIsReadyToPlayVideo:(WTVideoPlayerView *)videoPlayerView
{
    NSLog(@"ready to play...%i",(int)mplayer_.playing);
    //    [self recordPlayItemBegin];
    //    [self setDelaySeconds];
    
    // 显示歌词
    //    if (!mplayer_.lyricView  && [self isFullScreen]) {
    //        [mplayer_ showLyric:currentMtv_.Lyric singleLine:YES container:mplayer_];
    //    }
    // 判断要不要显示弹幕
    if (progressView_.isCommentShow){
        if(!commentListView_)
        {
            [self initCommentView];
        }
        [self showComments];
    } else {
        [self hideComments];
    }
}
- (void)videoPlayerViewDidReachEnd:(WTVideoPlayerView *)videoPlayerView
{
    //[commentManager_ stopCommentTimer];
    [commentManager_ stopCommentTimer];
    
    currentPlaySeconds_ = 0;
    [self pause];
    
//    [self removePlayerInThread];
}
- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView timeDidChange:(CGFloat)cmTime
{
    if(cmTime < 0.15)
    return;
    
    [self showProgressSync:cmTime];
    
    CGFloat progress = cmTime;
    currentPlaySeconds_ = progress;
    
    if (leaderPlayer_ && needPlayLeader_) {
        leaderPlayer_.currentTime = progress + 0.1;
        [leaderPlayer_ play];
        needPlayLeader_ = NO;
    }
    if(lastPlaySecondsForBackInfo_ > currentPlaySeconds_ || lastPlaySecondsForBackInfo_ < currentPlaySeconds_ -1)
    {
        [self showPlayBackProgress:currentPlaySeconds_];
        lastPlaySecondsForBackInfo_ = currentPlaySeconds_;
    }
    //显示歌词
    if(lyricView_ && lyricView_.hidden == NO)
    {
        [lyricView_ didPlayingWithSecond:currentPlaySeconds_];
    }
    // 同步comment的时间
    if(commentListView_ && commentManager_)
    {
        [commentManager_ setCurrentDuranceWhen:progress];
    }
    if ([self.delegate respondsToSelector:@selector(videoPlayerView:timeDidChange:)])
    {
        [self.delegate videoPlayerView:videoPlayerView timeDidChange:currentPlaySeconds_];
    }
}
- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView didStalled:(AVPlayerItem *)playerItem
{
    NSLog(@"playing pause by stalled");
    //此处不易中断处理，在Loader代理情况下，如果中断，会导致下载停止,IOS 7以下，不使用Loader
    if([DeviceConfig IOSVersion]<7.0)
    {
        [self pause];
    }
}
- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView beginPlay:(AVPlayerItem *)playerItem
{
    if(leaderPlayer_ && leaderPlayer_.rate<=0.1)
    {
        needPlayLeader_ = YES;
    }
}
- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView didFailedToPlayToEnd:(NSError *)error
{
    currentPlaySeconds_ = 0;
    NSLog(@"playing pause by didFailedToPlayToEnd:%@",[error localizedDescription]);
#ifdef USE_CACHEPLAYING
    if([userManager_ enableCachenWhenPlaying])
    {
        NSString * url = [[videoPlayerView getCurrentUrl]absoluteString];
        if(url && [HCFileManager isLocalFile:url])
        {
            if(localFileVDCItem_ && [[localFileVDCItem_.localFilePath lastPathComponent]isEqualToString:[url lastPathComponent]])
            {
                [[VDCManager shareObject]removeUrlCahche:localFileVDCItem_.remoteUrl];
                localFileVDCItem_.downloadBytes = 0;
                [videoPlayerView resetPlayItemKey];
                [self pause];
            }
            else
            {
                [self pause];
            }
        }
        else
        {
            [self pause];
        }
    }
    else
    {
        [self pause];
    }
#else
   [self pause];
#endif
}
- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView pausedByUnexpected:(NSError *)error item:(AVPlayerItem *)playerItem
{
    NSLog(@"playing pausedByUnexpected:%@",[error localizedDescription]);
//    pauseUnexpected_ = YES;
    if(leaderPlayer_)
    {
        [leaderPlayer_ pause];
    }
    
}
- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView autoPlayAfterPause:(NSError *)error item:(AVPlayerItem *)playerItem
{
//    if(!pauseUnexpected_)
//    {
//        [self pauseItem:nil];
//        NSLog(@"playing auto, no unexpected stop, so pause.");
//    }
//    pauseUnexpected_ = NO;
}
- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView didFailWithError:(NSError *)error
{
    currentPlaySeconds_ = 0;
    NSLog(@" playing failed error:%@",[error localizedDescription]);
#ifdef USE_CACHEPLAYING
    if([userManager_ enableCachenWhenPlaying])
    {
        NSString * url = [[videoPlayerView getCurrentUrl]absoluteString];
        if([HCFileManager isLocalFile:url])
        {
            if(localFileVDCItem_ && [[localFileVDCItem_.localFilePath lastPathComponent]isEqualToString:[url lastPathComponent]])
            {
                [[VDCManager shareObject]removeUrlCahche:localFileVDCItem_.remoteUrl];
                localFileVDCItem_.downloadBytes = 0;
                [videoPlayerView resetPlayItemKey];
                [self pauseItem:nil];
            }
        }
    }
#endif
}
- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView didTapped:(AVPlayerItem *)playerItem
{
    [self showProgressView:nil];
}
#pragma mark - moving
#pragma mark - PanGestureRecognizer
- (void)addPanGestureRecognizer
{
    //    MLNavigationController * nav = (MLNavigationController *)(self.navigationController);
    //    nav.canDragBack = NO;
    
    if (!panRecognizer_) {
        panRecognizer_ = [[UIPanGestureRecognizer alloc]initWithTarget:self
                                                                action:@selector(paningGestureReceive:)];
        panRecognizer_.delaysTouchesBegan = NO;
        panRecognizer_.delaysTouchesEnded = NO;
        panRecognizer_.cancelsTouchesInView = NO;
    }
    [self addGestureRecognizer:panRecognizer_];
}
- (void)removePanGestureRecognizer
{
    if(panRecognizer_)
    {
        [self removeGestureRecognizer:panRecognizer_];
        panRecognizer_ = nil;
    }
    
    //    MLNavigationController * nav = (MLNavigationController *)(self.navigationController);
    //    nav.canDragBack = YES;
}
#pragma mark - pan moving
- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer
{
    if(![progressView_ isFullScreen]) return;
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
    
    if(mplayer_ && mplayer_.playing)
    {
        isPlayingWhenEnterBackground_ = YES;
        [self pause];
    }
    else
    {
        isPlayingWhenEnterBackground_ = NO;
    }
    
    touchPointStart_ = point;
    if(objectMovingID_ == TAG_SCROLLRECT)
    {
        lastSecondsBeMoving_ = CMTimeGetSeconds([mplayer_ durationWhen]);
    }
    
    isMoving_ = YES;
}
- (void)moveDone:(CGPoint)point
{
    if(!isMoving_) return;
    NSLog(@"-----------move done---%d------",objectMovingID_);
    if(objectMovingID_ == TAG_SCROLLRECT)
    {
        objectMovingID_ = -1;
        isMoving_ = NO;
        if(isPlayingWhenEnterBackground_)
        {
            [self play];
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
        CGFloat progressLength = [progressView_ getProgressWidth];
        if(progressLength <=0) return;
        CGFloat seconds = targetPosx / progressLength * [progressView_ totalSeconds];
        [mplayer_ seek:seconds + lastSecondsBeMoving_ accurate:YES];
        
        // refresh comment
        CGFloat commentSeconds = seconds + lastSecondsBeMoving_;
        if(commentSeconds < 0) commentSeconds = 0;
        else if(commentSeconds >= mplayer_.getSecondsEnd) commentSeconds = 0;
        if (mplayer_) {
            [self refreshCommentsView:commentSeconds];
        }
    }
}
- (NSInteger)locationViewMoving:(CGPoint)point
{
    CGRect scrollRect = CGRectMake(0, 40, config_.Height, config_.Width - 120);
    if (!currentMTV_.IsLandscape) {
        scrollRect = CGRectMake(0, 40, config_.Width, config_.Height - 80);
    }
    
    if(CGRectContainsPoint(scrollRect, point))
    {
        return TAG_SCROLLRECT;
    }
    return -1;
}

#pragma mark - view
- (MTV*)getCurrentMTV
{
    return currentMTV_;
}
- (UIImage *)getCoverImage
{
    if(cover_ && cover_.image)
    return cover_.image;
    else
    return nil;
}
- (void) bringToolBar2Front
{
    if(cover_)
    [self bringSubviewToFront:cover_];
    if(mplayer_)
    [self bringSubviewToFront:mplayer_];
    
    
    
    [self bringSubviewToFront:progressView_];
    [self bringSubviewToFront:playPannel_];
    [self bringSubviewToFront:maxPannel_];
    
    [self bringSubviewToFront:centerPlayBtn_];
    
    
    
    [self bringSubviewToFront:commentListView_];
}
- (CGRect)getPlayerFrame
{
    if(progressView_.isFullScreen)
    {
        if(!currentMTV_ || currentMTV_.IsLandscape)
        {
            return CGRectMake(0, 0, config_.Height, config_.Width);
        }
        else
        {
            return CGRectMake(0, 0, config_.Width, config_.Height);
        }
    }
    else
    {
        CGRect containerFrame = self.frame;
        containerFrame.size.height -= playPannelHeight_;
        containerFrame.origin.y = 0;
        containerFrame.origin.x = 0;
        return containerFrame;
    }
}
#pragma mark - dealloc
- (void)readyToRelease
{
    _instanceDetailItem = nil;
    if (mplayer_) {
        [self removePlayerInThread];
    }
    if(leaderPlayer_)
    {
        [leaderPlayer_ stop];
        leaderPlayer_ = nil;
    }
    [progressView_ readyToRelease];
    [playPannel_ readyToRelease];
    [maxPannel_ readyToRelease];

    if(commentManager_)
    {
        [commentManager_ stopCommentTimer];
        [commentManager_ readyToRelease];
        commentManager_ = nil;
    }
    PP_RELEASE(commentListView_);
    PP_RELEASE(lyricView_);
//    PP_RELEASE(activityView_);
    
    PP_RELEASE(progressView_);
    PP_RELEASE(playPannel_);
    PP_RELEASE(maxPannel_);
    
  
}
- (void)dealloc
{
    [self readyToRelease];
    PP_SUPERDEALLOC;
}
@end
