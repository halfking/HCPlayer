//
//  HCPlayerWrapper(Play).m
//  HCPlayerTest
//
//  Created by HUANGXUTAO on 16/5/5.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import "HCPlayerWrapper(Play).h"
#import <AVFoundation/AVFoundation.h>
#import <hccoren/base.h>
#import <HCBaseSystem/user_wt.h>
#import <HCBaseSystem/SNAlertView.h>
#import <HCMVManager/VdcManager_full.h>

#import "MediaPlayer/MPMediaItem.h"
#import "MediaPlayer/MPNowPlayingInfoCenter.h"
#import "WTVideoPlayerView.h"
#import "WTVideoPlayerView(MTV).h"
#import "WTVideoPlayerProgressView.h"


#import "HCPlayerWrapper(Lyric).h"
#import "HCPlayerWrapper(Data).h"
#import "HCPlayerWrapper(background).h"

@implementation HCPlayerWrapper(Play)
#pragma mark - play pause changeitem 核心操作，这些操作可以当作原子操作
- (void)pauseItemWithCoreEvents
{
    NSLog(@"pauseItemWithCoreEvents");
    //[commentManager_ stopCommentTimer];
    [commentManager_ stopCommentTimer];
    
    if(mplayer_)// && mplayer.playing)
    {
        [mplayer_ pauseWithCache];
    }
    if (leaderPlayer_) {
        [leaderPlayer_ pause];
    }
//    playOrPause_.enabled = YES;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)playItemWithCoreEvents:(CGFloat)seconds
{
    if(!mplayer_)
    {
        [self play];
        return;
    }
    lastPlaySecondsForBackInfo_ = 0;
#ifdef USE_CACHEPLAYING
    if([userManager_ enableCachenWhenPlaying])
    {
        if(localFileVDCItem_ && localFileVDCItem_.needStop)
        {
            localFileVDCItem_.needStop = NO;
        }
    }
#endif
    //    MTV * currentItem = [self getCurrentMTV];
    if(mplayer_ && !mplayer_.playing)
    {
        //        if(currentItem.MTVID!=0)
        //        {
        //            if(CMTimeGetSeconds([mplayer_ durationWhen])>=currentItem.Durance-0.01 && currentItem.Durance>0)
        //            {
        //                [mplayer_ seek:0 accurate:YES];
        //            }
        //        }
        if(seconds>=0)
        {
            [mplayer_ seek:seconds accurate:YES];
        }
        [mplayer_ play];
        if (leaderPlayer_) {
            //等待播放进度稳定
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                needPlayLeader_ = YES;
            });
        }
        
        if(mplayer_.hidden==YES)
        {
            mplayer_.alpha = 0;
            mplayer_.hidden = NO;
            [UIView animateWithDuration:0.35 animations:^(void)
             {
                 mplayer_.alpha = 1;
             }completion:^(BOOL completed)
             {
                 
             }];
        }
        [self setTotalSeconds: CMTimeGetSeconds(mplayer_.duration)];
    }
    else if(mplayer_ && mplayer_.playing)
    {
        if(seconds>=0 && seconds < CMTimeGetSeconds(mplayer_.duration))
        {
            [mplayer_ seek:seconds accurate:YES];
            needPlayLeader_ = YES; //需要人声同步
        }
    }
//    playOrPause_.enabled = YES;
    NSLog(@"playItemWithCoreEvents");
    
    [commentManager_ startCommentTimer];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}
- (void)playItemChangeWithCoreEvents:(NSString *)path orgPath:(NSString*)orgPath mtv:(MTV*)item beginSeconds:(CGFloat)beginSeconds
{
    [self playItemChangeWithReady:path orgPath:orgPath mtv:item beginSeconds:beginSeconds play:YES];
}

