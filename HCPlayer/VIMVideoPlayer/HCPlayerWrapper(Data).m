//
//  HCPlayerWrapper(Data).m
//  HCPlayerTest
//
//  Created by HUANGXUTAO on 16/5/5.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import "HCPlayerWrapper(Data).h"
#import <hccoren/base.h>
#import <HCBaseSystem/database_wt.h>
#import <HCMVManager/MTV.h>
#import <HCMVManager/Samples.h>
#import <HCMVManager/HCDBHelper(MTV).h>
//#import <HCBaseSystem/CMD_TrackOpeate.h>

@implementation HCPlayerWrapper(Data)

#pragma mark - helper
- (BOOL) canPlay
{
    return mplayer_ && [mplayer_ canPlay];
}
- (CGFloat) currentPlayerWhen
{
    if(currentPlaySeconds_ <=0 && mplayer_ && mplayer_.playing)
    {
        currentPlaySeconds_ = CMTimeGetSeconds(mplayer_.durationWhen);
    }
    return currentPlaySeconds_;
}
- (CGFloat) duration
{
    if(mplayer_ && [mplayer_ canPlay])
        return CMTimeGetSeconds(mplayer_.duration);
    else
        return 0;
}
// 是否正在播放
- (BOOL)isPlaying
{
    if ((mplayer_ && mplayer_.playing) || isPlayingWhenEnterBackground_) {
        return YES;
    } else {
        return NO;
    }
}
//将本地路径记录，用于重唱或编辑
- (void)updateFilePath:(MTV*)item filePath:(NSString*)filePath
{
    dispatch_async([DBHelper_WT getDBQueue], ^{
        [DBHelper_WT updateFilePath:item filePath:filePath];
    });
    [item setFilePathN:filePath];
}
- (void)setTotalSeconds:(CGFloat)seconds
{
    if(isnan(seconds))
        seconds = 60;
    [progressView_ setTotalSeconds:seconds];
    //    progressView_.totalSeconds = seconds;
}
- (BOOL)isFullScreen
{
    return progressView_.isFullScreen;
    //    return playContainerView_.frame.size.height >= _ScreenHeight;
}
- (BOOL)canShowRecordBtn
{
    
    if(currentSample_ && [currentSample_ hasVideo])
        //       && currentMtv_.UserID !=userManager_.userID)
    {
        return YES;
    }
    return NO;
}
- (BOOL)currentItemIsSample
{
    return currentMTV_.MTVID == 0;
}
- (BOOL)isMVLandscape
{
    if(currentMTV_)
        return currentMTV_.IsLandscape;
    else
        return NO;
}
- (BOOL)hasGuideAudio
{
    return currentMTV_.MTVID==0 && currentMTV_.AudioRemoteUrl && currentMTV_.AudioRemoteUrl.length>2;
}
//- (BOOL)isMaxWindowPlay
//{
//    return (currentPlayerHeight_ >= playerHeightMax_);
//}
//- (BOOL)canShowComment
//{
//    canShowComments_ = maxPannel_.isCommentsShow || commentSwitch_.isOn;
//    return canShowComments_;
//}
#pragma mark - record events
- (void)recordPlayItemBegin
{
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
}
- (void)recordPlayItemEnd
{
    //    if(record_ && (record_.MTVID !=0 || record_.SampleID!=0))
    //    {
    //        if(mplayer_)
    //        {
    //            record_.EndDurance = CMTimeGetSeconds(mplayer_.durationWhen);
    //        }
    //        //        CMD_TrackOpeate * cmd = (CMD_TrackOpeate *)[[CMDS_WT sharedCMDS_WT]createCMDOP:@"TrackOpeate"];
    //        //        cmd.Item = record_;
    //        //        [cmd sendCMD];
    //    }
    //    PP_RELEASE(record_);
}

#pragma mark - show hide waiting
#pragma mark - player waiting view
- (void)showPlayerWaitingView
{
    if([NSThread isMainThread])
    {
        if(!playerWaitingView_)
        {
            //            self.activityView_ = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            //            //        self.activityView_.frame = CGRectMake(0, 0, 50, 50);
            //            //        self.activityView_.center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
            //            [self addSubview:self.activityView_];
            
            playerWaitingView_ = [[UIImageView alloc]initWithFrame: CGRectMake(0, -489.5/2.0f, 887, 489.5)];
            playerWaitingView_.image = [UIImage imageNamed:@"HCPlayer.bundle/playloading.png"];
            playerWaitingView_.backgroundColor = [UIColor clearColor];
            playerWaitingView_.hidden = YES;
            
            [self addSubview:playerWaitingView_];
            
            playerWaitingTimer_ = PP_RETAIN([NSTimer scheduledTimerWithTimeInterval:0.1
                                                                             target:self
                                                                           selector:@selector(moveWaitingView:)
                                                                           userInfo:nil
                                                                            repeats:YES]);
            playerWaitingTimer_.fireDate = [NSDate distantFuture];
            playerWaitingOffset_ = 0;
            
        }
        if(playerWaitingView_.hidden)
        {
            //            self.activityView_.hidden = NO;
            //            [self.activityView_ startAnimating];
            playerWaitingView_.hidden = NO;
            playerWaitingTimer_.fireDate = [NSDate distantPast];
        }
        [self bringSubviewToFront:playerWaitingView_];
        //        [self bringSubviewToFront:self.activityView_];
        
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self showPlayerWaitingView];
                       });
    }
}
- (void)hidePlayerWaitingView
{
    if([NSThread isMainThread])
    {
        if(playerWaitingView_ )
        {
            playerWaitingTimer_.fireDate = [NSDate distantFuture];
            playerWaitingView_.hidden = YES;
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self hidePlayerWaitingView];
                       });
    }
}
- (void)moveWaitingView:(NSTimer *)timer
{
    
    if([NSThread isMainThread])
    {
        NSLog(@"move waiting....");
        CGRect frame = playerWaitingView_.frame;
        frame.origin.x -= 5;
        if(frame.origin.x < - 100)
        {
            frame.origin.x = 0;
        }
        playerWaitingView_.frame = frame;
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self moveWaitingView:nil];
                       });
    }
    
}


@end
