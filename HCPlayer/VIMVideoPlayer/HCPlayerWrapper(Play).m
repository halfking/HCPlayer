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
#import <hccoren/NSString+CC.h>
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
#pragma mark - 业务相关

- (void)playItemChangeWithCoreEvents:(NSString *)path /*orgPath:(NSString*)orgPath mtv:(MTV*)item */ beginSeconds:(CGFloat)beginSeconds play:(BOOL)play

{
    [self buildMPlayer];
    
    NSLog(@"play item:%@",path);
    [self showSecondsWasted:@"begin to setpath"];
    [mplayer_ changeCurrentItemPath:path];
    
    
    if(localFileVDCItem_)
        mplayer_.playerItemKey = localFileVDCItem_.key;//[item getKey];
    else
        mplayer_.playerItemKey = [path md5Digest];
    
    if([userManager_ enableCachenWhenPlaying])
    {
        if (localFileVDCItem_ && localFileVDCItem_.AudioPath && localFileVDCItem_.AudioPath.length > 5 && [HCFileManager isLocalFile:localFileVDCItem_.AudioPath]) {
            
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
    
    [self addSubview:mplayer_];
    
    [self showSecondsWasted:@"play withcore"];
    [self showMPlayer:play seconds:beginSeconds];
}

- (void)playItemWithPlayerItem:(AVPlayerItem *)playerItem beginSeconds:(CGFloat)beginSeconds play:(BOOL)play
{
    [self buildMPlayer];
    [mplayer_ changeCurrentPlayerItem:playerItem];
    
    [self showSecondsWasted:@"play with item"];
    [maxPannel_ setUseGuidAudio:NO];
    [playPannel_ setUseGuidAudio:NO];
    [progressView_ setGuidAudio:NO];
    
    [self showMPlayer:play seconds:beginSeconds];
    
}
#pragma mark - prepares
- (BOOL) playRemoteFile:(MTV *)item path:(NSString *)path audioUrl:(NSString*)audioUrl seconds:(CGFloat)seconds
{
    //先停，让它不要再去读缓存了
//    [self removePlayerInThread];
    
    [self showPlayerWaitingView];
    
    VDCManager * vdcManager = [VDCManager shareObject];
    if([userManager_ enableCachenWhenPlaying])
    {
        localFileVDCItem_ = [[VDCManager shareObject]getVDCItemByURL:path checkFiles:YES];
        BOOL audioNeedDownload = audioUrl && audioUrl.length>2 && [HCFileManager isUrlOK:audioUrl];
        if((!localFileVDCItem_ || localFileVDCItem_.contentLength > localFileVDCItem_.downloadBytes || audioNeedDownload)
           && [DeviceConfig config].networkStatus==ReachableViaWWAN
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
        if([DeviceConfig config].networkStatus==ReachableViaWWAN)
        {
            if([[UserManager sharedUserManager]canShowNotickeFor3G])
            {
                [self hidePlayerWaitingView];
                [self showNoticeForWWAN];
                return NO;
            }
        }
    }
    
    //[self showHUDViewInThread];
    NSLog(@"playing ready to %@",path);
//    [self showPlayerWaitingView];
    
    if([userManager_ enableCachenWhenPlaying])
    {
        
        __weak MTV * weakMtv = [self getCurrentMTV];
        __weak NSString * weakPath = path;
        NSString *title = [NSString stringWithFormat:@"%@  (%@)",item.Title,item.Author];
        
        //自动下载缓存，并提前下载音频文件
        [vdcManager addUrlCache:path audioUrl:audioUrl title:title urlReady:^(VDCItem * vdcItem,NSURL * url)
         {
             //如果是多次重复调用，则不处理
             if(localFileVDCItem_ && [localFileVDCItem_.key isEqualToString:vdcItem.key])
             {
                 if(mplayer_ && mplayer_.playing)
                 {
                     [NSThread sleepForTimeInterval:0.1];
                 }
                 if(mplayer_ && mplayer_.playing)
                     return;
             }
             
             [self showButtonsPlaying];
             
             localFileVDCItem_ = vdcItem;
             localFileVDCItem_.MTVID = weakMtv.MTVID;
             
             if(vdcItem.SampleID !=weakMtv.SampleID)
             {
                 localFileVDCItem_.SampleID = weakMtv.SampleID;
                 [[VDCManager shareObject] rememberDownloadUrl:localFileVDCItem_ tempPath:localFileVDCItem_.tempFilePath];
             }
             [self showSecondsWasted:@"play vdc get"];
             NSLog(@"playing item url begin:%@",[url absoluteString]);
             dispatch_async(dispatch_get_main_queue(), ^{
                 if(weakMtv)
                 {
                     [self updateFilePath:weakMtv filePath:vdcItem.localFilePath];
                 }
                 NSString * newPath = [url path];
                 NSLog(@"**-- Play:%@",newPath?newPath:@"文件可能没有上传，但本地文件又不在了，所以会出现NULL值");
                 
                 [self playItemChangeWithCoreEvents:newPath /*orgPath:weakPath mtv:item */ beginSeconds:seconds play:YES];
                 
                 if (weakMtv && seconds <0.1 &&(([UserManager sharedUserManager].isFirstEnterMain && weakMtv.MTVID == 0)
                                                || weakMtv.UserID == [userManager_ userID])) {
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
            [self playItemChangeWithCoreEvents:path beginSeconds:seconds play:YES];
            
        });
    }
    return YES;
}

- (void) playLocalFile:(MTV *)item path:(NSString *)path audioUrl:(NSString*)audioUrl seconds:(CGFloat)seconds play:(BOOL)play
{
    if(audioUrl && audioUrl.length>0 && [HCFileManager isUrlOK:audioUrl])
    {
        [self playRemoteFile:item path:path audioUrl:audioUrl seconds:seconds];
        return;
    }
    
    if([userManager_ enableCachenWhenPlaying])
    {
        if(item)
            localFileVDCItem_  = [WTVideoPlayerView getVDCItem:item Sample:nil];
        else
            localFileVDCItem_ = [[VDCManager shareObject]getVDCItemByLocalFile:path];
        [localFileVDCItem_ setAudioFileName:[[HCFileManager manager] getFileName:audioUrl]];
    }
    else
    {
        
        localFileVDCItem_ = [[VDCManager shareObject]getVDCItemByLocalFile:path];
        localFileVDCItem_.localFileName = [[HCFileManager manager] getFileName:path];
        localFileVDCItem_.AudioFileName = [[HCFileManager manager] getFileName:audioUrl];
        localFileVDCItem_.title = item.Title;
    }
    [self showSecondsWasted:@"play get localvdc"];
    NSLog(@"playing ready2 to %@",path);

        if(!play)
            [self playItemChangeWithCoreEvents:path  beginSeconds:seconds play:NO];
        else
        {
            [self playItemChangeWithCoreEvents:path beginSeconds:seconds play:YES];

        }
}
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
    
    if([userManager_ enableCachenWhenPlaying])
    {
        if(localFileVDCItem_ && localFileVDCItem_.needStop)
        {
            localFileVDCItem_.needStop = NO;
        }
    }
    [self setMPlayerSettings];
    
    if(!mplayer_.playing)
    {
        if(seconds>=0 && fabs(mplayer_.secondsPlaying - seconds)>=0.1)
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
        [self setTotalSeconds: CMTimeGetSeconds(mplayer_.duration)];
    }
    else
    {
        if(seconds>=0  && fabs(mplayer_.secondsPlaying - seconds)>=0.1 )//&& seconds < CMTimeGetSeconds(mplayer_.duration))
        {
            [mplayer_ seek:seconds accurate:YES];
            needPlayLeader_ = YES; //需要人声同步
        }
    }
    
    NSLog(@"playItemWithCoreEvents");
    
    [self hidePlayerWaitingView];
    [commentManager_ startCommentTimer];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

#pragma mark - base functions
- (void)setMPlayerSettings
{
    [mplayer_ setRate:playRate_];
    if(mplayer_)
    {
        [mplayer_ setVideoVolume:playVol_];
    }
    
    if(leaderPlayer_)
    {
        [leaderPlayer_ setVolume:leaderVol_];
    }
}
- (void)buildMPlayer
{
    if (mplayer_) {
        [self removePlayerInThread];
    }
    
    [self showPlayerWaitingView];
    
    CGRect playerFrame = [self getPlayerFrame];
    if (!mplayer_) {
        mplayer_ = [[WTVideoPlayerView alloc]initWithFrame:playerFrame];
    }
    else
    {
        [mplayer_ resizeViewToRect:playerFrame andUpdateBounds:YES withAnimation:NO hidden:NO changed:nil];
    }
    //    [mplayer_ setRate:playRate_];
    mplayer_.userInteractionEnabled = NO;
    mplayer_.delegate = self;
    mplayer_.playerItemKey = nil;
    if([userManager_ enableCachenWhenPlaying])
    {
        mplayer_.cachingWhenPlaying = YES;
    }
    else
    {
        mplayer_.cachingWhenPlaying = NO;
    }
    mplayer_.hidden = YES;
    [self addSubview:mplayer_];
    [self showSecondsWasted:@"play build"];
    
}
- (void)showMPlayer:(BOOL)autoPlay seconds:(CGFloat)beginSeconds
{
    [self showSecondsWasted:@"play seek begin 0"];
    if(beginSeconds>=0)
    {
        [mplayer_ seek:beginSeconds accurate:YES];
        if(beginSeconds>0.1)
        {
            currentPlaySeconds_ = beginSeconds;
        }
    }
    [self showSecondsWasted:@"play seek end"];
    [self bringToolBar2Front];
    [self showSecondsWasted:@"play show 0"];
    if(autoPlay)
    {
        [self playItemWithCoreEvents:beginSeconds];
        [self recordPlayItemBegin];
    }
    [self showSecondsWasted:@"play show 1"];
    [self showMPlayerAnimates];
    [self showSecondsWasted:@"play show finished"];
}
- (void)showMPlayerAnimates
{
    if([NSThread isMainThread])
    {
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
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showMPlayerAnimates];
        });
    }
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

#pragma mark - download user audio
- (BOOL)downloadUserAudio:(MTV *)mtv
{
    if(!mtv || mtv.MTVID==0) return NO;
    if(!mtv.AudioRemoteUrl || mtv.AudioRemoteUrl.length<3) return NO;
    
    localFileVDCItem_.AudioUrl = mtv.AudioRemoteUrl;
    localFileVDCItem_.AudioFileName = mtv.AudioFileName;
    if(![[VDCManager shareObject] checkAudioPath:localFileVDCItem_])
    {
        [[VDCManager shareObject]downloadUrl:mtv.AudioRemoteUrl
                                       title:[NSString stringWithFormat:@"%@ 用户音频",mtv.Title]
                                    urlReady:^(VDCItem *vdcItem, NSURL *videoUrl) {
                                        
                                    } progress:^(VDCItem *vdcItem) {
                                        
                                    } completed:^(VDCItem *vdcItem, BOOL completed, VDCTempFileInfo *tempFile) {
                                        if([HCFileManager isFileExistAndNotEmpty:vdcItem.localFilePath size:nil])
                                        {
                                            if(mtv.AudioFileName && mtv.AudioFileName.length>0)
                                            {
                                                [HCFileManager copyFile:vdcItem.localFilePath
                                                                 target:[mtv getAudioPathN]
                                                              overwrite:YES];
                                                [[VDCManager shareObject]removeItem:vdcItem withTempFiles:YES includeLocal:YES];
                                            }
                                            else
                                            {
                                                [mtv setAudioPathN:vdcItem.localFileName];
                                                [[VDCManager shareObject]removeItem:vdcItem withTempFiles:YES includeLocal:NO];
                                                //                                                [[MTVUploader sharedMTVUploader]updateMTVKeyAndUserID:mtv];
                                            }
                                        }
                                    }];
        return YES;
    }
    return NO;
}
@end