- (void)playItemChangeWithReady:(NSString *)path orgPath:(NSString*)orgPath mtv:(MTV*)item beginSeconds:(CGFloat)beginSeconds play:(BOOL)play
{
    if (mplayer_) {
        [self removePlayerInThread];
    }
    
    [self hidePlayerWaitingView];
    
    CGRect playerFrame = [self getPlayerFrame];
    if (!mplayer_) {
        //        mplayer_ = [WTVideoPlayerView sharedWTVideoPlayerView];
        mplayer_ = [[WTVideoPlayerView alloc]initWithFrame:playerFrame];
        
        //        [self initCommentView];
        //        [mplayer_ resetCommentsFrame:mplayer_.frame container:self.view textContainer:self.view];
    }
    else
    {
        [mplayer_ resizeViewToRect:playerFrame andUpdateBounds:YES withAnimation:NO hidden:NO changed:nil];
        //    mplayer_.frame = playerFrame;
    }
#ifdef  USE_CACHEPLAYING
    if([userManager_ enableCachenWhenPlaying])
    {
        mplayer_.cachingWhenPlaying = YES;
    }
    else
    {
        mplayer_.cachingWhenPlaying = NO;
    }
#else
    mplayer_.cachingWhenPlaying = NO;
#endif
    mplayer_.userInteractionEnabled = NO;
    mplayer_.delegate = self;
    
    //点击播放时，自动显示进度
    //    {
    //        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showProgressView:)];
    //        [mplayer_ addGestureRecognizer:tap];
    //        PP_RELEASE(tap);
    //    }
    
    NSLog(@"play item:%@",path);
    [mplayer_ changeCurrentItemPath:path];
    
    //    if([self currentItemIsSample])
    //    {
    //        [mplayer_ setVideoVolume:[[[UserManager sharedUserManager] getUserBackgroundVolume] floatValue]];
    //    }
    //    else
    //    {
    //        [mplayer_ setVideoVolume:1];
    //    }
    mplayer_.playerItemKey = [item getKey];
#ifdef USE_CACHEPLAYING
    if([userManager_ enableCachenWhenPlaying])
    {
        if (localFileVDCItem_ && localFileVDCItem_.AudioPath && localFileVDCItem_.AudioPath.length > 5 && [HCFileManager isLocalFile:localFileVDCItem_.AudioPath] && item.MTVID == 0) {
            
            NSLog(@"play guide audio:%@",localFileVDCItem_.AudioPath);
            if(leaderPlayer_)
            {
                leaderPlayer_.delegate = nil;
                PP_RELEASE(leaderPlayer_);
            }
            leaderPlayer_ = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:localFileVDCItem_.AudioPath] error:nil];
            leaderPlayer_.volume = 1; //默认播
            [maxPannel_ setUseGuidAudio:YES];
            [playPannel_ setUseGuidAudio:YES];
        }
        else
        {
            if(leaderPlayer_)
            {
                leaderPlayer_.delegate = nil;
                PP_RELEASE(leaderPlayer_);
            }
            [maxPannel_ setUseGuidAudio:NO];
            [playPannel_ setUseGuidAudio:NO];
        }
    }
    else
    {
        [maxPannel_ setUseGuidAudio:NO];
        [playPannel_ setUseGuidAudio:NO];
    }
#else
    [maxPannel_ setUseGuidAudio:NO];
    [playPannel_ setUseGuidAudio:NO];
#endif
    
    [self addSubview:mplayer_];
    mplayer_.hidden = YES;
    [self bringToolBar2Front];
    if(beginSeconds>=0)
    {
        [mplayer_ seek:beginSeconds accurate:YES];
        if(beginSeconds>0.1)
        {
            currentPlaySeconds_ = beginSeconds;
        }
    }
    
    __weak WTVideoPlayerView * weakPlayer  = mplayer_;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong WTVideoPlayerView * player = weakPlayer;
        
        if(play)
        {
            [self playItemWithCoreEvents:beginSeconds];
            [self recordPlayItemBegin];
        }
        player.alpha = 0;
        player.hidden = NO;
        [UIView animateWithDuration:0.35 animations:^{
            player.alpha= 1;
        } completion:^(BOOL finished) {
        }];
    });
    //    mplayer_.alpha = 1;
    //[self hideHUDViewInThread];
}
- (void)removePlayerInThread
{
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self removePlayer];
                       });
    }
    else{
        [self removePlayer];
    }
}
- (void)removePlayer
{
    //    currentPlaySeconds_ = 0;
    [self recordPlayItemEnd];
    
    if(mplayer_){
        //        [self playerWillEnterForeground];
        //此处不易中断处理，在Loader代理情况下，如果中断，会导致下载停止,IOS 7以下，不使用Loader
        if([DeviceConfig IOSVersion]>=7.0)
        {
            [mplayer_ pauseWithCache];
        }
        [mplayer_ removeFromSuperview];
        [mplayer_ readyToRelease];
        currentPlaySeconds_ = 0;
        PP_RELEASE(mplayer_);
    }
    
}

