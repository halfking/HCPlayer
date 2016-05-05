//
//  HCPlayerWrapper.h
//  HCPlayerTest
//
//  Created by HUANGXUTAO on 16/5/5.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//
// 完整封装的Player
#import <UIKit/UIKit.h>
#import <hccoren/base.h>
#import <HCBaseSystem/user_wt.h>
#import <HCMVManager/MTV.h>
#import "lyricView.h"
#import "UICommentsView.h"
#import "CommentViewManager.h"
#import "WTVideoPlayerProgressView.h"
#import "WTVideoPlayerView.h"
#import "WTPlayerControlPannel.h"
#import "WTPlayerTopPannel.h"
#import <HCBaseSystem/VDCItem.h>

static UIBackgroundTaskIdentifier bgTask_ =  0;//UIBackgroundTaskInvalid;

@interface HCPlayerWrapper : UIView<WTVideoPlayerViewDelegate>
{
    LyricView * lyricView_;
    UICommentsView * commentListView_;
    CommentViewManager * commentManager_;
    UITextField * commentTextInput_;
    
    WTVideoPlayerProgressView * progressView_;
    WTPlayerControlPannel * playPannel_;
    WTPlayerTopPannel * maxPannel_;
    WTVideoPlayerView *mplayer_;
    
    AVAudioPlayer *leaderPlayer_;
    AVAudioPlayer *audioPlayer_;
    
    VDCItem *localFileVDCItem_;
    
    UserManager * userManager_;

    
    //播放的数据
    MTV * currentMTV_;
    AVPlayerItem * currentPlayerItem_;
    NSURL * currentUrl_;
    
    BOOL needPlayLeader_; //是否叠加音频，如导唱之类的
    CGFloat currentPlaySeconds_; //当前播放时间，当切源时，可以继续
    CGFloat lastPlaySecondsForBackInfo_;//??
    
    BOOL canShowPlaybackInfo_;  //后台播放显示相关的信息？
    
}
@property (nonatomic,PP_WEAK) id<WTVideoPlayerViewDelegate> delegate;

- (BOOL) setPlayerData:(MTV *)item;
- (BOOL) setPlayerItem:(AVPlayerItem *)playerItem;
- (BOOL) setPlayerUrl:(NSURL *)url;

- (BOOL) setPlayRange:(CGFloat)beginSeconds end:(CGFloat)endSeconds;
- (void) showComments;
- (void) hideComments;
- (void) showLyric;
- (void) hideLyric;

- (BOOL) play;
- (BOOL) pause;
- (void) readyToRelease;

- (void) fullScreen;
- (void) normalScrenn:(CGRect)frame;


- (void) bringToolBar2Front;
- (CGRect) getPlayerFrame;
- (MTV*) getCurrentMTV;
- (UIImage *) getCoverImage;
@end
