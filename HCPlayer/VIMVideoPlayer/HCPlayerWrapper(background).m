//
//  HCPlayerWrapper(background).m
//  HCPlayerTest
//
//  Created by HUANGXUTAO on 16/5/5.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <hccoren/base.h>
#import <HCBaseSystem/user_wt.h>
#import "MediaPlayer/MPMediaItem.h"
#import "MediaPlayer/MPNowPlayingInfoCenter.h"
#import "HCPlayerWrapper(background).h"
#import "HCPlayerWrapper(Data).h"
@implementation HCPlayerWrapper(background)

#pragma mark - playback
//设置锁屏状态，显示的歌曲信息
- (void)setPlayBackInfo
{
    //    NSLog(@"----- set playback info.....");
    [self setPlayBackInfoA:0];
}

- (void)setPlayBackInfoA:(int)count
{
    NSLog(@"SetPlayBackInfoA: %d category:%@",count,[AVAudioSession sharedInstance].category);
    
    //    if ([[AudioCenter shareAudioCenter] didAudioControllerStoped]) {
    if(![[AVAudioSession sharedInstance].category isEqualToString:AVAudioSessionCategoryPlayback]
       && !![[AVAudioSession sharedInstance].category isEqualToString:AVAudioSessionCategoryPlayAndRecord])
    {
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        if (error) {
            NSLog(@"Audio Session Set Category Error %@",error);
        }
        [[AVAudioSession sharedInstance] setActive:YES error:&error];
        if (error) {
            NSLog(@"Audio Session Set Active Error %@",error);
        }
        else
        {
            NSLog(@"SetPlayBackInfo Yes");
        }
    }
    
    [self setMPNowPlayingInfo];
    
}

- (void)setMPNowPlayingInfo
{
    if (NSClassFromString(@"MPNowPlayingInfoCenter"))
    {
        canShowPlaybackInfo_ = YES;
        MTV * item = [self getCurrentMTV];
        if(!item) return;
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        //歌曲名称
        if(!item.Title) item.Title = @"";
        [dict setObject:item.Title forKey:MPMediaItemPropertyTitle];
        
        //演唱者
        if(!item.Author) item.Author = @"麦爸用户";
        [dict setObject:item.Author forKey:MPMediaItemPropertyArtist];
        
        //专辑名
        if(!item.Tag) item.Tag = @"";
        [dict setObject:item.Tag forKey:MPMediaItemPropertyAlbumTitle];
        
        //专辑缩略图
        UIImage * image =  [self getCoverImage];
        if(!image) image = [UIImage imageNamed:@"HCPlayer.bundle/mtvcover_icon.png"];
        
        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:image];
        [dict setObject:artwork forKey:MPMediaItemPropertyArtwork];
        
        //音乐剩余时长
        CGFloat duration = item.Durance;
        if(mplayer_ && [mplayer_ canPlay])
        duration = CMTimeGetSeconds(mplayer_.duration);
        [dict setObject:[NSNumber numberWithDouble:duration] forKey:MPMediaItemPropertyPlaybackDuration];
        
        //音乐当前播放时间 在计时器中修改
        [dict setObject:[NSNumber numberWithDouble:currentPlaySeconds_>=0?currentPlaySeconds_:0.0] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        
        if(mplayer_ && mplayer_.playing)
        {
            [dict setObject:[NSNumber numberWithDouble:1] forKey:MPNowPlayingInfoPropertyPlaybackRate];
        }
        else
        {
            [dict setObject:[NSNumber numberWithDouble:0] forKey:MPNowPlayingInfoPropertyPlaybackRate];
        }
        NSLog(@"set playbackInfo:%@",dict);
        //设置锁屏状态下屏幕显示播放音乐信息
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
        //        [MPRemoteCommandCenter sharedCommandCenter]set
    }
}
- (void)showPlayBackProgress:(CGFloat)seconds
{
    if(canShowPlaybackInfo_)
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo]];
        [dict setObject:[NSNumber numberWithDouble:seconds] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime]; //音乐当前已经过时间
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
        //        NSLog(@"set playbackInfo:%@",dict);
    }
}
- (void)showPlayBackPause
{
    if(canShowPlaybackInfo_)
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo]];
        [dict setObject:[NSNumber numberWithDouble:0] forKey:MPNowPlayingInfoPropertyPlaybackRate];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
    }
}
- (void)showPlayBackPlay
{
    if(canShowPlaybackInfo_)
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo]];
        [dict setObject:[NSNumber numberWithDouble:1] forKey:MPNowPlayingInfoPropertyPlaybackRate];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
    }
}
- (void)clearPlayBackinfo
{
    NSLog(@"----- clear playback info.....");
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
    canShowPlaybackInfo_ = NO;
}

- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        NSLog(@"remote control.222..");
        HCPlayerWrapper * detailVC = [HCPlayerWrapper shareObject];
        if(!detailVC) return;
        switch (receivedEvent.subtype) {
                case UIEventSubtypeRemoteControlPlay:
            {
                NSLog(@"UIEventSubtypeRemoteControlPlay");
                if(mplayer_ && mplayer_.playing)
                {
                    [detailVC pause];
                    [self showPlayBackPause];
                }
                else
                {
                    [detailVC play];
                    [self showPlayBackPlay];
                }
            }
                break;
                case UIEventSubtypeRemoteControlPause:
            {
                NSLog(@"UIEventSubtypeRemoteControlPause");
                if(mplayer_ && mplayer_.playing)
                {
                    [detailVC pause];
                    [self showPlayBackPause];
                }
                else
                {
                    [detailVC play];
                    [self showPlayBackPlay];
                }
                
            }
                break;
                case UIEventSubtypeRemoteControlTogglePlayPause:
            {
                NSLog(@"UIEventSubtypeRemoteControlTogglePlayPause");
                if(mplayer_ && mplayer_.playing)
                {
                    [detailVC pause];
                    [self showPlayBackPause];
                }
                else
                {
                    [detailVC play];
                    [self showPlayBackPlay];
                }
            }
                break;
                
                case UIEventSubtypeRemoteControlPreviousTrack:
            {
                NSLog(@"UIEventSubtypeRemoteControlPreviousTrack");
                if([detailVC canPlay])
                {
                    CGFloat seconds = [detailVC currentPlayerWhen];
                    seconds -= 10;
                    if(seconds<0) seconds = 0;
                    [detailVC setPlayRange:seconds end:-1];
                    [detailVC play];
                }
            }
                break;
                
                case UIEventSubtypeRemoteControlNextTrack:
            {
                NSLog(@"UIEventSubtypeRemoteControlNextTrack");
                if([detailVC canPlay])
                {
                    CGFloat seconds = [detailVC currentPlayerWhen];
                    seconds += 10;
                    if(seconds>= [detailVC duration]) seconds = 0;
                    [detailVC setPlayRange:seconds end:-1];
                    [detailVC play];
                }
            }
                break;
            default:
                break;
        }
    }
}