//- (VDCItem *) getVDCItemByRemoveUrl:(MTV*)item path:(NSString *)path audioUrl:(NSString *)audioUrl
//{
//    VDCManager * vdcManager = [VDCManager shareObject];
//
//    VDCItem * remoteItem  = [vdcManager getVDCItemByURL:path checkFiles:NO];
//    if(remoteItem)
//    {
//        remoteItem.MTVID = item.MTVID;
//        if(remoteItem.SampleID !=item.SampleID)
//        {
//            remoteItem.SampleID = item.SampleID;
//            [[VDCManager shareObject] rememberDownloadUrl:remoteItem tempPath:remoteItem.tempFilePath];
//        }
//    }
//    return remoteItem;
//}
//- (VDCItem *) getVDCItemByLocalFile:(MTV*)item path:(NSString *)path audioUrl:(NSString*)audioUrl
//{
//
//    VDCItem * localItem = [[VDCManager shareObject]getVDCItemByURL:[item getDownloadUrlOpeated:netStatus_ userID:userInfo_.UserID] checkFiles:NO];
//    localItem.localFilePath = item.FilePath;
//    localItem.remoteUrl = item.DownloadUrl720;
//    localItem.contentLength = [[VDCManager shareObject]fileSizeForPath:item.FilePath];
//    localItem.downloadBytes = localItem.contentLength;
//
//    localItem.MTVID = item.MTVID;
//    if(localItem.SampleID !=item.SampleID)
//    {
//        localItem.SampleID = item.SampleID;
//        [[VDCManager shareObject] rememberDownloadUrl:localItem tempPath:localItem.tempFilePath];
//    }
//
//    NSLog(@"\n tempFilePath = %@ \n path = %@",localItem.tempFilePath,path);
//    // localFileVDCItem_.tempFilePath = path;
//    [[VDCManager shareObject]buildAudioPath:localItem audioUrlString:audioUrl key:localItem.key];
//    return localItem;
//}
- (BOOL) playRemoteFile:(MTV *)item path:(NSString *)path audioUrl:(NSString*)audioUrl seconds:(CGFloat)seconds
{
    
    //先停，让它不要再去读缓存了
    [self removePlayerInThread];
    
    [self showPlayerWaitingView];
    
    //    localFileVDCItem_  = [self getVDCItemByRemoveUrl:item path:path audioUrl:audioUrl];
#ifdef USE_CACHEPLAYING
    VDCManager * vdcManager = [VDCManager shareObject];
    if([userManager_ enableCachenWhenPlaying])
    {
        
        localFileVDCItem_  = [WTVideoPlayerView getVDCItem:item Sample:nil];
        
        if((!localFileVDCItem_ || localFileVDCItem_.contentLength > localFileVDCItem_.downloadBytes)
           && netStatus_==ReachableViaWWAN
           )
        {
            if([[UserManager sharedUserManager]canShowNotickeFor3G])
            {
                //[self hideHUDViewInThread];
                [self hidePlayerWaitingView];
                [self showNoticeForWWAN];
                return NO;
            }
        }
    }
    else
    {
        if(netStatus_==ReachableViaWWAN)
        {
            if([[UserManager sharedUserManager]canShowNotickeFor3G])
            {
                //[self hideHUDViewInThread];
                [self hidePlayerWaitingView];
                [self showNoticeForWWAN];
                return NO;
            }
        }
    }
#else
    if([DeviceConfig config].networkStatus ==ReachableViaWWAN)
    {
        if([[UserManager sharedUserManager]canShowNotickeFor3G])
        {
            //[self hideHUDViewInThread];
            [self hidePlayerWaitingView];
            [self showNoticeForWWAN];
            return NO;
        }
    }
#endif
    //[self showHUDViewInThread];
    NSLog(@"playing ready to %@",path);
    [self showPlayerWaitingView];
    
#ifdef USE_CACHEPLAYING
    if([userManager_ enableCachenWhenPlaying])
    {
        
        __weak MTV * weakMtv = [self getCurrentMTV];
        __weak NSString * weakPath = path;
        NSString *title = [NSString stringWithFormat:@"%@  (%@)",item.Title,item.Author];
        
        [vdcManager addUrlCache:path audioUrl:nil title:title urlReady:^(VDCItem * vdcItem,NSURL * url)
         {
             //如果是多次重复调用，则不处理
             if(localFileVDCItem_ && [localFileVDCItem_.key isEqualToString:vdcItem.key])
             {
                 if(mplayer_ && mplayer_.playing) return;
                 [NSThread sleepForTimeInterval:0.1];
                 if(mplayer_ && mplayer_.playing)
                 return;
             }
             
             [self showButtonsPlaying];
             
             localFileVDCItem_ = vdcItem;
             localFileVDCItem_.MTVID = weakMtv.MTVID;
             
             //mediaEditManager_.accompanyDownKey = localFileVDCItem_.key;
             
             if(vdcItem.SampleID !=weakMtv.SampleID)
             {
                 localFileVDCItem_.SampleID = weakMtv.SampleID;
                 [[VDCManager shareObject] rememberDownloadUrl:localFileVDCItem_ tempPath:localFileVDCItem_.tempFilePath];
             }
             
             NSLog(@"playing item url begin:%@",[url absoluteString]);
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [self updateFilePath:weakMtv filePath:vdcItem.localFilePath];
                 
                 NSString * newPath = url.absoluteString;
                 NSLog(@"**-- Play:%@",newPath?newPath:@"文件可能没有上传，但本地文件又不在了，所以会出现NULL值");
                 [self playItemChangeWithCoreEvents:newPath orgPath:weakPath mtv:item beginSeconds:seconds];
                 
                 if (seconds <0.1 &&(([UserManager sharedUserManager].isFirstEnterMain && weakMtv.MTVID == 0) || weakMtv.UserID == userInfo_.UserID)) {
                     //[self showTitleInThread:YES];
                 }
                 else
                 {
                     //titleTimer_ = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideTitleInThread:) userInfo:nil repeats:NO];
                 }
                 
             });
         } completed:^(VDCItem * vdcItem,BOOL completed,VDCTempFileInfo * tempFile)
         {
             // 如果是看他人的视频，下载完成删除临时文件
             if (item.MTVID != 0 && ![HCFileManager isLocalFile:weakPath])
             {
                 if ([[VDCManager shareObject] isItemDownloadCompleted:vdcItem])
                 {
                     vdcItem.isDownloading = NO;
                     [[VDCManager shareObject] removeTemplateFilesByUrl:weakPath];
                     vdcItem.tempFileList = nil;
                     vdcItem.SampleID = weakMtv.SampleID;
                     [[VDCManager shareObject] rememberDownloadUrl:vdcItem tempPath:vdcItem.tempFilePath];
                 }
             }
             [self downloadUserAudio:weakMtv];
         }];
    }
    else
    {
        NSLog(@"playing item url begin:%@",path);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self playItemChangeWithCoreEvents:path orgPath:path mtv:item beginSeconds:seconds];
            
        });
    }
