//
//  MusicDetailViewController.h
//  maiba
//
//  Created by seentech_5 on 15/12/10.
//  Copyright © 2015年 seenvoice.com. All rights reserved.
//

//#import <MediaPlayer/MediaPlayer.h>
#import "WTVideoPlayerView.h"
//#import "WTVideoPlayerView(Lyric).h"
//#import "WTVideoPlayerView(Cache).h"
#import "WTVideoPlayerProgressView.h"
#import <HCBaseSystem/cmds_wt.h>
#import <HCMVManager/mtv.h>
#import <HCMVManager/vdcmanager_full.h>
#import <HCbaseSystem/vdc_f.h>
#import <HCBaseSystem/user_wt.h>
#import <HCMVManager/hcmvmanager.h>
//#import "MediaEditManager.h"
//#import "MTVUploader.h"
//#import "WTVideoPlayerProgressView.h"
//#import "CommentViewManager.h"
//#import "WTPlayerTopPannel.h"
//#import "WTPlayerControlPannel.h"
//
//#import "LyricView.h"
//#import "SNAlterView.h"
#import "HCPlayerWrapper.h"
#import "HCPlayerWrapper(background).h"
#import "HCPlayerWrapper(lyric).h"
#import "HCPlayerWrapper(Data).h"
#import "HCPlayerWrapper(Play).h"

#define DELAYSEC 0.1

#define USE_CACHEPLAYING  //播放时是否使用缓存

//static UIBackgroundTaskIdentifier bgTask_ =  0;//UIBackgroundTaskInvalid;

@interface MusicDetailViewController :UIViewController
{
    // 播放区
    HCPlayerWrapper * playContainerView_;
//    UIView *playContainerView_;
//    UIButton *playOrPause_;
    
//    WTVideoPlayerView *mplayer_;
//    AVAudioPlayer *leaderPlayer_;
//    AVAudioPlayer *audioPlayer_;
//    CGFloat currentPlaySeconds_;
    BOOL pauseUnexpected_; // 未知原因中断
//    PlayRecord *record_;
    MTV *currentMtv_;
    MTV * currentSample_;
    
//#ifdef USE_CACHEPLAYING
//    VDCItem *localFileVDCItem_;
//#endif
    
//    NetworkStatus netStatus_;
//    UserInformation *userInfo_;
//    MediaEditManager *mediaEditManager_;
    BOOL needPlayLeader_;
    
//    UserManager * userManager_;
//    CommentViewManager * commentManager_;
    
//    LyricView *lyricView_;
//    WTVideoPlayerProgressView * progressView_;
//    WTPlayerControlPannel * playPannel_;
//    WTPlayerTopPannel * maxPannel_;
    
//    UIImageView * playerWaitingView_;
//    NSTimer * playerWaitingTimer_;
//    CGFloat playerWaitingOffset_;
    
//    BOOL canShowPlaybackInfo_;
//    BOOL needPlaying_;
    
    UIDeviceOrientation lastOrientation_;
    UIDeviceOrientation lastOrientationDone_;
    //    NSDate * lastOrientationChangeTime_;
//    CGFloat lastPlaySecondsForBackInfo_;
//    BOOL isAutoPlaying_;
}
@property (nonatomic,PP_STRONG) NSString * shareTitle;
+ (instancetype)shareObject;
- (void)setupWithMtvID:(int)mtvID;
//- (instancetype)initWithDictionary:(NSDictionary *)dic isSample:(BOOL)isSample;
- (void) showMessage:(NSString *)msgTitle msg:(NSString *)msg;
- (void) bringToolBar2Front;
- (void) setCurrentMTV:(MTV *)mtv;
- (MTV*) getCurrentMTV;
- (BOOL) currentItemIsSample;
- (BOOL) downloadUserAudio:(MTV *)mtv;
- (void) playMTVItemWithMTVID:(long)MTVID;

//- (void) showProgressView:(id)sender;
//- (void) showProgressSync:(CGFloat)seconds;
- (void) showButtonsPause;
- (void) showButtonsPlaying;
- (CGRect) getPlayerFrame;
//- (void) setTotalSeconds:(CGFloat)seconds;

//- (BOOL)isFullScreen;
//- (BOOL)checkLoginStatus;

//- (void)initCommentView;
//- (BOOL)canShowComment;
//- (BOOL)isMaxWindowPlay;

//- (UIImage *)getCoverImage;
//- (void)loadTestData;
@end