- (void)playerWillEnterBackground
{
    NSLog(@"player will enter background.");
    UIApplication*app = [UIApplication sharedApplication];
    
    NSLog(@"is first response:%d",[self isFirstResponder]);
    
    if(bgTask_!=UIBackgroundTaskInvalid)
    {
        [app endBackgroundTask:bgTask_];
        bgTask_ = UIBackgroundTaskInvalid;
    }
    
    bgTask_ = [app beginBackgroundTaskWithExpirationHandler:nil];
    
    //    if(![self isFirstResponder])
    //    {
    [app beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    //    if (![app becomeFirstResponder]) {
    //        NSLog(@"Become First Responder Faild 2222");
    //        [self becomeFirstResponder];
    //    }
    //    else
    //    {
    //
    //    }
    //    }
    
    if (mplayer_ && mplayer_.playing) {
        isPlayingWhenEnterBackground_ = YES;
        //        [self pauseItemWithCoreEvents];
        [self setPlayBackInfo];
        //        [self playItemWithCoreEvents:-1];
    }
    else
    {
        [self setPlayBackInfo];
        isPlayingWhenEnterBackground_ = NO;
    }
    //避免错误显示按钮，必须判断播放器状态
    
}
- (void)endBackgroundTask
{
    UIApplication*app = [UIApplication sharedApplication];
    if(bgTask_!=UIBackgroundTaskInvalid)
    {
        [app endBackgroundTask:bgTask_];
        bgTask_ = UIBackgroundTaskInvalid;
    }
}
- (void)playerWillEnterForeground
{
    NSLog(@"player will enter foreground");
    UIApplication*app = [UIApplication sharedApplication];
    
    [app endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    
    if(bgTask_!=UIBackgroundTaskInvalid)
    {
        [app endBackgroundTask:bgTask_];
        bgTask_ = UIBackgroundTaskInvalid;
    }
    
    if(isPlayingWhenEnterBackground_)
    {
        if(mplayer_ && mplayer_.playing)
        {
            [self pause];
            [self play];
//            [self pauseItemWithCoreEvents];
//            [self playItemWithCoreEvents:-1];
        }
        else
        {
            [self play];
//            [self playItem:nil seconds:-1];
        }
    }
    else
    {
        [self pause];
//        [self pauseItem:nil];
    }
    [self clearPlayBackinfo];
    [self becomeFirstResponder];
}
#pragma mark - background??

- (NSMutableDictionary *)getParameters
{
    NSMutableDictionary * dic = [NSMutableDictionary new];
    if(mplayer_ && mplayer_.playing)
    {
        [dic setObject:@(1) forKey:@"isplaying"];
    }
    else
    {
        [dic setObject:@(0) forKey:@"isplaying"];
    }
    return dic;
}
- (void)setParameters:(NSDictionary *)para
{
    BOOL isplaying = NO;
    if(para && [para objectForKey:@"isplaying"])
    {
        isplaying = [[para objectForKey:@"isplaying"]intValue]>0;
    }
}

#pragma mark - network check
- (void)showNoticeForWWANForTag:(int)tagID
{
    if ([NSThread isMainThread]) {
        [self pause];
//        [self pauseItem:nil];
        
        SNAlertView *alert = [[SNAlertView alloc] initWithTitle:@"prompt"
                                                        message:@"您正在使用手机网络，是否继续加载视频？"
                                                       delegate:self
                                              cancelButtonTitle:@"暂停"
                                              otherButtonTitles:@"继续加载", nil];
        alert.tag = tagID;
        [alert show];
        
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showNoticeForWWANForTag:tagID];
        });
    }
}
- (void)showNoticeForWWAN
{
    [self showNoticeForWWANForTag:3001];
}
- (void)hideNoticeForWWAN
{
    if ([NSThread isMainThread]) {
        
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideNoticeForWWAN];
        });
    }
}

- (void)snAlertView:(SNAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==3001)
    {
        if(buttonIndex ==alertView.cancelButtonIndex){
            //下次再出现，还需要提醒
            [[UserManager sharedUserManager] enableNotickeFor3G];
            [UserManager sharedUserManager].currentSettings.DownloadVia3G = NO;
            [self pauseWithCache];
//            [self stopCacheMTV:nil];
//            [self pauseItem:nil];
            [self hidePlayerWaitingView];
        }else{
            
            //30分钟内不再提示
            [UserManager sharedUserManager].currentSettings.DownloadVia3G = YES;
            [[UserManager sharedUserManager] disableNotickeFor3G];
            playItemChanged_ = YES;
            [self play];
//            [self playItem:nil seconds:-1];
        }
    }
}
@end