#else
    NSLog(@"playing item url begin:%@",path);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self playItemChangeWithCoreEvents:path orgPath:path mtv:item beginSeconds:seconds];
        
    });
#endif
    return YES;
}

- (void) playLocalFile:(MTV *)item path:(NSString *)path audioUrl:(NSString*)audioUrl seconds:(CGFloat)seconds play:(BOOL)play
{
    //    localFileVDCItem_ = [self getVDCItemByLocalFile:item path:path audioUrl:audioUrl];
    
#ifdef USE_CACHEPLAYING
    if([userManager_ enableCachenWhenPlaying])
    {
        localFileVDCItem_  = [WTVideoPlayerView getVDCItem:item Sample:nil];
        
        mediaEditManager_.accompanyDownKey = localFileVDCItem_.key;
        
        NSLog(@"playing ready2 to %@",path);
        if([NSThread isMainThread])
        {
            if(!play)
            [self playItemChangeWithReady:path orgPath:path mtv:item beginSeconds:seconds play:NO];
            else
            {
                [self playItemChangeWithCoreEvents:path orgPath:path mtv:item beginSeconds:seconds];
                //看别人的没有标题
                if (seconds <0.1&&(([UserManager sharedUserManager].isFirstEnterMain && item.MTVID == 0) || item.UserID == userInfo_.UserID) ) {
                    //[self showTitleInThread:YES];
                }
                else
                {
                    //titleTimer_ = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideTitleInThread:) userInfo:nil repeats:NO];
                }
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(!play)
                [self playItemChangeWithReady:path orgPath:path mtv:item beginSeconds:seconds play:NO];
                else
                {
                    [self playItemChangeWithCoreEvents:path orgPath:path mtv:item beginSeconds:seconds];
                    
                    if (seconds <0.1&&(([UserManager sharedUserManager].isFirstEnterMain && item.MTVID == 0) || item.UserID == userInfo_.UserID) ) {
                        //[self showTitleInThread:YES];
                    }
                    else
                    {
                        //titleTimer_ = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideTitleInThread:) userInfo:nil repeats:NO];
                    }
                }
            });
        }
        if(item.SampleID>0 && item.MTVID ==0)
        {
            [self downloadUserAudio:item];
        }
    }
    else
    {
        if([NSThread isMainThread])
        {
            if(!play)
            {
                [self playItemChangeWithReady:path orgPath:path mtv:item beginSeconds:seconds play:NO];
            }
            else
            {
                [self playItemChangeWithCoreEvents:path orgPath:path mtv:item beginSeconds:seconds];
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(!play)
                {
                    [self playItemChangeWithReady:path orgPath:path mtv:item beginSeconds:seconds play:NO];
                }
                else
                {
                    [self playItemChangeWithCoreEvents:path orgPath:path mtv:item beginSeconds:seconds];
                    
                }
            });
        }
    }
#else
    if([NSThread isMainThread])
    {
        if(!play)
        {
            [self playItemChangeWithReady:path orgPath:path mtv:item beginSeconds:seconds play:NO];
        }
        else
        {
            [self playItemChangeWithCoreEvents:path orgPath:path mtv:item beginSeconds:seconds];
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(!play)
            {
                [self playItemChangeWithReady:path orgPath:path mtv:item beginSeconds:seconds play:NO];
            }
            else
            {
                [self playItemChangeWithCoreEvents:path orgPath:path mtv:item beginSeconds:seconds];
                
            }
        });
    }
#endif
}
@end
