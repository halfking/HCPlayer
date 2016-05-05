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
@interface HCPlayerWrapper()<WTVideoPlayerViewDelegate,WTVideoPlayerProgressDelegate,SNAlertView>
{
    BOOL subViewBuild_;
    UIButton *  centerPlayBtn_      //视图中央的播放按钮
    CGFloat     centerPlayWidth_;   //中央按钮宽度
    
    UIWebImageViewN * cover_;
    CGFloat     progressHeight_;    //进度条高度
    CGFloat     playPannelHeight_;  //非全屏时，操作按钮在视频外，占用的高度
}

@end

@implementation HCPlayerWrapper
#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self initData];
        [self buildViews:frame];
    }
    return self;
}
- (void)initData
{
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
        [playContainerView_ addSubview:progressView_];
        
        [progressView_ changeFrame:toolFrame];
        
        progressView_.delegate = self;
    }
    //top pannel
    {
        CGRect toolFrame = CGRectMake(0, 0, containerSize.width, 40);
        maxPannel_ = [[WTPlayerTopPannel alloc]initWithFrame:toolFrame];
        
        [playContainerView_ addSubview:maxPannel_];
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
        [playContainerView_ addGestureRecognizer:tap];
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
    
}

- (void)showProgressView:(id)sender
{
    if([sender isKindOfClass:[UIGestureRecognizer class]])
    {
        UITapGestureRecognizer * tap = (UITapGestureRecognizer *)sender;
        CGPoint pos = [tap locationInView:self.view];
        NSLog(@"point:%@",NSStringFromCGPoint(pos));
        //        [self dismissKeyboard];
        
        if([progressView_ isHidden]==NO && [self isFullScreen])
        {
            CGRect pRect = [self.view convertRect:progressView_.frame fromView:progressView_.superview];
            CGRect mRect = [self.view convertRect:maxPannel_.frame fromView:maxPannel_.superview];
            if(CGRectContainsPoint(pRect, pos) || CGRectContainsPoint(mRect, pos))
            {
                return ;
            }
            //点击在右侧的地方
            if(maxPannel_.isRightMenuShow && maxPannel_.rightMenuContainer)
            {
                CGRect msRect = [self.view convertRect:maxPannel_.rightMenuContainer.frame
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
        [self pauseItem:nil];
    }
    else
    {
        MTV * item = currentMtv_;
        if(mplayer_.playing)
        {
            [self showButtonsPlaying];
            return;
        }
        
        if (item.MTVID == 0)
        {
            NSString *downloadURL = [currentMtv_ getDownloadUrlOpeated:netStatus_ userID:userInfo_.UserID];
            [self stopCacheMTV:downloadURL];
            [self playItem:nil seconds:-1];
            
        }
        //观看他人的MTV
        else
        {
            [self playItem:nil seconds:-1];
        }
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
#ifdef USE_CACHEPLAYING
    if([userManager_ enableCachenWhenPlaying])
    {
        if(!localFileVDCItem_)
        {
            localFileVDCItem_ = [[VDCManager shareObject]getVDCItemByMtv:currentMtv_ urlString:nil];
        }
        
        [progressView_ setCacheKey:localFileVDCItem_.key];
    }
#endif
    if(currentMtv_)
    {
        [maxPannel_ setMTVItem:currentMtv_ sample:currentSample_];
        //                maxPannel_.MTVItem = currentMtv_;
    }
    if(currentMtv_ && currentMtv_.AudioRemoteUrl && currentMtv_.AudioRemoteUrl.length>2)
    {
        [playPannel_ setUseGuidAudio:YES];
        [progressView_ setGuidAudio:YES];
    }
    else
    {
        [playPannel_ setUseGuidAudio:NO];
        [progressView_ setGuidAudio:NO];
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
- (void)pauseItem:(id)sender
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
    NSString * path = [item getMTVUrlString:netStatus_ userID:userInfo_.UserID remoteUrl:nil];
    
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
        pauseUnexpected_ = NO;
        
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
            [WTVideoPlayerView isDownloadCompleted:&item Sample:nil NetStatus:netStatus_ UserID:userInfo_.UserID];
        }
    }
#endif
    path = [item getMTVUrlString:netStatus_ userID:userInfo_.UserID remoteUrl:nil];
    
    if(path && path.length != 0)
    {
        //[self showHUDViewInThread];
        NSString * audioUrl = nil;
        //下载导唱的数据
        if([self currentItemIsSample] ||item.UserID==userInfo_.UserID)
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
            [self setCurrentMTV:item];
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
        [self showMessage:MSG_ERROR msg:@"没有获取到正确的数据，请检查网络后重试!"];
        return NO;
    }
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
    if ([self canShowComment] && ([self isMaxWindowPlay] || [self isFullScreen])){
        if(!mplayer_.commentListView)
        {
            [self initCommentView];
        }
        [mplayer_ showComments];
    } else {
        [mplayer_ hideComments];
    }
}
- (void)videoPlayerViewDidReachEnd:(WTVideoPlayerView *)videoPlayerView
{
    //[commentManager_ stopCommentTimer];
    [mplayer_.commentManager stopCommentTimer];
    
    currentPlaySeconds_ = 0;
    [self pauseItem:nil];
    
    [self removePlayerInThread];
}
- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView timeDidChange:(CGFloat)cmTime
{
    if(cmTime < 0.15)
    return;
    
    [self showProgressSync:cmTime];
    
    CGFloat progress = cmTime;
    currentPlaySeconds_ = progress;
    
    if (leaderPlayer_ && needPlayLeader_) {
        leaderPlayer_.currentTime = progress + DELAYSEC;
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
        [lyricView_ didPlayingWithSecond:secondsPlaying];
    }
    // 同步comment的时间
    if([self canShowComment] && commentManager_)
    {
        [commentManager_ setCurrentDuranceWhen:progress];
    }
    if ([self.delegate respondsToSelector:@selector(videoPlayerView:timeDidChange:)])
    {
        [self.delegate videoPlayerView:videoPlayer timeDidChange:secondsPlaying];
    }
}
- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView didStalled:(AVPlayerItem *)playerItem
{
    NSLog(@"playing pause by stalled");
    //此处不易中断处理，在Loader代理情况下，如果中断，会导致下载停止,IOS 7以下，不使用Loader
    if([DeviceConfig IOSVersion]<7.0)
    {
        [self pauseItem:nil];
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
                [self pauseItem:nil];
            }
            else
            {
                [self pauseItem:nil];
            }
        }
        else
        {
            [self pauseItem:nil];
        }
    }
    else
    {
        [self pauseItem:nil];
    }
#else
    [self pauseItem:nil];
#endif
}
- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView pausedByUnexpected:(NSError *)error item:(AVPlayerItem *)playerItem
{
    NSLog(@"playing pausedByUnexpected:%@",[error localizedDescription]);
    pauseUnexpected_ = YES;
    if(leaderPlayer_)
    {
        [leaderPlayer_ pause];
    }
    
}
- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView autoPlayAfterPause:(NSError *)error item:(AVPlayerItem *)playerItem
{
    if(!pauseUnexpected_)
    {
        [self pauseItem:nil];
        NSLog(@"playing auto, no unexpected stop, so pause.");
    }
    pauseUnexpected_ = NO;
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
#pragma mark - view
- (MTV*)getCurrentMTV
{
    return currentMtv_;
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
        if(!currentMtv_ || currentMtv_.IsLandscape)
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
    PP_RELEASE(_commentManager);
    PP_RELEASE(_commentListView);
    PP_RELEASE(_lyricView);
    PP_RELEASE(_activityView_);
}
- (void)dealloc
{
    [self readyToRelease];
    PP_SUPPERDEALLOC;
}
@end
