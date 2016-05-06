//
//  MusicDetailViewController(Play).m
//  maiba
//
//  Created by seentech_5 on 15/12/18.
//  Copyright © 2015年 seenvoice.com. All rights reserved.
//

#import "MusicDetailViewController(Play).h"
#import <hccoren/base.h>
#import <HCBaseSystem/user_wt.h>
#import <HCBaseSystem/SNAlertView.h>
#import <HCMVManager/VdcManager_full.h>

#import "WTVideoPlayerView(MTV).h"
#import "MediaPlayer/MPMediaItem.h"
#import "MediaPlayer/MPNowPlayingInfoCenter.h"

//#import "AudioCenter.h"

//static void ASAudioSessionInterruptionListener(void *inClientData, UInt32 inInterruptionState)
//{
//    [[MusicDetailViewController shareObject] handleInterruption:inInterruptionState];
//}
@implementation MusicDetailViewController(Play)
//- (void)handleInterruption:(UInt32 )state
//{
//    AudioQueuePropertyID inInterruptionState= (AudioQueuePropertyID)state;//[[notification object] longValue];
//    if (inInterruptionState == kAudioSessionBeginInterruption)
//    {
//        needPlaying_ = YES;
//        [self pauseItem:nil];
//        NSLog(@"begin interruption——->");
//    }
//    else if (inInterruptionState == kAudioSessionEndInterruption)
//    {
//        if(needPlaying_)
//        {
//            [self playItem:nil seconds:-1];
//        }
//        NSLog(@"end interruption——->");
//    }
//}
//#pragma mark - play or pause
//- (void)pauseItem:(id)sender
//{
//    [self showButtonsPause];
//    [self pauseItemWithCoreEvents];
//}
//
//
//- (BOOL)playItem:(id)sender seconds:(CGFloat)seconds
//{
//    [self showButtonsPlaying];
//    MTV * item = [self getCurrentMTV];
//    currentPlaySeconds_ = 0;
//    //    float lastLrcTime = 0;
//#ifdef USE_CACHEPLAYING
//    if([userManager_ enableCachenWhenPlaying])
//    {
//        if(!item.isCheckDownload)
//        {
//            [WTVideoPlayerView isDownloadCompleted:&item Sample:nil NetStatus:netStatus_ UserID:userInfo_.UserID];
//        }
//    }
//#endif
//    NSString * path = [item getMTVUrlString:netStatus_ userID:userInfo_.UserID remoteUrl:nil];
//    
//    if(mplayer_ && [mplayer_ isCurrentPath:path])
//    {
//        //[self hideHUDViewInThread];
//        //暂停后播放需要回退
//        //[self showButtonsInThreadWithMTV:item animate:NO];
//        //        playOrPause_.enabled = NO;
//        [self showButtonsPlaying];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            [self playItemWithCoreEvents:seconds];
//        });
//        return YES;
//    }
//    else
//    {
//        pauseUnexpected_ = NO;
//        
//        
//        //播放别人的MTV过程当中暂停继续播放，并且发生文件切换，此时应从中断位置开始。
//        //        if(item.MTVID!=0 && [mplayer_ isCurrentMTV:item])
//        //        {
//        //            lastLrcTime = CMTimeGetSeconds([mplayer_ durationWhen]);
//        //            if(lastLrcTime >= item.Durance-0.1 && item.Durance>0)
//        //            {
//        //                lastLrcTime = 0;
//        //            }
//        //        }
//        //        else
//        if([mplayer_ isCurrentMTV:item])
//        {
//            if(mplayer_ && [mplayer_ getCurrentUrl]) {
//                [self showButtonsPlaying];
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    [self playItemWithCoreEvents:seconds];
//                });
//                return YES;
//            }
//        }
//        
//        return [self updatePlayer:item seconds:seconds];
//    }
//    
//}
//
////滚动的时候也会触发该事件
////更换当前播放的对像或者再次播放
////在此之前，请不要更新currentMtv对像
//-(BOOL) updatePlayer:(MTV *)item seconds:(CGFloat)seconds
//{
//    __block NSString * path;
//#ifdef USE_CACHEPLAYING
//    if([userManager_ enableCachenWhenPlaying])
//    {
//        if(!item.isCheckDownload)
//        {
//            [WTVideoPlayerView isDownloadCompleted:&item Sample:nil NetStatus:netStatus_ UserID:userInfo_.UserID];
//        }
//    }
//#endif
//    path = [item getMTVUrlString:netStatus_ userID:userInfo_.UserID remoteUrl:nil];
//    
//    if(path && path.length != 0)
//    {
//        //[self showHUDViewInThread];
//        NSString * audioUrl = nil;
//        //下载导唱的数据
//        if([self currentItemIsSample] ||item.UserID==userInfo_.UserID)
//        {
//            audioUrl = item.AudioRemoteUrl;
//        }
//        
////        [[UMShareObject shareObject]event:@"PlayBegin" attributes:@{@"title":item.Title?item.Title:@"NoName",@"url":path}];
//        if([HCFileManager isLocalFile:path] && [HCFileManager isExistsFile:path])
//        {
//            [self playLocalFile:item path:path audioUrl:audioUrl seconds:seconds play:YES];
//        }
//        else
//        {
//            if(![self playRemoteFile:item path:path audioUrl:audioUrl seconds:seconds])
//            {
//                return NO;
//            }
//        }
//        if([self getCurrentMTV]!=item)
//        {
//            [self setCurrentMTV:item];
//        }
//        
//        //[self refreshButtonStateInThreadWithMTV:item];
//        
//        
//        return YES;
//    }
//    else if(item)
//    {
//        NSLog(@"invalid item path(not found)");
////        [self showMessage:MSG_ERROR msg:MSG_FILENOTFOUND];
//        return NO;
//    }
//    else
//    {
//        [self showMessage:MSG_ERROR msg:@"没有获取到正确的数据，请检查网络后重试!"];
//        return NO;
//    }
//}
//
//
//#pragma mark - play pause changeitem 核心操作，这些操作可以当作原子操作
//- (void)pauseItemWithCoreEvents
//{
//    NSLog(@"pauseItemWithCoreEvents");
//    //[commentManager_ stopCommentTimer];
////    [mplayer_.commentManager stopCommentTimer];
//    
//    if(mplayer_)// && mplayer.playing)
//    {
//        [mplayer_ pauseWithCache];
//    }
//    if (leaderPlayer_) {
//        [leaderPlayer_ pause];
//    }
//    playOrPause_.enabled = YES;
//    
//    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
//}
//
//- (void)playItemWithCoreEvents:(CGFloat)seconds
//{
//    if(!mplayer_)
//    {
//        [self playItem:nil seconds:-1];
//        return;
//    }
//    lastPlaySecondsForBackInfo_ = 0;
//#ifdef USE_CACHEPLAYING
//    if([userManager_ enableCachenWhenPlaying])
//    {
//        if(localFileVDCItem_ && localFileVDCItem_.needStop)
//        {
//            localFileVDCItem_.needStop = NO;
//        }
//    }
//#endif
//    //    MTV * currentItem = [self getCurrentMTV];
//    if(mplayer_ && !mplayer_.playing)
//    {
//        //        if(currentItem.MTVID!=0)
//        //        {
//        //            if(CMTimeGetSeconds([mplayer_ durationWhen])>=currentItem.Durance-0.01 && currentItem.Durance>0)
//        //            {
//        //                [mplayer_ seek:0 accurate:YES];
//        //            }
//        //        }
//        if(seconds>=0)
//        {
//            [mplayer_ seek:seconds accurate:YES];
//        }
//        [mplayer_ play];
//        if (leaderPlayer_) {
//            //等待播放进度稳定
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                needPlayLeader_ = YES;
//            });
//        }
//        
//        if(mplayer_.hidden==YES)
//        {
//            mplayer_.alpha = 0;
//            mplayer_.hidden = NO;
//            [UIView animateWithDuration:0.35 animations:^(void)
//             {
//                 mplayer_.alpha = 1;
//             }completion:^(BOOL completed)
//             {
//                 
//             }];
//        }
//        [self setTotalSeconds: CMTimeGetSeconds(mplayer_.duration)];
//    }
//    else if(mplayer_ && mplayer_.playing)
//    {
//        if(seconds>=0 && seconds < CMTimeGetSeconds(mplayer_.duration))
//        {
//            [mplayer_ seek:seconds accurate:YES];
//            needPlayLeader_ = YES; //需要人声同步
//        }
//    }
//    playOrPause_.enabled = YES;
//    NSLog(@"playItemWithCoreEvents");
//    
////    [mplayer_.commentManager startCommentTimer];
//    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
//}
//- (void)playItemChangeWithCoreEvents:(NSString *)path orgPath:(NSString*)orgPath mtv:(MTV*)item beginSeconds:(CGFloat)beginSeconds
//{
//    [self playItemChangeWithReady:path orgPath:orgPath mtv:item beginSeconds:beginSeconds play:YES];
//}
//
//- (void)playItemChangeWithReady:(NSString *)path orgPath:(NSString*)orgPath mtv:(MTV*)item beginSeconds:(CGFloat)beginSeconds play:(BOOL)play
//{
//    if (mplayer_) {
//        [self removePlayerInThread];
//    }
//    
//    [self hidePlayerWaitingView];
//    
//    CGRect playerFrame = [self getPlayerFrame];
//    if (!mplayer_) {
//        //        mplayer_ = [WTVideoPlayerView sharedWTVideoPlayerView];
//        mplayer_ = [[WTVideoPlayerView alloc]initWithFrame:playerFrame];
//        
////        [self initCommentView];
////        [mplayer_ resetCommentsFrame:mplayer_.frame container:self.view textContainer:self.view];
//    }
//    else
//    {
//        [mplayer_ resizeViewToRect:playerFrame andUpdateBounds:YES withAnimation:NO hidden:NO changed:nil];
//        //    mplayer_.frame = playerFrame;
//    }
//#ifdef  USE_CACHEPLAYING
//    if([userManager_ enableCachenWhenPlaying])
//    {
//        mplayer_.cachingWhenPlaying = YES;
//    }
//    else
//    {
//        mplayer_.cachingWhenPlaying = NO;
//    }
//#else
//    mplayer_.cachingWhenPlaying = NO;
//#endif
//    mplayer_.userInteractionEnabled = NO;
//    mplayer_.delegate = self;
//    
//    //点击播放时，自动显示进度
//    //    {
//    //        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showProgressView:)];
//    //        [mplayer_ addGestureRecognizer:tap];
//    //        PP_RELEASE(tap);
//    //    }
//    
//    NSLog(@"play item:%@",path);
//    [mplayer_ changeCurrentItemPath:path];
//    
//    //    if([self currentItemIsSample])
//    //    {
//    //        [mplayer_ setVideoVolume:[[[UserManager sharedUserManager] getUserBackgroundVolume] floatValue]];
//    //    }
//    //    else
//    //    {
//    //        [mplayer_ setVideoVolume:1];
//    //    }
//    mplayer_.playerItemKey = [item getKey];
//#ifdef USE_CACHEPLAYING
//    if([userManager_ enableCachenWhenPlaying])
//    {
//        if (localFileVDCItem_ && localFileVDCItem_.AudioPath && localFileVDCItem_.AudioPath.length > 5 && [HCFileManager isLocalFile:localFileVDCItem_.AudioPath] && item.MTVID == 0) {
//            
//            NSLog(@"play guide audio:%@",localFileVDCItem_.AudioPath);
//            if(leaderPlayer_)
//            {
//                leaderPlayer_.delegate = nil;
//                PP_RELEASE(leaderPlayer_);
//            }
//            leaderPlayer_ = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:localFileVDCItem_.AudioPath] error:nil];
//            leaderPlayer_.volume = 1; //默认播
//            [maxPannel_ setUseGuidAudio:YES];
//            [playPannel_ setUseGuidAudio:YES];
//        }
//        else
//        {
//            if(leaderPlayer_)
//            {
//                leaderPlayer_.delegate = nil;
//                PP_RELEASE(leaderPlayer_);
//            }
//            [maxPannel_ setUseGuidAudio:NO];
//            [playPannel_ setUseGuidAudio:NO];
//        }
//    }
//    else
//    {
//        [maxPannel_ setUseGuidAudio:NO];
//        [playPannel_ setUseGuidAudio:NO];
//    }
//#else
//    [maxPannel_ setUseGuidAudio:NO];
//    [playPannel_ setUseGuidAudio:NO];
//#endif
//    
//    [playContainerView_ addSubview:mplayer_];
//    mplayer_.hidden = YES;
//    [self bringToolBar2Front];
//    if(beginSeconds>=0)
//    {
//        [mplayer_ seek:beginSeconds accurate:YES];
//        if(beginSeconds>0.1)
//        {
//            currentPlaySeconds_ = beginSeconds;
//        }
//    }
//    
//    __weak WTVideoPlayerView * weakPlayer  = mplayer_;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        __strong WTVideoPlayerView * player = weakPlayer;
//        
//        if(play)
//        {
//            [self playItemWithCoreEvents:beginSeconds];
//            [self recordPlayItemBegin];
//        }
//        player.alpha = 0;
//        player.hidden = NO;
//        [UIView animateWithDuration:0.35 animations:^{
//            player.alpha= 1;
//        } completion:^(BOOL finished) {
//        }];
//    });
//    //    mplayer_.alpha = 1;
//    //[self hideHUDViewInThread];
//}
//- (void)removePlayerInThread
//{
//    if (![NSThread isMainThread]) {
//        dispatch_async(dispatch_get_main_queue(), ^(void)
//                       {
//                           [self removePlayer];
//                       });
//    }
//    else{
//        [self removePlayer];
//    }
//}
//- (void)removePlayer
//{
//    //    currentPlaySeconds_ = 0;
//    [self recordPlayItemEnd];
//    
//    if(mplayer_){
//        //        [self playerWillEnterForeground];
//        //此处不易中断处理，在Loader代理情况下，如果中断，会导致下载停止,IOS 7以下，不使用Loader
//        if([DeviceConfig IOSVersion]>=7.0)
//        {
//            [mplayer_ pauseWithCache];
//        }
//        [mplayer_ removeFromSuperview];
//        [mplayer_ readyToRelease];
//        currentPlaySeconds_ = 0;
//        PP_RELEASE(mplayer_);
//    }
//    
//}
//
////- (VDCItem *) getVDCItemByRemoveUrl:(MTV*)item path:(NSString *)path audioUrl:(NSString *)audioUrl
////{
////    VDCManager * vdcManager = [VDCManager shareObject];
////
////    VDCItem * remoteItem  = [vdcManager getVDCItemByURL:path checkFiles:NO];
////    if(remoteItem)
////    {
////        remoteItem.MTVID = item.MTVID;
////        if(remoteItem.SampleID !=item.SampleID)
////        {
////            remoteItem.SampleID = item.SampleID;
////            [[VDCManager shareObject] rememberDownloadUrl:remoteItem tempPath:remoteItem.tempFilePath];
////        }
////    }
////    return remoteItem;
////}
////- (VDCItem *) getVDCItemByLocalFile:(MTV*)item path:(NSString *)path audioUrl:(NSString*)audioUrl
////{
////
////    VDCItem * localItem = [[VDCManager shareObject]getVDCItemByURL:[item getDownloadUrlOpeated:netStatus_ userID:userInfo_.UserID] checkFiles:NO];
////    localItem.localFilePath = item.FilePath;
////    localItem.remoteUrl = item.DownloadUrl720;
////    localItem.contentLength = [[VDCManager shareObject]fileSizeForPath:item.FilePath];
////    localItem.downloadBytes = localItem.contentLength;
////
////    localItem.MTVID = item.MTVID;
////    if(localItem.SampleID !=item.SampleID)
////    {
////        localItem.SampleID = item.SampleID;
////        [[VDCManager shareObject] rememberDownloadUrl:localItem tempPath:localItem.tempFilePath];
////    }
////
////    NSLog(@"\n tempFilePath = %@ \n path = %@",localItem.tempFilePath,path);
////    // localFileVDCItem_.tempFilePath = path;
////    [[VDCManager shareObject]buildAudioPath:localItem audioUrlString:audioUrl key:localItem.key];
////    return localItem;
////}
//- (BOOL) playRemoteFile:(MTV *)item path:(NSString *)path audioUrl:(NSString*)audioUrl seconds:(CGFloat)seconds
//{
//    
//    //先停，让它不要再去读缓存了
//    [self removePlayerInThread];
//    
//    [self showPlayerWaitingView];
//    
//    //    localFileVDCItem_  = [self getVDCItemByRemoveUrl:item path:path audioUrl:audioUrl];
//#ifdef USE_CACHEPLAYING
//    VDCManager * vdcManager = [VDCManager shareObject];
//    if([userManager_ enableCachenWhenPlaying])
//    {
//        
//        localFileVDCItem_  = [WTVideoPlayerView getVDCItem:item Sample:nil];
//        
//        if((!localFileVDCItem_ || localFileVDCItem_.contentLength > localFileVDCItem_.downloadBytes)
//           && netStatus_==ReachableViaWWAN
//           )
//        {
//            if([[UserManager sharedUserManager]canShowNotickeFor3G])
//            {
//                //[self hideHUDViewInThread];
//                [self hidePlayerWaitingView];
//                [self showNoticeForWWAN];
//                return NO;
//            }
//        }
//    }
//    else
//    {
//        if(netStatus_==ReachableViaWWAN)
//        {
//            if([[UserManager sharedUserManager]canShowNotickeFor3G])
//            {
//                //[self hideHUDViewInThread];
//                [self hidePlayerWaitingView];
//                [self showNoticeForWWAN];
//                return NO;
//            }
//        }
//    }
//#else
//    if(netStatus_==ReachableViaWWAN)
//    {
//        if([[UserManager sharedUserManager]canShowNotickeFor3G])
//        {
//            //[self hideHUDViewInThread];
//            [self hidePlayerWaitingView];
//            [self showNoticeForWWAN];
//            return NO;
//        }
//    }
//#endif
//    //[self showHUDViewInThread];
//    NSLog(@"playing ready to %@",path);
//    [self showPlayerWaitingView];
//    
//#ifdef USE_CACHEPLAYING
//    if([userManager_ enableCachenWhenPlaying])
//    {
//        
//        __weak MTV * weakMtv = [self getCurrentMTV];
//        __weak NSString * weakPath = path;
//        NSString *title = [NSString stringWithFormat:@"%@  (%@)",item.Title,item.Author];
//        
//        [vdcManager addUrlCache:path audioUrl:nil title:title urlReady:^(VDCItem * vdcItem,NSURL * url)
//         {
//             //如果是多次重复调用，则不处理
//             if(localFileVDCItem_ && [localFileVDCItem_.key isEqualToString:vdcItem.key])
//             {
//                 if(mplayer_ && mplayer_.playing) return;
//                 [NSThread sleepForTimeInterval:0.1];
//                 if(mplayer_ && mplayer_.playing)
//                     return;
//             }
//             
//             [self showButtonsPlaying];
//             
//             localFileVDCItem_ = vdcItem;
//             localFileVDCItem_.MTVID = weakMtv.MTVID;
//             
//             //mediaEditManager_.accompanyDownKey = localFileVDCItem_.key;
//             
//             if(vdcItem.SampleID !=weakMtv.SampleID)
//             {
//                 localFileVDCItem_.SampleID = weakMtv.SampleID;
//                 [[VDCManager shareObject] rememberDownloadUrl:localFileVDCItem_ tempPath:localFileVDCItem_.tempFilePath];
//             }
//             
//             NSLog(@"playing item url begin:%@",[url absoluteString]);
//             dispatch_async(dispatch_get_main_queue(), ^{
//                 
//                 [self updateFilePath:weakMtv filePath:vdcItem.localFilePath];
//                 
//                 NSString * newPath = url.absoluteString;
//                 NSLog(@"**-- Play:%@",newPath?newPath:@"文件可能没有上传，但本地文件又不在了，所以会出现NULL值");
//                 [self playItemChangeWithCoreEvents:newPath orgPath:weakPath mtv:item beginSeconds:seconds];
//                 
//                 if (seconds <0.1 &&(([UserManager sharedUserManager].isFirstEnterMain && weakMtv.MTVID == 0) || weakMtv.UserID == userInfo_.UserID)) {
//                     //[self showTitleInThread:YES];
//                 }
//                 else
//                 {
//                     //titleTimer_ = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideTitleInThread:) userInfo:nil repeats:NO];
//                 }
//                 
//             });
//         } completed:^(VDCItem * vdcItem,BOOL completed,VDCTempFileInfo * tempFile)
//         {
//             // 如果是看他人的视频，下载完成删除临时文件
//             if (item.MTVID != 0 && ![HCFileManager isLocalFile:weakPath])
//             {
//                 if ([[VDCManager shareObject] isItemDownloadCompleted:vdcItem])
//                 {
//                     vdcItem.isDownloading = NO;
//                     [[VDCManager shareObject] removeTemplateFilesByUrl:weakPath];
//                     vdcItem.tempFileList = nil;
//                     vdcItem.SampleID = weakMtv.SampleID;
//                     [[VDCManager shareObject] rememberDownloadUrl:vdcItem tempPath:vdcItem.tempFilePath];
//                 }
//             }
//             [self downloadUserAudio:weakMtv];
//         }];
//    }
//    else
//    {
//        NSLog(@"playing item url begin:%@",path);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self playItemChangeWithCoreEvents:path orgPath:path mtv:item beginSeconds:seconds];
//            
//        });
//    }
//#else
//    NSLog(@"playing item url begin:%@",path);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self playItemChangeWithCoreEvents:path orgPath:path mtv:item beginSeconds:seconds];
//        
//    });
//#endif
//    return YES;
//}
//
//- (void) playLocalFile:(MTV *)item path:(NSString *)path audioUrl:(NSString*)audioUrl seconds:(CGFloat)seconds play:(BOOL)play
//{
//    //    localFileVDCItem_ = [self getVDCItemByLocalFile:item path:path audioUrl:audioUrl];
//    
//#ifdef USE_CACHEPLAYING
//    if([userManager_ enableCachenWhenPlaying])
//    {
//        localFileVDCItem_  = [WTVideoPlayerView getVDCItem:item Sample:nil];
//        
//        mediaEditManager_.accompanyDownKey = localFileVDCItem_.key;
//        
//        NSLog(@"playing ready2 to %@",path);
//        if([NSThread isMainThread])
//        {
//            if(!play)
//                [self playItemChangeWithReady:path orgPath:path mtv:item beginSeconds:seconds play:NO];
//            else
//            {
//                [self playItemChangeWithCoreEvents:path orgPath:path mtv:item beginSeconds:seconds];
//                //看别人的没有标题
//                if (seconds <0.1&&(([UserManager sharedUserManager].isFirstEnterMain && item.MTVID == 0) || item.UserID == userInfo_.UserID) ) {
//                    //[self showTitleInThread:YES];
//                }
//                else
//                {
//                    //titleTimer_ = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideTitleInThread:) userInfo:nil repeats:NO];
//                }
//            }
//        }
//        else
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                if(!play)
//                    [self playItemChangeWithReady:path orgPath:path mtv:item beginSeconds:seconds play:NO];
//                else
//                {
//                    [self playItemChangeWithCoreEvents:path orgPath:path mtv:item beginSeconds:seconds];
//                    
//                    if (seconds <0.1&&(([UserManager sharedUserManager].isFirstEnterMain && item.MTVID == 0) || item.UserID == userInfo_.UserID) ) {
//                        //[self showTitleInThread:YES];
//                    }
//                    else
//                    {
//                        //titleTimer_ = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideTitleInThread:) userInfo:nil repeats:NO];
//                    }
//                }
//            });
//        }
//        if(item.SampleID>0 && item.MTVID ==0)
//        {
//            [self downloadUserAudio:item];
//        }
//    }
//    else
//    {
//        if([NSThread isMainThread])
//        {
//            if(!play)
//            {
//                [self playItemChangeWithReady:path orgPath:path mtv:item beginSeconds:seconds play:NO];
//            }
//            else
//            {
//                [self playItemChangeWithCoreEvents:path orgPath:path mtv:item beginSeconds:seconds];
//            }
//        }
//        else
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                if(!play)
//                {
//                    [self playItemChangeWithReady:path orgPath:path mtv:item beginSeconds:seconds play:NO];
//                }
//                else
//                {
//                    [self playItemChangeWithCoreEvents:path orgPath:path mtv:item beginSeconds:seconds];
//                    
//                }
//            });
//        }
//    }
//#else
//    if([NSThread isMainThread])
//    {
//        if(!play)
//        {
//            [self playItemChangeWithReady:path orgPath:path mtv:item beginSeconds:seconds play:NO];
//        }
//        else
//        {
//            [self playItemChangeWithCoreEvents:path orgPath:path mtv:item beginSeconds:seconds];
//        }
//    }
//    else
//    {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            if(!play)
//            {
//                [self playItemChangeWithReady:path orgPath:path mtv:item beginSeconds:seconds play:NO];
//            }
//            else
//            {
//                [self playItemChangeWithCoreEvents:path orgPath:path mtv:item beginSeconds:seconds];
//                
//            }
//        });
//    }
//#endif
//}
//#pragma mark - player waiting view
//- (void)showPlayerWaitingView
//{
//    if([NSThread isMainThread])
//    {
//        if(!playerWaitingView_)
//        {
//            //            self.activityView_ = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//            //            //        self.activityView_.frame = CGRectMake(0, 0, 50, 50);
//            //            //        self.activityView_.center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
//            //            [self addSubview:self.activityView_];
//            
//            playerWaitingView_ = [[UIImageView alloc]initWithFrame: CGRectMake(0, -489.5/2.0f, 887, 489.5)];
//            playerWaitingView_.image = [UIImage imageNamed:@"playloading.png"];
//            playerWaitingView_.backgroundColor = [UIColor clearColor];
//            playerWaitingView_.hidden = YES;
//            
//            [playContainerView_ addSubview:playerWaitingView_];
//            
//            playerWaitingTimer_ = PP_RETAIN([NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(moveWaitingView:) userInfo:nil repeats:YES]);
//            playerWaitingTimer_.fireDate = [NSDate distantFuture];
//            playerWaitingOffset_ = 0;
//            
//        }
//        if(playerWaitingView_.hidden)
//        {
//            //            self.activityView_.hidden = NO;
//            //            [self.activityView_ startAnimating];
//            playerWaitingView_.hidden = NO;
//            playerWaitingTimer_.fireDate = [NSDate distantPast];
//        }
//        [playContainerView_ bringSubviewToFront:playerWaitingView_];
//        //        [self bringSubviewToFront:self.activityView_];
//        
//    }
//    else
//    {
//        dispatch_async(dispatch_get_main_queue(), ^(void)
//                       {
//                           [self showPlayerWaitingView];
//                       });
//    }
//}
//- (void)hidePlayerWaitingView
//{
//    if([NSThread isMainThread])
//    {
//        if(playerWaitingView_ )
//        {
//            playerWaitingTimer_.fireDate = [NSDate distantFuture];
//            playerWaitingView_.hidden = YES;
//        }
//    }
//    else
//    {
//        dispatch_async(dispatch_get_main_queue(), ^(void)
//                       {
//                           [self hidePlayerWaitingView];
//                       });
//    }
//}
//- (void)moveWaitingView:(NSTimer *)timer
//{
//    dispatch_async(dispatch_get_main_queue(), ^(void)
//                   {
//                       CGRect frame = playerWaitingView_.frame;
//                       frame.origin.x -= 5;
//                       if(frame.origin.x < - 100)
//                       {
//                           frame.origin.x = 0;
//                       }
//                       playerWaitingView_.frame = frame;
//                   });
//}
//#pragma mark - player delegate
//- (void)videoPlayerViewIsReadyToPlayVideo:(WTVideoPlayerView *)videoPlayerView
//{
//    NSLog(@"ready to play...%i",(int)mplayer_.playing);
//    //    [self recordPlayItemBegin];
//    //    [self setDelaySeconds];
//    
//    // 显示歌词
////    if (!mplayer_.lyricView  && [self isFullScreen]) {
////        [mplayer_ showLyric:currentMtv_.Lyric singleLine:YES container:mplayer_];
////    }
//    // 判断要不要显示弹幕
//    if ([self canShowComment] && ([self isMaxWindowPlay] || [self isFullScreen])){
//        if(!mplayer_.commentListView)
//        {
//            [self initCommentView];
//        }
//        [mplayer_ showComments];
//    } else {
//        [mplayer_ hideComments];
//    }
//}
//- (void)videoPlayerViewDidReachEnd:(WTVideoPlayerView *)videoPlayerView
//{
//    //[commentManager_ stopCommentTimer];
//    [mplayer_.commentManager stopCommentTimer];
//    
//    currentPlaySeconds_ = 0;
//    [self pauseItem:nil];
//    
//    [self removePlayerInThread];
//}
//- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView timeDidChange:(CGFloat)cmTime
//{
//    if(cmTime < 0.15)
//        return;
//    
//    [self showProgressSync:cmTime];
//    
//    CGFloat progress = cmTime;
//    currentPlaySeconds_ = progress;
//    
//    if (leaderPlayer_ && needPlayLeader_) {
//        leaderPlayer_.currentTime = progress + DELAYSEC;
//        [leaderPlayer_ play];
//        needPlayLeader_ = NO;
//    }
//    if(lastPlaySecondsForBackInfo_ > currentPlaySeconds_ || lastPlaySecondsForBackInfo_ < currentPlaySeconds_ -1)
//    {
//        [self showPlayBackProgress:currentPlaySeconds_];
//        lastPlaySecondsForBackInfo_ = currentPlaySeconds_;
//    }
//    
//    // 同步comment的时间
//    if([self canShowComment] && mplayer_.commentManager)
//    {
//        //[mplayer_.commentManager commentsShowInThread:progress time:0 animate:YES];
//        
//        [mplayer_.commentManager setCurrentDuranceWhen:progress];
//    }
//}
//- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView didStalled:(AVPlayerItem *)playerItem
//{
//    NSLog(@"playing pause by stalled");
//    //此处不易中断处理，在Loader代理情况下，如果中断，会导致下载停止,IOS 7以下，不使用Loader
//    if([DeviceConfig IOSVersion]<7.0)
//    {
//        [self pauseItem:nil];
//    }
//}
//- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView beginPlay:(AVPlayerItem *)playerItem
//{
//    if(leaderPlayer_ && leaderPlayer_.rate<=0.1)
//    {
//        needPlayLeader_ = YES;
//    }
//}
//- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView didFailedToPlayToEnd:(NSError *)error
//{
//    currentPlaySeconds_ = 0;
//    NSLog(@"playing pause by didFailedToPlayToEnd:%@",[error localizedDescription]);
//#ifdef USE_CACHEPLAYING
//    if([userManager_ enableCachenWhenPlaying])
//    {
//        NSString * url = [[videoPlayerView getCurrentUrl]absoluteString];
//        if(url && [HCFileManager isLocalFile:url])
//        {
//            if(localFileVDCItem_ && [[localFileVDCItem_.localFilePath lastPathComponent]isEqualToString:[url lastPathComponent]])
//            {
//                [[VDCManager shareObject]removeUrlCahche:localFileVDCItem_.remoteUrl];
//                localFileVDCItem_.downloadBytes = 0;
//                [videoPlayerView resetPlayItemKey];
//                [self pauseItem:nil];
//            }
//            else
//            {
//                [self pauseItem:nil];
//            }
//        }
//        else
//        {
//            [self pauseItem:nil];
//        }
//    }
//    else
//    {
//        [self pauseItem:nil];
//    }
//#else
//    [self pauseItem:nil];
//#endif
//}
//- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView pausedByUnexpected:(NSError *)error item:(AVPlayerItem *)playerItem
//{
//    NSLog(@"playing pausedByUnexpected:%@",[error localizedDescription]);
//    pauseUnexpected_ = YES;
//    if(leaderPlayer_)
//    {
//        [leaderPlayer_ pause];
//    }
//    
//}
//- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView autoPlayAfterPause:(NSError *)error item:(AVPlayerItem *)playerItem
//{
//    if(!pauseUnexpected_)
//    {
//        [self pauseItem:nil];
//        NSLog(@"playing auto, no unexpected stop, so pause.");
//    }
//    pauseUnexpected_ = NO;
//}
//- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView didFailWithError:(NSError *)error
//{
//    currentPlaySeconds_ = 0;
//    NSLog(@" playing failed error:%@",[error localizedDescription]);
//#ifdef USE_CACHEPLAYING
//    if([userManager_ enableCachenWhenPlaying])
//    {
//        NSString * url = [[videoPlayerView getCurrentUrl]absoluteString];
//        if([HCFileManager isLocalFile:url])
//        {
//            if(localFileVDCItem_ && [[localFileVDCItem_.localFilePath lastPathComponent]isEqualToString:[url lastPathComponent]])
//            {
//                [[VDCManager shareObject]removeUrlCahche:localFileVDCItem_.remoteUrl];
//                localFileVDCItem_.downloadBytes = 0;
//                [videoPlayerView resetPlayItemKey];
//                [self pauseItem:nil];
//            }
//        }
//    }
//#endif
//}
//- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView didTapped:(AVPlayerItem *)playerItem
//{
//    [self showProgressView:nil];
//}
//#pragma mark - helper
//- (BOOL) canPlay
//{
//    return mplayer_ && [mplayer_ canPlay];
//}
//- (CGFloat) currentPlayerWhen
//{
//    if(currentPlaySeconds_ <=0 && mplayer_ && mplayer_.playing)
//    {
//        currentPlaySeconds_ = CMTimeGetSeconds(mplayer_.durationWhen);
//    }
//    return currentPlaySeconds_;
//}
//- (CGFloat) duration
//{
//    if(mplayer_ && [mplayer_ canPlay])
//        return CMTimeGetSeconds(mplayer_.duration);
//    else
//        return 0;
//}
//// 是否正在播放
//- (BOOL)isPlaying
//{
//    if ((mplayer_ && mplayer_.playing) || isAutoPlaying_) {
//        return YES;
//    } else {
//        return NO;
//    }
//}
////将本地路径记录，用于重唱或编辑
//- (void)updateFilePath:(MTV*)item filePath:(NSString*)filePath
//{
//    dispatch_async([DBHelper_WT getDBQueue], ^{
//        [DBHelper_WT updateFilePath:item filePath:filePath];
//    });
//    [item setFilePathN:filePath];
//}
//- (void)showNoticeForWWANForTag:(int)tagID
//{
//    if ([NSThread isMainThread]) {
//        [self pauseItem:nil];
//        
//        SNAlertView *alert = [[SNAlertView alloc] initWithTitle:@"prompt"
//                                                        message:@"您正在使用手机网络，是否继续加载视频？"
//                                                       delegate:self
//                                              cancelButtonTitle:@"暂停"
//                                              otherButtonTitles:@"继续加载", nil];
//        alert.tag = tagID;
//        [alert show];
//        
//    }
//    else
//    {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self showNoticeForWWANForTag:tagID];
//        });
//    }
//}
//- (void)showNoticeForWWAN
//{
//    [self showNoticeForWWANForTag:3001];
//}
//- (void)hideNoticeForWWAN
//{
//    if ([NSThread isMainThread]) {
//        
//    }
//    else
//    {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self hideNoticeForWWAN];
//        });
//    }
//}
//#pragma mark - record events
//- (void)recordPlayItemBegin
//{
//    //将上次没有搞完的记录一下
//    if(record_ && record_.MTVID >0)
//    {
//        [self recordPlayItemEnd];
//    }
//    PP_RELEASE(record_);
//    if(![self getCurrentMTV]) return;
//    
//    record_ = [[PlayRecord alloc]init];
//    record_.UserID = [[UserManager sharedUserManager]userID];
//    record_.MTVID = [self getCurrentMTV].MTVID;
//    record_.PlayTime = [CommonUtil stringFromDate:[NSDate date]];
//    if(mplayer_)
//    {
//        record_.BeginDurance = CMTimeGetSeconds(mplayer_.durationWhen);
//    }
//    record_.IsFullScreen = YES;
//    record_.IsSynced = NO;
//}
//- (void)recordPlayItemEnd
//{
//    if(record_ && (record_.MTVID !=0 || record_.SampleID!=0))
//    {
//        if(mplayer_)
//        {
//            record_.EndDurance = CMTimeGetSeconds(mplayer_.durationWhen);
//        }
////        CMD_TrackOpeate * cmd = (CMD_TrackOpeate *)[[CMDS_WT sharedCMDS_WT]createCMDOP:@"TrackOpeate"];
////        cmd.Item = record_;
////        [cmd sendCMD];
//    }
//    PP_RELEASE(record_);
//}
//
//#pragma mark - playback
////设置锁屏状态，显示的歌曲信息
//- (void)setPlayBackInfo
//{
//    //    NSLog(@"----- set playback info.....");
//    [self setPlayBackInfoA:0];
//}
//
//- (void)setPlayBackInfoA:(int)count
//{
//    NSLog(@"SetPlayBackInfoA: %d category:%@",count,[AVAudioSession sharedInstance].category);
//    
//    //    if ([[AudioCenter shareAudioCenter] didAudioControllerStoped]) {
//    if(![[AVAudioSession sharedInstance].category isEqualToString:AVAudioSessionCategoryPlayback]
//       && !![[AVAudioSession sharedInstance].category isEqualToString:AVAudioSessionCategoryPlayAndRecord])
//    {
//        NSError *error = nil;
//        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
//        if (error) {
//            NSLog(@"Audio Session Set Category Error %@",error);
//        }
//        [[AVAudioSession sharedInstance] setActive:YES error:&error];
//        if (error) {
//            NSLog(@"Audio Session Set Active Error %@",error);
//        }
//        else
//        {
//            NSLog(@"SetPlayBackInfo Yes");
//        }
//    }
//    
//    [self setMPNowPlayingInfo];
//    
//}
//
//- (void)setMPNowPlayingInfo
//{
//    if (NSClassFromString(@"MPNowPlayingInfoCenter"))
//    {
//        canShowPlaybackInfo_ = YES;
//        MTV * item = [self getCurrentMTV];
//        if(!item) return;
//        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//        
//        //歌曲名称
//        if(!item.Title) item.Title = @"";
//        [dict setObject:item.Title forKey:MPMediaItemPropertyTitle];
//        
//        //演唱者
//        if(!item.Author) item.Author = @"麦爸用户";
//        [dict setObject:item.Author forKey:MPMediaItemPropertyArtist];
//        
//        //专辑名
//        if(!item.Tag) item.Tag = @"";
//        [dict setObject:item.Tag forKey:MPMediaItemPropertyAlbumTitle];
//        
//        //专辑缩略图
//        UIImage * image = [self getCoverImage];
//        if(!image) image = [UIImage imageNamed:@"mtvcover_icon.png"];
//        
//        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:image];
//        [dict setObject:artwork forKey:MPMediaItemPropertyArtwork];
//        
//        //音乐剩余时长
//        CGFloat duration = item.Durance;
//        if(mplayer_ && [mplayer_ canPlay])
//            duration = CMTimeGetSeconds(mplayer_.duration);
//        [dict setObject:[NSNumber numberWithDouble:duration] forKey:MPMediaItemPropertyPlaybackDuration];
//        
//        //音乐当前播放时间 在计时器中修改
//        [dict setObject:[NSNumber numberWithDouble:currentPlaySeconds_>=0?currentPlaySeconds_:0.0] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
//        
//        if(mplayer_ && mplayer_.playing)
//        {
//            [dict setObject:[NSNumber numberWithDouble:1] forKey:MPNowPlayingInfoPropertyPlaybackRate];
//        }
//        else
//        {
//            [dict setObject:[NSNumber numberWithDouble:0] forKey:MPNowPlayingInfoPropertyPlaybackRate];
//        }
//        NSLog(@"set playbackInfo:%@",dict);
//        //设置锁屏状态下屏幕显示播放音乐信息
//        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
//        //        [MPRemoteCommandCenter sharedCommandCenter]set
//    }
//}
//- (void)showPlayBackProgress:(CGFloat)seconds
//{
//    if(canShowPlaybackInfo_)
//    {
//        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo]];
//        [dict setObject:[NSNumber numberWithDouble:seconds] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime]; //音乐当前已经过时间
//        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
//        //        NSLog(@"set playbackInfo:%@",dict);
//    }
//}
//- (void)showPlayBackPause
//{
//    if(canShowPlaybackInfo_)
//    {
//        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo]];
//        [dict setObject:[NSNumber numberWithDouble:0] forKey:MPNowPlayingInfoPropertyPlaybackRate];
//        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
//    }
//}
//- (void)showPlayBackPlay
//{
//    if(canShowPlaybackInfo_)
//    {
//        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo]];
//        [dict setObject:[NSNumber numberWithDouble:1] forKey:MPNowPlayingInfoPropertyPlaybackRate];
//        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
//    }
//}
//- (void)clearPlayBackinfo
//{
//    NSLog(@"----- clear playback info.....");
//    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
//    canShowPlaybackInfo_ = NO;
//}
//
//- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
//    if (receivedEvent.type == UIEventTypeRemoteControl) {
//        NSLog(@"remote control.222..");
//        MusicDetailViewController * detailVC = [MusicDetailViewController shareObject];
//        if(!detailVC) return;
//        switch (receivedEvent.subtype) {
//            case UIEventSubtypeRemoteControlPlay:
//            {
//                NSLog(@"UIEventSubtypeRemoteControlPlay");
//                if(mplayer_ && mplayer_.playing)
//                {
//                    [detailVC pauseItem:nil];
//                    [self showPlayBackPause];
//                }
//                else
//                {
//                    [detailVC playItem:nil seconds:-1];
//                    [self showPlayBackPlay];
//                }
//            }
//                break;
//            case UIEventSubtypeRemoteControlPause:
//            {
//                NSLog(@"UIEventSubtypeRemoteControlPause");
//                if(mplayer_ && mplayer_.playing)
//                {
//                    [detailVC pauseItem:nil];
//                    [self showPlayBackPause];
//                }
//                else
//                {
//                    [detailVC playItem:nil seconds:-1];
//                    [self showPlayBackPlay];
//                }
//                
//            }
//                break;
//            case UIEventSubtypeRemoteControlTogglePlayPause:
//            {
//                NSLog(@"UIEventSubtypeRemoteControlTogglePlayPause");
//                if(mplayer_ && mplayer_.playing)
//                {
//                    [detailVC pauseItem:nil];
//                    [self showPlayBackPause];
//                }
//                else
//                {
//                    [detailVC playItem:nil seconds:-1];
//                    [self showPlayBackPlay];
//                }
//            }
//                break;
//                
//            case UIEventSubtypeRemoteControlPreviousTrack:
//            {
//                NSLog(@"UIEventSubtypeRemoteControlPreviousTrack");
//                if([detailVC canPlay])
//                {
//                    CGFloat seconds = [detailVC currentPlayerWhen];
//                    seconds -= 10;
//                    if(seconds<0) seconds = 0;
//                    [detailVC playItem:nil seconds:seconds];
//                }
//            }
//                break;
//                
//            case UIEventSubtypeRemoteControlNextTrack:
//            {
//                NSLog(@"UIEventSubtypeRemoteControlNextTrack");
//                if([detailVC canPlay])
//                {
//                    CGFloat seconds = [detailVC currentPlayerWhen];
//                    seconds += 10;
//                    if(seconds>= [detailVC duration]) seconds = 0;
//                    [detailVC playItem:nil seconds:seconds];
//                }
//            }
//                break;
//            default:
//                break;
//        }
//    }
//}
//
//- (void)playerWillEnterBackground
//{
//    NSLog(@"player will enter background.");
//    UIApplication*app = [UIApplication sharedApplication];
//    
//    NSLog(@"is first response:%d",[self isFirstResponder]);
//    
//    if(bgTask_!=UIBackgroundTaskInvalid)
//    {
//        [app endBackgroundTask:bgTask_];
//        bgTask_ = UIBackgroundTaskInvalid;
//    }
//    
//    bgTask_ = [app beginBackgroundTaskWithExpirationHandler:nil];
//    
//    //    if(![self isFirstResponder])
//    //    {
//    [app beginReceivingRemoteControlEvents];
//    [self becomeFirstResponder];
//    //    if (![app becomeFirstResponder]) {
//    //        NSLog(@"Become First Responder Faild 2222");
//    //        [self becomeFirstResponder];
//    //    }
//    //    else
//    //    {
//    //
//    //    }
//    //    }
//    
//    if (mplayer_ && mplayer_.playing) {
//        isAutoPlaying_ = YES;
//        //        [self pauseItemWithCoreEvents];
//        [self setPlayBackInfo];
//        //        [self playItemWithCoreEvents:-1];
//    }
//    else
//    {
//        [self setPlayBackInfo];
//        isAutoPlaying_ = NO;
//    }
//    //避免错误显示按钮，必须判断播放器状态
//    
//}
//- (void)endBackgroundTask
//{
//    UIApplication*app = [UIApplication sharedApplication];
//    if(bgTask_!=UIBackgroundTaskInvalid)
//    {
//        [app endBackgroundTask:bgTask_];
//        bgTask_ = UIBackgroundTaskInvalid;
//    }
//}
//- (void)playerWillEnterForeground
//{
//    NSLog(@"player will enter foreground");
//    UIApplication*app = [UIApplication sharedApplication];
//    
//    [app endReceivingRemoteControlEvents];
//    [self resignFirstResponder];
//    
//    if(bgTask_!=UIBackgroundTaskInvalid)
//    {
//        [app endBackgroundTask:bgTask_];
//        bgTask_ = UIBackgroundTaskInvalid;
//    }
//    
//    if(isAutoPlaying_)
//    {
//        if(mplayer_ && mplayer_.playing)
//        {
//            [self pauseItemWithCoreEvents];
//            [self playItemWithCoreEvents:-1];
//        }
//        else
//        {
//            [self playItem:nil seconds:-1];
//        }
//    }
//    else
//    {
//        [self pauseItem:nil];
//    }
//    [self clearPlayBackinfo];
//    [self becomeFirstResponder];
//}
@end
