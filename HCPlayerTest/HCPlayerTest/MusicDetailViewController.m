//
//  MusicDetailViewController.m
//  maiba
//
//  Created by seentech_5 on 15/12/10.
//  Copyright © 2015年 seenvoice.com. All rights reserved.
//

#import "MusicDetailViewController.h"
#import "MusicDetailViewController(Play).h"
#import <hccoren/base.h>
#import <hccoren/windowitem.h>
#import <hcbasesystem/UIWebImageViewN.h>
#import <HCBaseSystem/SNAlertView.h>
#import "player_config.h"
#import "AppDelegate.h"

#import "WTPlayerControlPannel.h"
#import "WTVideoPlayerProgressView.h"
#import "WTPlayerTopPannel.h"

#import "CMD_GetMtvInfo.h"
#import "CMD_GetSampleInfo.h"
#import <HCBaseSystem/CMD_LikeOrNot.h>
#import <HCBaseSystem/SevenSwitch.h>


#define PLAYPANNEL_HEIGHT 0 //45
#define PROGRESS_HEIGHT 45
//#define TAG_SCROLLRECT 78654

//typedef NS_ENUM(NSInteger, MBKScrollDirection) {
//    MBKScrollDirectionNone,
//    MBKScrollDirectionUp,
//    MBKScrollDirectionDown,
//};

//MBKScrollDirection mbDetectScrollDirection(float currentOffsetY, float previousOffsetY)
//{
//    return currentOffsetY > previousOffsetY ? MBKScrollDirectionUp   :
//    currentOffsetY < previousOffsetY ? MBKScrollDirectionDown :
//    MBKScrollDirectionNone;
//}

static MusicDetailViewController * _instanceDetailItem;

@interface MusicDetailViewController()<UIScrollViewDelegate,WTPlayerControlPannelDelegate,WTVideoPlayerProgressDelegate,WTVideoPlayerViewDelegate>
{
    
    //    UIView *containerView_;
    //    UIInputToolView *inputToolView_;
    
    // 播放区
    //    UIVisualEffectView *playerVisualEffectView_;
    //    UIButton *centerPlayBtn_;
    //    UIWebImageViewN *cover_;
    //    CGSize coverSize_;
    //    UIView *playerToolBarView_;
    
    // 信息区
    //    UIView *authorInfoView_;
    //    MtvInfoView *mtvInfoView_;
    // 内容区
    //    UIView *contentContainerView_;
    //    UIView *tagsContainerView_;
    //    UIView *swipeContainerView_;
    
    UIButton * returnBtn_;
    UIButton * reportBtn_;
    //    SevenSwitch *commentSwitch_;
    
    // swipe
    //    SwipeView * listView_;
    //    UISwipePager * pager_;
    //    UIListViewA * onePageView_;
    NSArray *tags_;
    //
    CGFloat screenWidth_;
    CGFloat screenHeight_;
    CGFloat playerHeightMax_;
    CGFloat playerHeightMin_;
    CGFloat currentPlayerHeight_;
    CGFloat lastPlayerHeight_;
    CGFloat tagsHeight_;
    
    CGFloat mtvInfoHeight_;
    CGFloat centerPlayWidth_;
    //
    BOOL needSetupUI_;
    BOOL isPlayViewScrolling_;
    BOOL canPushPlayView_;
    
    DeviceConfig * config_;
    //    RecordRemindeView *recordReminderView_;
    
    
    CGRect playFrameForPortrait_;
    
    BOOL needPlayAfterPause_;
    
    //    ShareView *shareView_;
    
    //    LoginViewNew *loginView_;
    
    //    BOOL canShowComments_;
    //    BOOL needRefreshComments_;
    CGFloat commentForWhen_;
    
    //    UIView  *dynamicCountView_;
    //    UILabel *dynamicCountLabel_;
    
    //    DynamicView * currentDynamicView_;
    //    DynamicView * listViewDynamicItem_;
    //    int currentTab_;
    
    int openTypeAfterLogin_;
    NSMutableDictionary * tempDataDic_;
    
    //    BOOL isCanMove_;
    //    NSInteger objectMovingID_;
    //    CGPoint touchPointStart_;
    //    BOOL isMoving_;
    //    CGFloat lastSecondsBeMoving_;
    
    BOOL canQueryList_;
    
    UIPanGestureRecognizer * panRecognizer_;
}
@property(nonatomic,strong) UICommentsView * commentListView_;
//@property(nonatomic,strong) UINavigationItem *topItem;
//@property(nonatomic,strong) UILabel *titleLabel;
//@property (strong, nonatomic)  UITextField *commentText;

//@property (nonatomic) MBKScrollDirection previousScrollDirection;
@property (nonatomic) CGFloat previousOffsetY;

@end

@implementation MusicDetailViewController
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
//- (UIImage *)getCoverImage
//{
//    if(cover_ && cover_.image)
//        return cover_.image;
//    else
//        return nil;
//}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _instanceDetailItem = self;
    [self addEnterbackgroundObserver];
    //    if(UIInterfaceOrientationIsLandscape(self.navigationController.interfaceOrientation))
    //    {
    //        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    //        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    //    }
    [playContainerView_ playerWillEnterForeground];
    //    if(mplayer_ && isAutoPlaying_)
    //    {
    //        [self playItem:nil seconds:-1];
    //    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    //    if (![self becomeFirstResponder]) {
    //        NSLog(@"Become First Responder Faild 2222 ");
    //    }
    //    NSLog(@"is first response:%d",[self isFirstResponder]);
    
    if (needSetupUI_) {
        [self setupUI];
    }
    
    // 切换 statusBar 状态
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    _instanceDetailItem = nil;
    [playContainerView_ playerWillEnterBackground];
    //    if(playContainerView_ && playContainerView_.isPlaying)
    //    {
    //        [self pauseItem:nil];
    //    }
    
    //    NSString *downloadURL = [currentMtv_ getDownloadUrlOpeated:netStatus_ userID:userInfo_.UserID];
    //    [self stopCacheMTV:downloadURL];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
}
//- (void)viewDidDisappear:(BOOL)animated
//{
//    [super viewDidDisappear:animated];
//    [[UIApplication sharedApplication]endReceivingRemoteControlEvents];
//    [self resignFirstResponder];
//}
- (BOOL)canBecomeFirstResponder
{
    return YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    config_ = [DeviceConfig config];
    self.view.backgroundColor = [UIColor whiteColor];
    
    bgTask_= UIBackgroundTaskInvalid;
    
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error) {
        NSLog(@"Audio Session Set Category Error %@",error);
    }
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error) {
        NSLog(@"Audio Session Set Active Error %@",error);
    }
    
    
    needSetupUI_ = YES;
    canPushPlayView_ = YES;
    //playerHeightMax_ = 210 * config_.Height/667 + PLAYPANNEL_HEIGHT;
    playerHeightMax_ = config_.Width + PLAYPANNEL_HEIGHT;
    //playerHeightMin_ = 64;
    playerHeightMin_ = 150 * (float)config_.Height/667.0;
    centerPlayWidth_ = 60;
    
    mtvInfoHeight_ = 50;
    tagsHeight_ = 35;
    
    canQueryList_ = NO;
    
    openTypeAfterLogin_ = 0;
    tempDataDic_ = [NSMutableDictionary new];
    
    //    if(!userManager_)
    //    {
    //        userManager_ = [UserManager sharedUserManager];
    //    }
    //    commentManager_ = [CommentViewManager new];
    //    userInfo_ = [userManager_ currentUser];
    //    netStatus_ = [[MTVUploader sharedMTVUploader] networkStatus];
    //    mediaEditManager_ = [MediaEditManager shareObject];
    
    if (needSetupUI_ && currentMtv_) {
        [self setupUI];
        //        [self setUpForDismissKeyboard];
        //        self.keyboardMode = keyboardModeNewInputView;
        //        [self setRootViewKeyboardEffect:swipeContainerView_];
        //[self setRootViewKeyboardEffect:contentContainerView_];
        //        [inputToolView_ registerKB:nil];
        //        [self.view bringSubviewToFront:inputToolView_];
        
        [self setupData];
    }
    else
    {
        [self setupUI];
        //        [self buildStartView:self.view];
    }
    
    //    [[AudioCenter shareAudioCenter] setAudioSessionForRecord];
    //    [[AudioCenter shareAudioCenter] startAudioController];
}

- (void)setupWithDictionary:(WindowItem *)winItem
{
    if(winItem.WinParameters)
    {
        NSDictionary * dic = winItem.WinParameters;
        MTV * item = nil;
        if([dic objectForKey:@"sharetitle"])
        {
            self.shareTitle = [dic objectForKey:@"sharetitle"];
        }
        if ([[dic objectForKey:@"source"] isEqualToString:@"cache"]) {
            item = [[MediaEditManager shareObject] mergeMTVItem];
            Samples * sample = [[MediaEditManager shareObject] CurrentSample];
            if(sample && sample.SampleID>0)
            {
                currentSample_ = [MediaEditManager shareObject].Sample;
            }
        }
        else if([[dic objectForKey:@"source"] isEqualToString:@"get"])
        {
            [[MediaEditManager shareObject]clear];
            
            if ([[dic objectForKey:@"issample"] intValue]) {
                if ([dic objectForKey:@"sampleid"]) {
                    [self loadSample:[[dic objectForKey:@"sampleid"] intValue]];
                }
            }
            else{
                if ([dic objectForKey:@"mtvid"]) {
                    [self loadMTV:[[dic objectForKey:@"mtvid"] intValue]];
                }
            }
        }
        
        if(item)
        {
            [self setCurrentMTV:item];
            [self setupData];
        }
    }
}
- (void)setupWithMtvID:(int)mtvID
{
    [[MediaEditManager shareObject]clear];
    [self loadMTV:mtvID];
}
- (void)setCurrentMTV:(MTV *)mtv
{
    //    [self removeStartView];
    mtv.IsLandscape = YES;
    currentMtv_ = mtv;
//    [UserManager sharedUserManager].currentSettings.EnbaleCacheWhenPlaying = YES;
    [MediaEditManager shareObject].mergeMTVItem = mtv;
    //    mtv.IsLandscape = NO;
    //    [[MediaEditManager shareObject] setCacheDataBetweenWindows:mtv sample:nil];
    //    [MediaEditManager shareObject].CurrentMTV = mtv;
    
    if(needSetupUI_)
    {
        [self setupUI];
    } else {
        //        [self refreshSwipeView];
    }
    //    if (currentDynamicView_) {
    //        //[currentDynamicView_ setHeaderView:authorInfoView_];
    //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //            [currentDynamicView_ setHeaderView:mtvInfoView_];
    //        });
    //    }
    
    //[self setPlayBackInfoA];
    //[self setupData];
}
- (void)setupUI
{
    if([NSThread isMainThread]==NO)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self setupUI];
                       });
        return;
    }
    needSetupUI_ = NO;
    
    screenWidth_ = config_.Width;
    screenHeight_ = config_.Height;
    //
    //    if(!userManager_)
    //    {
    //        userManager_ = [UserManager sharedUserManager];
    //    }
    
    //#ifdef USE_CACHEPLAYING
    //    if([userManager_ enableCachenWhenPlaying])
    //    {
    //        if(!localFileVDCItem_)
    //        {
    //            localFileVDCItem_ = [[VDCManager shareObject]getVDCItemByMtv:currentMtv_ urlString:nil];
    //        }
    //    }
    //#endif
    //    NSLog(@"MusicDetailViewController frame = %@",NSStringFromCGRect(self.view.frame));
    //    containerView_ = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth_, screenHeight_)];
    //    [self.view addSubview:containerView_];
    // container Height
    CGFloat contentHeight = screenHeight_-(playerHeightMax_+49);// 49为底部输入框
    //    CGFloat swipeHeight = contentHeight-tagsHeight_;
    // container subView
    {
        //        returnBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];
        //        returnBtn_.frame = CGRectMake(10, 20, 40, 40);
        //        [returnBtn_ setImage:[UIImage imageNamed:@"play_back_icon.png"] forState:UIControlStateNormal];
        //        [returnBtn_ addTarget:self action:@selector(returnToParent:) forControlEvents:UIControlEventTouchUpInside];
        //        [self.view addSubview:returnBtn_];
        //
        //        playContainerView_ = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth_, playerHeightMax_)];
        //        [self.view addSubview:playContainerView_];
        //        playContainerView_.userInteractionEnabled = YES;
        //        playFrameForPortrait_ = playContainerView_.frame;
        //
        //        authorInfoView_ = [[UIView alloc] initWithFrame:CGRectMake(0, playerHeightMax_, screenWidth_, authorInfoHeight_)];
        //        [self.view addSubview:authorInfoView_];
        
        //        contentContainerView_ = [[UIView alloc] initWithFrame:CGRectMake(0, playerHeightMax_, screenWidth_, contentHeight)];
        //        [self.view addSubview:contentContainerView_];
        
        //        tagsContainerView_ = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth_, tagsHeight_)];
        //        [contentContainerView_ addSubview:tagsContainerView_];
        //        swipeContainerView_ = [[UIView alloc] initWithFrame:CGRectMake(0, tagsHeight_, screenWidth_, swipeHeight)];
        //        [contentContainerView_ addSubview:swipeContainerView_];
        
        
        returnBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];
        returnBtn_.frame = CGRectMake(10, 20, 40, 40);
        [returnBtn_ setImage:[UIImage imageNamed:@"play_back_icon.png"] forState:UIControlStateNormal];
        [returnBtn_ addTarget:self action:@selector(returnToParent:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:returnBtn_];
        
        playContainerView_ = [[HCPlayerWrapper alloc] initWithFrame:CGRectMake(0, 0, screenWidth_, playerHeightMax_)];
        currentPlayerHeight_ = playerHeightMax_;
        //        [playContainerView_ setPlayerData:currentMtv_ sample:currentSample_];
        playContainerView_.delegate = self;
        
        [self.view addSubview:playContainerView_];
        playContainerView_.userInteractionEnabled = YES;
        playFrameForPortrait_ = playContainerView_.frame;
        
    }
    //report
    //    {
    ////        reportBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];
    ////        reportBtn_.frame = CGRectMake(config_.Width - 40 - 10, 20, 40, 40);
    ////        [reportBtn_ setImage:[UIImage imageNamed:@"report.png"] forState:UIControlStateNormal];
    ////        [reportBtn_ addTarget:self action:@selector(reportMtv:) forControlEvents:UIControlEventTouchUpInside];
    ////        [self.view addSubview:reportBtn_];
    //
    //        CGFloat left = config_.Width - 50 - 10;
    //        commentSwitch_ = [[SevenSwitch alloc]initWithFrame:CGRectMake(left, 30, 40, 25)];
    //        commentSwitch_.isRounded = YES;
    //        commentSwitch_.hidden = NO;
    //
    //        [commentSwitch_ setup];
    //        [commentSwitch_ setOn:YES];
    //        commentSwitch_.knobImage = [UIImage imageNamed:@"commentswitch"];
    //        commentSwitch_.borderColor = [UIColor clearColor];
    //        commentSwitch_.onColor = COLOR_BA;
    //        commentSwitch_.activeColor = COLOR_CF;
    //        commentSwitch_.inactiveColor = COLOR_CF;
    //
    //        [self.view addSubview:commentSwitch_];
    //
    //        [commentSwitch_ addTarget:self action:@selector(showOrHideComment:) forControlEvents:UIControlEventValueChanged];
    //    }
    // 播放区
    //    {
    //        playContainerView_.backgroundColor = [UIColor blackColor];
    //        if ([DeviceConfig config].SysVersion >= 8.0) {
    //            // iOS8.0 以上可用 毛玻璃
    ////            playerVisualEffectView_ = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    ////            playerVisualEffectView_.frame = playContainerView_.bounds;
    ////            //            playerVisualEffectView_.alpha = 0;
    ////            playerVisualEffectView_.hidden = YES;
    //            //[playContainerView_ addSubview:playerVisualEffectView_];
    //        }
    //        {
    //            // 滚动时的播放按钮
    //            centerPlayBtn_ = [[UIButton alloc] initWithFrame:CGRectMake((playContainerView_.frame.size.width-centerPlayWidth_)/2, (playerHeightMax_-centerPlayWidth_)/2, centerPlayWidth_, centerPlayWidth_)];
    //            [centerPlayBtn_ setImage:[UIImage imageNamed:@"play"]
    //                               forState:UIControlStateNormal];
    //            [centerPlayBtn_ setImage:[UIImage imageNamed:@"stop"]
    //                               forState:UIControlStateSelected];
    //            [centerPlayBtn_ addTarget:self action:@selector(tempPlayPauseBtnClick:)
    //                        forControlEvents:UIControlEventTouchUpInside];
    //            //centerPlayBtn_.alpha = 1;
    //            [self addSubview:centerPlayBtn_];
    //        }
    //        // 封面
    //        {
    //            cover_ = [[UIWebImageViewN alloc] initWithFrame:CGRectMake(0, 0, playContainerView_.frame.size.width, playerHeightMax_ - PLAYPANNEL_HEIGHT)];
    //            //cover_.isFill_ = YES;
    //            cover_.keepScale_ = YES;
    //            cover_.fastMode = NO;
    //            cover_.contentMode = UIViewContentModeScaleAspectFit;
    //            cover_.clipsToBounds = YES;
    ////            cover_.image = [UIImage imageNamed:PLAYERHOLDER];
    //            [playContainerView_ addSubview:cover_];
    //        }
    //        // 工具栏
    //        {
    //            CGRect toolFrame = CGRectMake(0, playerHeightMax_- PROGRESS_HEIGHT - PLAYPANNEL_HEIGHT, screenWidth_, PROGRESS_HEIGHT);
    //            progressView_ = [[WTVideoPlayerProgressView alloc]initWithFrame:toolFrame needGradient:YES];
    //
    //            [progressView_ setColorsForBackground:[UIColor whiteColor]
    //                                       foreground:COLOR_BA //[UIColor redColor] //COLOR_P1
    //                                          caching:[UIColor yellowColor] //COLOR_P2
    //                                           handle:[UIColor clearColor]
    //                                           border:[UIColor colorWithRed:0.0 green:205.0/255.0 blue:184.0/255.0 alpha:1.0]];
    //
    //            [progressView_ setTotalSeconds:currentMtv_.Durance];
    //#ifdef USE_CACHEPLAYING
    //            if([userManager_ enableCachenWhenPlaying])
    //            {
    //                [progressView_ setCacheKey:localFileVDCItem_.key];
    //            }
    //#endif
    //            progressView_.isFullScreen = NO;
    //            progressView_.GuideAudioBtn.hidden = YES;
    //            [playContainerView_ addSubview:progressView_];
    //
    //            [progressView_ changeFrame:toolFrame];
    //
    //            progressView_.delegate = self;
    //        }
    //        //top pannel
    //        {
    //            CGRect toolFrame = CGRectMake(0, 0, screenWidth_, 40);
    //            maxPannel_ = [[WTPlayerTopPannel alloc]initWithFrame:toolFrame];
    //            if(currentMtv_)
    //            {
    //                [maxPannel_ setMTVItem:currentMtv_ sample:currentSample_];
    //                //                maxPannel_.MTVItem = currentMtv_;
    //            }
    //            [playContainerView_ addSubview:maxPannel_];
    //            maxPannel_.hidden = YES;
    //            maxPannel_.backgroundColor = [UIColor clearColor];
    //            maxPannel_.delegate = self;
    //        }
    //        //按钮栏
    //        {
    ////            playPannel_ = [[WTPlayerControlPannel alloc]initWithFrame:CGRectMake(0, playContainerView_.frame.size.height - PLAYPANNEL_HEIGHT, playContainerView_.frame.size.width, PLAYPANNEL_HEIGHT)];
    ////            //            NSLog(@"pannel frame:%@",NSStringFromCGRect(playPannel_.frame));
    ////            playPannel_.backgroundColor = [UIColor clearColor];
    ////            [playPannel_ setMTVItem:currentMtv_ sample:currentSample_];
    ////            playPannel_.delegate = self;
    ////            // [playContainerView_ addSubview:playPannel_];
    ////
    ////            // NSLog(@"pannel frame:%@",NSStringFromCGRect(playPannel_.frame));
    //        }
    //    }
    
    // 创建listView
    //    [self refreshSwipeView];
    
    // recordReminderView
    //    {
    //        recordReminderView_ = [[RecordRemindeView alloc] initWithFrame:CGRectMake((screenWidth_ - 150)/2, (screenHeight_ - 150)/2, 150, 150)];
    //        recordReminderView_.hidden = YES;
    //        [self.view addSubview:recordReminderView_];
    //    }
    //    {
    //        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showProgressView:)];
    //        tap.enabled = YES;
    //        tap.numberOfTapsRequired = 1;
    //        tap.cancelsTouchesInView = NO;
    //        [playContainerView_ addGestureRecognizer:tap];
    //    }
    
    /* // 弹幕整合到player
     if(!self.commentListView_)
     {
     if (!commentManager_) commentManager_ = [CommentViewManager new];
     commentManager_.showType = CommentShowTypePop;
     self.commentListView_ = [commentManager_ createCommentsView:CGRectMake(0, 50, config_.Height, config_.Width - 150)];
     [self.view addSubview:self.commentListView_];
     self.commentListView_.hidden = YES;
     // self.commentListView_.backgroundColor = [UIColor yellowColor];
     }
     */
    
    //    if(currentMtv_ && currentMtv_.AudioRemoteUrl && currentMtv_.AudioRemoteUrl.length>2)
    //    {
    //        [playPannel_ setUseGuidAudio:YES];
    //        [progressView_ setGuidAudio:YES];
    //    }
    //    else
    //    {
    //        [playPannel_ setUseGuidAudio:NO];
    //        [progressView_ setGuidAudio:NO];
    //    }
    // 发动态
    //    if(!inputToolView_)
    //    {
    //        inputToolView_ = [[UIInputToolView alloc] initWithFrame:CGRectMake(0, screenHeight_-49, screenWidth_, 49)];
    //        inputToolView_.delegate = self;
    //        if(currentMtv_.SampleID==0)
    //        {
    //            [inputToolView_ hideSingButton];
    //        }
    //        [self.view addSubview:inputToolView_];
    //
    //        self.keyboardMode = keyboardModeNewInputView;
    //        [inputToolView_ registerKB:self];
    //    }
    
    [self bringToolBar2Front];
}

//- (void)buildMtvInfoView
//{
//    if (mtvInfoView_) return;
//    mtvInfoView_ = [[MtvInfoView alloc] initWithFrame:CGRectMake(0, 0, _ScreenWidth, mtvInfoHeight_)];
//    mtvInfoView_.delegate = self;
//}
- (BOOL)canShowSwipeView
{
    //    return (currentMtv_.SampleID>0);
    return NO;
}

- (void)resetPlayFrame:(CGRect)frame
{
    [playContainerView_ resizeViews:frame];
}
- (void)setupData
{
    NSLog(@"getData.....");
    if([NSThread isMainThread])
    {
//        [playContainerView_ setPlayerData:currentMtv_ sample:currentSample_];
        [[UserManager sharedUserManager]currentSettings].EnbaleCacheWhenPlaying = YES;
        [playContainerView_ setLyricBottomSpace:30];
        [playContainerView_ setPlayRange:10 end:-1];
        
//        AVURLAsset *movieAsset = nil;
//        NSString * urlString = [currentMtv_ getMTVUrlString:config_.networkStatus userID:[[UserManager sharedUserManager] userID] remoteUrl:nil];;
//        NSLog(@"play item url:%@",urlString);
//        
//        movieAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:urlString] options:nil];
//        AVPlayerItem * playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
//        [playContainerView_ setPlayerUrl:[NSURL URLWithString:urlString]];
        [playContainerView_ setPlayerData:currentMtv_ sample:nil];
        playContainerView_.backgroundColor = [UIColor blackColor];
//        [playContainerView_ setPlayRate:1];
        playContainerView_.isLoop = YES;
        
        [self bringToolBar2Front];
    }
    else
    {
        __weak MusicDetailViewController * weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           __strong MusicDetailViewController * strongSelf = weakSelf;
                           [strongSelf setupData];
                           strongSelf = nil;
                       });
    }
}
- (void) playMTVItemWithMTVID:(long)MTVID
{
    CMD_CREATE(cmd, GetMtvInfo, @"GetMtvInfo");
    cmd.MtvID = (int)MTVID;
    cmd.HasSample = NO;
    cmd.CMDCallBack = ^(HCCallbackResult * result)
    {
        if(result.Code==0)
        {
            if (result.Data) {
                MTV *item = (MTV *)result.Data;
                [self playMTVItem:item];
            }
        }
    };
    [cmd sendCMD];
}

- (void)playMTVItem:(MTV *)item
{
    MTV * orgItem = [self getCurrentMTV];
    //将歌词同步赋值(同一伴奏)
    if(item!=orgItem && (!item.Lyric || item.Lyric.length<3)
       &&item.SampleID >0 && item.SampleID== orgItem.SampleID
       && orgItem.Lyric && orgItem.Lyric.length>2
       )
    {
        item.Lyric = orgItem.Lyric;
    }
    [self setCurrentMTV:item];
    if([NSThread isMainThread])
    {
        [self setupData];
        
        [playContainerView_ setPlayRange:0 end:-1];
        [playContainerView_ play];
        //    [self playItem:nil seconds:0];
        // player 放大最大位置
        if (currentPlayerHeight_ < playerHeightMax_) {
            currentPlayerHeight_ = playerHeightMax_;
            [self pushPlayViewToPosition:currentPlayerHeight_ animated:YES];
        }
    }
}

#pragma mark - player view
- (void)pushPlayViewToPosition:(CGFloat)playerHeight animated:(BOOL)animated
{
    if (isPlayViewScrolling_)  {
        canPushPlayView_ = YES;
        
        return;
    }
    
    if (lastPlayerHeight_ == playerHeight && (lastPlayerHeight_ >= playerHeightMax_ || lastPlayerHeight_ <= playerHeightMin_)) return;
    
    lastPlayerHeight_ = playerHeight;
    if (!animated)
    {
        [self changePlayViewFrame:playerHeight];
        [self showPlayerHeight:playerHeight];
    }
    else
    {
        isPlayViewScrolling_ = YES;
        [UIView animateWithDuration:0.2f animations:^{
            [self changePlayViewFrame:playerHeight];
        } completion:^(BOOL finished) {
            isPlayViewScrolling_ = NO;
            [self showPlayerHeight:playerHeight];
        }];
    }
}
- (void)showPlayerHeight:(CGFloat)playerHeight
{
    canPushPlayView_ = YES;
    
    //    if (playerHeight == playerHeightMax_) {
    //        if ([self canShowComment]) {
    //            if (!mplayer_.commentListView) {
    //                [self initCommentView];
    //            }
    //            if (self.isPlaying) {
    //                [mplayer_ showComments];
    //                [mplayer_ refreshComment];
    //            }
    //        }
    //        commentSwitch_.hidden = NO;
    //    } else if (playerHeight < playerHeightMax_) {
    //        [mplayer_ hideComments];
    //        commentSwitch_.hidden = YES;
    //    }
}

- (void)showPlayOrPause:(CGFloat)height
{
    //    CGFloat scale = (float)(playerHeightMax_-height)/(playerHeightMax_-playerHeightMin_);
    //
    //    if (height >= playerHeightMax_)
    //    {
    //        //centerPlayBtn_.hidden = YES;
    //        //centerPlayBtn_.alpha = 0;
    //        CGRect frame = CGRectMake((playContainerView_.frame.size.width-centerPlayWidth_)/2, (height-centerPlayWidth_)/2, centerPlayWidth_, centerPlayWidth_);
    //        centerPlayBtn_.frame = frame;
    //
    ////        playerVisualEffectView_.hidden = YES;
    //        progressView_.hidden = NO;
    //        NSLog(@"height:%.1f > playerheightmax:%.1f",height,playerHeightMax_);
    //    }
    //    else
    //    {
    //        if(fabs(height - (playerHeightMax_ - 40))<3)
    //        {
    //            height = (playerHeightMax_ - 40);
    //        }
    //        //        if (fabs(height - (playerHeightMax_ - 40))>0.5) { //防止抖动
    //
    //        //NSLog(@"height:%.1f <= playerheightmax:%.1f - 40 ",height,playerHeightMax_);
    //        //centerPlayBtn_.alpha = scale;
    //        //centerPlayBtn_.hidden = NO;
    //
    //        //随时定位在中央,在可见区中央
    //        CGFloat top = 0 - playContainerView_.frame.origin.y
    //        + (playContainerView_.frame.origin.y + playContainerView_.frame.size.height - 30)/2.0f;
    //        centerPlayBtn_.frame = CGRectMake((playContainerView_.frame.size.width - centerPlayWidth_)/2.0f,
    //                                             top,
    //                                             centerPlayWidth_, centerPlayWidth_);
    //
    //
    //        CGRect playerFrame = [self getPlayerFrame];
    //        playerFrame.origin.x = 0;
    //        mplayer_.frame = playerFrame;
    //        cover_.frame = playerFrame;
    //
    //        //             progressView_.alpha = 0;
    //        //            [progressView_ hide:NO];
    //
    //        // 改变透明度
    //        playerFrame.size.height += PLAYPANNEL_HEIGHT;
    ////        playerVisualEffectView_.hidden = NO;
    ////        playerVisualEffectView_.alpha = scale;
    ////        playerVisualEffectView_.frame = playerFrame;
    //        //NSLog(@"playerVisualEffectView_.alpha = %.1f",scale);
    //        //        }
    //        //        else
    //        //        {
    //        //            NSLog(@"height:%.1f > playerheightmax:%.1f - 40",height,playerHeightMax_);
    //        //            playerVisualEffectView_.hidden = YES;
    //        //            centerPlayBtn_.hidden = YES;
    //        //
    //        //            //            progressView_.alpha = MAX(0,(1 - scale)/2);
    //        //        }
    //    }
}
- (void)changePlayViewFrame:(CGFloat)playerHeight
{
    //    if ([self isKeyboardShow]) return;
    
    NSLog(@"playerHeight = %f",playerHeight);
    //playContainerView_.frame = CGRectMake(0, -(playerHeightMax_-playerHeight), _ScreenWidth, playerHeightMax_);
    // 播放区
    CGRect playFrame = CGRectMake(0, 0, config_.Width, playerHeight);;
    playContainerView_.frame = playFrame;
    [self resetPlayFrame:playFrame];
    //    // 播放器
    //    [mplayer_ resizeViewToRect:playFrame andUpdateBounds:YES withAnimation:YES hidden:NO changed:nil];
    
    //authorInfoView_.frame = CGRectMake(0, playerHeight, screenWidth_, authorInfoHeight_);
    //NSLog(@"player container frame:%@",NSStringFromCGRect(playContainerView_.frame));
    
    //    CGFloat contentHeight = screenHeight_-(playerHeight+49);// 49为底部输入框
    //    contentContainerView_.frame = CGRectMake(0, playerHeight, config_.Width, contentHeight);
    //
    //    CGFloat top =[self canShowSwipeView]==NO?0:tagsHeight_;
    
    //    CGFloat swipeHeight = contentHeight- top;
    //    swipeContainerView_.frame = CGRectMake(0, top, screenWidth_, swipeHeight);
    
    
    // swipeView 内部frame变化
    //    if(listView_ && listView_.hidden==NO)
    //    {
    //        CGRect frame = CGRectMake(0, 0, screenWidth_, swipeHeight);
    //        //        NSLog(@"swipe frame = %@",NSStringFromCGRect(frame));
    //        listView_.frame = frame;
    //
    //        // 滚动过程中只改变当前子view的高度 滚动结束再改变其它两个view的高度 以免造成卡顿
    //        //for (int i = 0; i < listView_.numberOfItems; i++) {
    //        UIListViewA *itemView = (UIListViewA *)[listView_ currentItemView];
    //        itemView.frame = CGRectMake(itemView.frame.origin.x, itemView.frame.origin.y, itemView.frame.size.width, frame.size.height);
    //        [itemView changeSubviewsFrame:frame];
    //        //}
    //    }
    //    else if(currentDynamicView_)
    //    {
    //        CGRect frame = swipeContainerView_.bounds;
    //        currentDynamicView_.frame = frame;
    //        [currentDynamicView_ changeSubviewsFrame:frame];
    //    }
    
    //    NSLog(@"play container:%@",NSStringFromCGRect(playContainerView_.frame));
    //    NSLog(@"play frame:%@",NSStringFromCGRect(mplayer_.frame));
    [self showPlayOrPause:playerHeight];
}

#pragma mark - button event
- (void) showButtonsPause
{
    
}
- (void) showButtonsPlaying
{
    
}
#pragma mark - videoProgress delegate
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
    NSLog(@"need full screen...%d",fullScreen);
    if(fullScreen)
    {
        [self doFullScreen:UIInterfaceOrientationLandscapeRight];
    }
    else
    {
        [self cancelFullScreen:UIInterfaceOrientationPortrait];
    }
}
- (void)videoProgress:(WTVideoPlayerProgressView *)progressView didHidden:(BOOL)hidden
{
    //    if(progressView.isFullScreen)
    //    {
    //        if(hidden)
    //        {
    //            [maxPannel_ hideRightMenu:nil animates:YES];
    //            [maxPannel_ hideWithAnimates:YES];
    //        }
    //        else
    //        {
    //            maxPannel_.hidden = hidden;
    //            [maxPannel_ hideRightMenu:nil animates:NO];
    //        }
    //    }
    //    else
    //    {
    //        //returnBtn_.hidden = hidden;
    //        maxPannel_.hidden = YES;
    //    }
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
    //    if(record)
    //    {
    //        [self readyToRelease];
    //        [mediaEditManager_ clear];
    //        if(currentMtv_.UserID == userInfo_.UserID && userInfo_.UserID>0)
    //        {
    //            mediaEditManager_.mergeMTVItem = currentMtv_;
    //        }
    ////        NSString * url = [[HWindowStack shareObject]buildSingUrl:NO
    ////                                                          source:@"cache"
    ////                                                        sampleID:currentMtv_.SampleID
    ////                                                     isLandscape:currentMtv_.IsLandscape?1:0];
    ////        [[HWindowStack shareObject]openWindow:self urlString:url shouldOpenWeb:YES];
    //    }
}
- (BOOL)videoProgress:(WTVideoPlayerProgressView *)progressView isPlaying:(BOOL)isPlaying
{
    //    if(mplayer_ && mplayer_.playing)
    //        return YES;
    //    else
    return NO;
}
- (void)videoProgress:(WTVideoPlayerProgressView *)progressView Seek:(CGFloat)seconds
{
    //    if(mplayer_)
    //    {
    //        [mplayer_ seek:seconds accurate:YES];
    //    }
}
#pragma mark - share download....

//- (void)videoPannel:(WTPlayerControlPannel *)pannelView doShare:(CGFloat)seconds
//{
////    if ([UserManager sharedUserManager].isLogin) {
////        [self openShareView];
////    }
////    else{
////        openTypeAfterLogin_ = 1;//分享
////        [self openLoginView];
////    }
//}
//- (void)videoPannel:(WTPlayerControlPannel *)pannelView guideChanged:(BOOL)isGuide
//{
//    if (isGuide) {
//        leaderPlayer_.volume = 1;
//    }
//    else{
//        leaderPlayer_.volume = 0;
//    }
//}
//- (void)videoPannel:(WTPlayerControlPannel *)pannelView showComments:(BOOL)show{
//    NSLog(@"need comments... 1 Or 0 -> %d",show);
//    [commentSwitch_ setOn:show];
//
//    if (!mplayer_) return;
//    if (show) {
//        if(!mplayer_.commentListView)
//        {
//            [self initCommentView];
//        }
//        [mplayer_ showComments];
//        [mplayer_ refreshComment];
//    } else {
//        [mplayer_ hideComments];
//    }
//}
//- (void)videoPannel:(WTPlayerControlPannel *)pannelView editComments:(BOOL)show
//{
//    NSLog(@"show comment input....");
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
////    self.keyboardMode = keyboardModeNewInputView;
////    [inputToolView_ registerKB:self];
////
////    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////        [inputToolView_ becomeFirstResponder];
////        //        self.commentText.selectedTextRange = NSMakeRange(0, 0);
////    });
//
//
//    //    textView.selectedRange = NSMakeRange(0, 0);
//    //    }
//}
//- (void)videoPannel:(WTPlayerControlPannel *)pannelView likeIt:(BOOL)isLike
//{
////    if (![self checkLoginStatus]) return;
//
//    MTV * item = currentMtv_;
//    CMD_CREATE(cmd, LikeOrNot, @"LikeOrNot");
//
//    if(item.MTVID>0)
//    {
//        cmd.MtvID = item.MTVID;
//    }
//    else
//    {
//        cmd.MtvID = item.SampleID;
//        cmd.ObjectType = HCObjectTypeSample;
//    }
//    cmd.ObjectUserID = item.UserID;
//    cmd.IsLike = !isLike;
//    cmd.CMDCallBack = ^(HCCallbackResult * result)
//    {
//        if(result.Code==0)
//        {
//            if (pannelView && pannelView == playPannel_) {
//                [playPannel_ showLikeStatus];
//            } else {
//                [maxPannel_ showLikeStatus];
//            }
////            for (UIView * v in listView_.visibleItemViews) {
////                if([v isKindOfClass:[RankView class]])
////                {
////                    RankView * vv = (RankView *)v;
////                    [vv setConcernChanged:currentMtv_];
////                }
////            }
//
//            if (currentMtv_.MTVID>0) {
//                NSMutableDictionary *dic = [NSMutableDictionary new];
//                [dic setValue:@(HCObjectTypeMTV) forKey:@"objecttype"];
//                [dic setValue:@(currentMtv_.MTVID) forKey:@"objectid"];
//                [dic setValue:@(!isLike) forKey:@"islike"];
//                [[NSNotificationCenter defaultCenter] postNotificationName:NT_CHANGELIKESTATUS object:nil userInfo:dic];
//            }
//        }
//    };
//    [cmd sendCMD];
//
//}
//- (void)videoPannel:(WTPlayerControlPannel *)pannelView editMtv:(BOOL)edit
//{
//    NSLog(@"edit");
//    if(edit)
//    {
//        [self readyToRelease];
//        [mediaEditManager_ clear];
//        mediaEditManager_.mergeMTVItem = [self getCurrentMTV];
////        NSString * url = [[HWindowStack shareObject]buildSingUrl:NO source:@"cache" sampleID:currentMtv_.SampleID];
//
//
////        NSString * url = [[HWindowStack shareObject]buildEditUrl:currentMtv_.MTVID isLandscape:mediaEditManager_.mergeMTVItem.IsLandscape?1:0];
////        [[HWindowStack shareObject]openWindow:self urlString:url shouldOpenWeb:YES];
//    }
//}
//- (void)videoPannel:(WTPlayerControlPannel *)pannelView didReturn:(BOOL)isReturn
//{
//    [self cancelFullScreen:UIInterfaceOrientationPortrait];
//}

//- (BOOL)canShowComment
//{
//    canShowComments_ = maxPannel_.isCommentsShow || commentSwitch_.isOn;
//    return canShowComments_;
//}
//- (BOOL)isMaxWindowPlay
//{
//    return (currentPlayerHeight_ >= playerHeightMax_);
//}
//- (void)showOrHideComment:(id)sender
//{
//    BOOL isOn = commentSwitch_.isOn;
//    [maxPannel_ setIsCommentsShow:isOn];
//    if (!mplayer_)
//        return;
//
//    if (isOn) {
//        if (currentPlayerHeight_ >= playerHeightMax_) {
//            if (!mplayer_.commentListView) {
//                [self initCommentView];
//            }
//            [mplayer_ showComments];
//            [mplayer_ refreshComment];
//        }
//    } else {
//        [mplayer_ hideComments];
//    }
//}
- (void)videoPannel:(WTPlayerControlPannel *)pannelView reportMtv:(BOOL)report
{
    [self reportMtv:nil];
}

#pragma mark - mtvInfoDelegate
- (void)backClick:(id)sender {
    [self returnToParent:sender];
    //    if (self.navigationController)
    //        [self.navigationController popToRootViewControllerAnimated:YES];
    //    else
    //        [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)stopCacheMTV:(NSString *)url
{
    [[VDCManager shareObject] stopDownload:nil];
}

#pragma mark - show hide
- (CGRect)getPlayerFrame
{
    if(playContainerView_.isFullScreen)
    {
        if(currentMtv_.IsLandscape)
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
        CGRect containerFrame = playContainerView_.frame;
        containerFrame.size.height -= PLAYPANNEL_HEIGHT;
        containerFrame.origin.y = 0;
        containerFrame.origin.x = 0;
        return containerFrame;
    }
}
- (void) bringToolBar2Front
{
    [self.view bringSubviewToFront:playContainerView_];
    //    [self.view bringSubviewToFront:recordReminderView_];
    //[self.view bringSubviewToFront:self.commentListView_];
    
    [self.view bringSubviewToFront:returnBtn_];
    //[self.view bringSubviewToFront:reportBtn_];
    //    [self.view bringSubviewToFront:commentSwitch_];
    //    [self.view bringSubviewToFront:inputToolView_];
    //
    //    [self.view bringSubviewToFront:mplayer_.commentListView];
}

- (void)showMessage:(NSString *)msgTitle msg:(NSString *)msg
{
    SNAlertView *alert = [[SNAlertView alloc] initWithTitle:msgTitle
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:EDIT_IKNOWN
                                          otherButtonTitles:nil];
    alert.tag = 9999999;
    [alert show:self.view];
    PP_RELEASE(alert);
}


- (MTV*)getCurrentMTV
{
    return currentMtv_;
}

- (void)loadMTV:(int)mtvID
{
    CMD_CREATE(cmd, GetMtvInfo, @"GetMtvInfo");
    cmd.MtvID = mtvID;
    cmd.HasSample = YES;
    //    [self showProgressHUDWithMessage:@"waiting..."];
    cmd.CMDCallBack = ^(HCCallbackResult * result)
    {
        //        [self hideProgressHUD:YES];
        if(result.Code==0)
        {
            if (result.Data) {
                [self setCurrentMTV:(MTV *)result.Data];
                if(result.SecondsItem)
                {
                    Samples * sample = (Samples *)result.SecondsItem;
                    if(sample && sample.SampleID>0)
                    {
                        currentSample_ = [sample toMTV];
                    }
                }
                else if(currentMtv_.MTVID==0)
                {
                    currentSample_ = [currentMtv_ copyItem];
                    currentSample_.MTVID =0;
                }
                if(!currentMtv_.Lyric || currentMtv_.Lyric.length<2)
                {
                    currentMtv_.Lyric = currentSample_.Lyric;
                }
                [self setupData];
            }
        }
    };
    if ([cmd sendCMD]) {
        //        [self hideProgressHUD:YES];
    }
}

- (void)loadSample:(int)sampleID
{
    CMD_CREATE(cmd, GetSampleInfo, @"GetSampleInfo");
    cmd.sampleID = sampleID;
    cmd.CMDCallBack = ^(HCCallbackResult * result)
    {
        if(result.Code==0)
        {
            NSLog(@"call back ....");
            if (result.Data) {
                Samples * sample = (Samples *)result.Data;
                [[MediaEditManager shareObject]setSampleInfo:sample];
                
                if(sample.UserMTV)
                    [self setCurrentMTV:sample.UserMTV];
                else
                    [self setCurrentMTV:[MediaEditManager shareObject].Sample];
                NSLog(@"setup data");
                currentSample_ = [currentMtv_ copyItem];
                currentSample_.MTVID =0;
                [self setupData];
            }
        }
    };
    [cmd sendCMD];
}

- (MTV*)convertSample2Mtv:(Samples *)sampleItem
{
    return [sampleItem toMTV];
}


- (BOOL)currentItemIsSample
{
    return currentMtv_.MTVID == 0;
}
- (BOOL)downloadUserAudio:(MTV *)mtv
{
    //    if(!mtv || mtv.MTVID==0) return NO;
    //    if(!mtv.AudioRemoteUrl || mtv.AudioRemoteUrl.length<3) return NO;
    //
    //    if(![mediaEditManager_ checkAudioPath:mtv])
    //    {
    //        [[VDCManager shareObject]downloadUrl:mtv.AudioRemoteUrl
    //                                       title:[NSString stringWithFormat:@"%@ 用户音频",mtv.Title]
    //                                    urlReady:^(VDCItem *vdcItem, NSURL *videoUrl) {
    //
    //                                    } progress:^(VDCItem *vdcItem) {
    //
    //                                    } completed:^(VDCItem *vdcItem, BOOL completed, VDCTempFileInfo *tempFile) {
    //                                        if([HCFileManager isFileExistAndNotEmpty:vdcItem.localFilePath size:nil])
    //                                        {
    //                                            if(mtv.AudioFileName && mtv.AudioFileName.length>0)
    //                                            {
    //                                                [HCFileManager copyFile:vdcItem.localFilePath target:[mtv getAudioPathN] overwrite:YES];
    //                                                [[VDCManager shareObject]removeItem:vdcItem withTempFiles:YES includeLocal:YES];
    //                                            }
    //                                            else
    //                                            {
    //                                                [mtv setAudioPathN:vdcItem.localFileName];
    //                                                [[VDCManager shareObject]removeItem:vdcItem withTempFiles:YES includeLocal:NO];
    //                                                //                                                [[MTVUploader sharedMTVUploader]updateMTVKeyAndUserID:mtv];
    //                                            }
    //                                        }
    //                                    }];
    //        return YES;
    //    }
    return NO;
}

#pragma mark notification events
- (void)addEnterbackgroundObserver
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecordStarted:) name:NT_STARTRECORD object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecordStopped:) name:NT_STOPRECORD object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecordMeterChanged:) name:NT_RECORDMETERCHANGED object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCancelStatusChanged:) name:NT_CANSENDSTATUSCHANGED object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didIWantSing:) name:NT_IWANTSING object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginPlayAudio:) name:NT_BEGINPLAYAUDIO object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndPlayAudio:) name:NT_ENDPLAYAUDIO object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginFullScreen) name:UIWindowDidBecomeVisibleNotification object:nil];//进入全屏
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endFullScreen) name:UIWindowDidBecomeHiddenNotification object:nil];//退出全屏
}
- (void)removeEnterbackgroundObserver
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //    [[NSNotificationCenter defaultCenter]removeObserver:self name:NT_IWANTSING object:nil];
    //    [[NSNotificationCenter defaultCenter]removeObserver:self name:NT_BEGINPLAYAUDIO object:nil];
    //    [[NSNotificationCenter defaultCenter]removeObserver:self name:NT_ENDPLAYAUDIO object:nil];
    //
    //    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIWindowDidBecomeVisibleNotification object:nil];
    //    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIWindowDidBecomeHiddenNotification object:nil];
    //
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:NT_STARTRECORD object:nil];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:NT_STOPRECORD object:nil];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:NT_CANSENDSTATUSCHANGED object:nil];
}
- (void)willResignActive:(NSNotification *)notification
{
    //    if ([self isKeyboardShow]) {
    //        [self dismissKeyboard];
    //    }
    //    [((AppDelegate *)[UIApplication sharedApplication].delegate) decBackgroundRef];
}
- (void)didBecomeActive:(NSNotification*)notification
{
    //    [((AppDelegate *)[UIApplication sharedApplication].delegate) addBackgroundRef];
}
//后台播放相关
#pragma mark - play background
//
//- (NSMutableDictionary *)getParameters
//{
//    NSMutableDictionary * dic = [NSMutableDictionary new];
//    if(mplayer_ && mplayer_.playing)
//    {
//        [dic setObject:@(1) forKey:@"isplaying"];
//    }
//    else
//    {
//        [dic setObject:@(0) forKey:@"isplaying"];
//    }
//    return dic;
//}
//- (void)setParameters:(NSDictionary *)para
//{
//    BOOL isplaying = NO;
//    if(para && [para objectForKey:@"isplaying"])
//    {
//        isplaying = [[para objectForKey:@"isplaying"]intValue]>0;
//    }
//}


#pragma mark - rotation
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    //    if([self isFullScreen])
    //    {
    //        return UIInterfaceOrientationMaskLandscape;
    //    }
    //    else
    //    return UIInterfaceOrientationMaskAll;
    return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskPortraitUpsideDown;
}

#pragma mark -- 检测和处理屏幕的旋转
- (void) deviceOrientChange:(NSNotification *)notification
{
    UIDeviceOrientation or =  [UIDevice currentDevice].orientation;
    //    if(or == UIDeviceOrientationLandscapeLeft || or == UIDeviceOrientationLandscapeRight)
    //    {
    //        //        if([self isFullScreen]==NO)
    //        //        {
    //        if(or==UIDeviceOrientationLandscapeLeft)
    //        {
    //            [self doFullScreen:UIInterfaceOrientationLandscapeRight];
    //        }
    //        else
    //        {
    //            [self doFullScreen:UIInterfaceOrientationLandscapeLeft];
    //        }
    //        //        }
    //    }
    //    else
    //    {
    //        if(or == UIDeviceOrientationPortraitUpsideDown)
    //        {
    //            [self cancelFullScreen:UIInterfaceOrientationPortraitUpsideDown];
    //        }
    //        else
    //        {
    //            [self cancelFullScreen:UIInterfaceOrientationPortrait];
    //        }
    //    }
    
    [self doChangeOrientaion:or prevOrietation:lastOrientation_ count:0];
    //    [super deviceOrientChange:notification];
    lastOrientation_ = or;
}
- (void)doChangeOrientaion:(UIDeviceOrientation)or prevOrietation:(UIDeviceOrientation)prevOr count:(int)count
{
    //    UIDeviceOrientation or =  [UIDevice currentDevice].orientation;
    //需要判断Or的持久性，即防止方向快速切换导到的相关的问题
    
    if(or==lastOrientationDone_  || or == UIDeviceOrientationFaceUp || or == UIDeviceOrientationFaceDown) return;
    if(or!=lastOrientationDone_)
    {
        if(or==lastOrientation_) count ++;
        else  count = 0;
        if(count < 4)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
                [self doChangeOrientaion:or prevOrietation:lastOrientation_ count:count];
            });
            return;
        }
    }
    
    if(or == UIDeviceOrientationLandscapeLeft || or == UIDeviceOrientationLandscapeRight)
    {
        //        if([self isFullScreen]==NO)
        //        {
        if(or==UIDeviceOrientationLandscapeLeft)
        {
            [playContainerView_ doFullScreen:CGRectMake(0, 0, config_.Height, config_.Width)];
            //            [self doFullScreen:UIInterfaceOrientationLandscapeRight];
        }
        else
        {
            [playContainerView_ doFullScreen:CGRectMake(0, 0, config_.Height, config_.Width)];
            //            [self doFullScreen:UIInterfaceOrientationLandscapeLeft];
        }
        //        lastOrientationChangeTime_ = [NSDate date];
        lastOrientationDone_ = or;
        //        }
    }
    else
    {
        //        if(or == UIDeviceOrientationPortraitUpsideDown||or==UIDeviceOrientationPortrait)
        //        {
        //            [self cancelFullScreen:UIInterfaceOrientationPortraitUpsideDown];
        //        }
        //        else
        //        {
        //            //[self cancelFullScreen:UIInterfaceOrientationPortrait];
        //        }
        //        //        lastOrientationChangeTime_ = [NSDate date];
        //        lastOrientationDone_ = or;
    }
}
////开始旋转时会触发的方法
////经常用来暂停播放器播放,暂停视屏播放,以及关闭用户交互
//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
//}
////当旋转结束是时触发
////继续音乐,视频播放,以及打开的用户交互
//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
//    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
//}
//
////当将要开始旋转做动画时触发,经常用来在旋转时添加自定义动画
//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
//    //    //    NSLog(@"did layout...");
//    //    if([self isFullScreen])
//    //    {
//    //        [self doFullScreen:toInterfaceOrientation];
//    //    }
//    //    else
//    //    {
//    //        if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft
//    //           || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
//    //        {
//    //            [self doFullScreen:toInterfaceOrientation];
//    //        }
//    //        else
//    //        {
//    //            if(UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
//    //            {
//    //                self.view.transform = CGAffineTransformIdentity;
//    //                self.view.bounds = CGRectMake(0.0, 0.0, config_.Width,config_.Height);
//    //            }
//    //        }
//    //    }
//    if([self isFullScreen]&& UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
//    {
//        if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
//            self.view.transform = CGAffineTransformMakeRotation(0 - M_PI_2);
//        else
//            self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
//        self.view.bounds = CGRectMake(0.0, 0.0, config_.Height,config_.Width);
//    }
//    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
//}
//
//- (void)viewDidLayoutSubviews
//{
//    [super viewDidLayoutSubviews];
//}

- (BOOL)canShowRecordBtn
{
    
    if(currentSample_ && [currentSample_ hasVideo])
        //       && currentMtv_.UserID !=userManager_.userID)
    {
        return YES;
    }
    return NO;
}
- (void)doFullScreen:(UIInterfaceOrientation)orientation
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    
    NSLog(@"landscape...");
    if(![playContainerView_ isFullScreen])
    {
        //        [self hidePopView:nil];
        [UIView animateWithDuration:0.35 animations:^(void)
         {
             self.view.transform = CGAffineTransformIdentity;
             
             //        if(!UIInterfaceOrientationIsLandscape(orientation))
             //        {
             CGFloat width = config_.Height;
             CGFloat height = config_.Width;
             
             if(currentMtv_.IsLandscape)
             {
                 if(orientation == UIInterfaceOrientationLandscapeLeft)
                 {
                     self.view.transform = CGAffineTransformMakeRotation(0 - M_PI_2);
                 }
                 else
                     self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
                 //        }
                 
                 self.view.bounds = CGRectMake(0.0, 0.0, config_.Height,config_.Width);
             }
             else
             {
                 width = config_.Width;
                 height = config_.Height;
             }
             playFrameForPortrait_ = playContainerView_.frame;
//             [playContainerView_ resizeViews:CGRectMake(0, 0,width , height )];
             [playContainerView_ doFullScreen:CGRectMake(0, 0,width , height )];
             NSLog(@"player frame:%@",NSStringFromCGRect(playContainerView_.frame));
         }];
    }
    else
    {
        if(currentMtv_.IsLandscape)
        {
            [UIView animateWithDuration:0.35 animations:^(void)
             {
                 if(orientation == UIInterfaceOrientationLandscapeLeft)
                     self.view.transform = CGAffineTransformMakeRotation(0 - M_PI_2);
                 else
                     self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
                 self.view.bounds = CGRectMake(0.0, 0.0, config_.Height,config_.Width);
             }];
        }
    }
}
- (void)cancelFullScreen:(UIInterfaceOrientation)orientation
{
    //    if ([[HWindowStack shareObject] getLastVc] == self) {
    //        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    //    }
    if([playContainerView_ isFullScreen])
    {
        [UIView animateWithDuration:0.35 animations:^(void)
         {
             self.view.transform = CGAffineTransformIdentity;
             self.view.bounds = CGRectMake(0.0, 0.0, config_.Width,config_.Height);
             
             [playContainerView_ cancelFullScreen:playFrameForPortrait_];
//             [playContainerView_ resizeViews:playFrameForPortrait_];
         }];
        [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
    }
}
- (void)didRecordStarted:(NSNotification *)noti
{
    if([NSThread isMainThread])
    {
        //        recordReminderView_.hidden = NO;
        //        recordReminderView_.isCancelMode = NO;
        //        [recordReminderView_ startRefreshVolume];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self didRecordStarted:noti];
                       });
    }
}

- (void)didRecordStopped:(NSNotification *)noti
{
    if([NSThread isMainThread])
    {
        //        recordReminderView_.hidden = YES;
        //        [recordReminderView_ stopRefreshVolume];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self didRecordStopped:noti];
                       });
    }
}
- (void)didRecordMeterChanged:(NSNotification *)noti
{
    double meter = [[noti.userInfo objectForKey:@"meters"] doubleValue];
    //    [recordReminderView_ setCurrentMeter:(CGFloat)meter];
}
//- NT_RECORDMETERCHANGED

- (void)didCancelStatusChanged:(NSNotification *)noti
{
    //    recordReminderView_.isCancelMode = [[noti.userInfo objectForKey:@"cancelSend"] boolValue];
}

- (void)didIWantSing:(NSNotification *)noti
{
    //    if (playOrPause_.selected) {
    //        [self tempPlayPauseBtnClick:nil];
    //    }
    //    [self pauseItem:nil];
    //    [self removePlayerInThread];
}
//-(void)clickEditButton:(id)sender
//{
//    [self hideRightMenu:nil];
//    if (currentMtv_.UserID != userInfo_.UserID) return;
//    if(isGoing_) return;
//    isGoing_ = YES;
//
//    [self clearAndResetManager];
//
//    if(![self prepareForEditor:NO])
//    {
//        isGoing_ = NO;
//        return;
//    }
//
//    [self readyToRelease];
//
//    [[NSNotificationCenter defaultCenter] postNotificationName:NT_EDITVIDEO object:nil];
//
//    isGoing_ = NO;
//}

- (void)didBeginPlayAudio:(NSNotification *)noti
{
    //    needPlayAfterPause_ = mplayer_.playing;
    //    if (needPlayAfterPause_) {
    //        [self pauseItem:nil];
    //    }
}

- (void)didEndPlayAudio:(NSNotification *)noti
{
    //    if (needPlayAfterPause_) {
    //        [self playItem:nil seconds:-1];
    //    }
}

//#pragma mark - PanGestureRecognizer
//- (void)addPanGestureRecognizer
//{
////    MLNavigationController * nav = (MLNavigationController *)(self.navigationController);
////    nav.canDragBack = NO;
//
//    if (!panRecognizer_) {
//        panRecognizer_ = [[UIPanGestureRecognizer alloc]initWithTarget:self
//                                                                action:@selector(paningGestureReceive:)];
//        panRecognizer_.delaysTouchesBegan = NO;
//        panRecognizer_.delaysTouchesEnded = NO;
//        panRecognizer_.cancelsTouchesInView = NO;
//    }
//    [self.view addGestureRecognizer:panRecognizer_];
//}
//- (void)removePanGestureRecognizer
//{
//    if(panRecognizer_)
//    {
//        [self.view removeGestureRecognizer:panRecognizer_];
//        panRecognizer_ = nil;
//    }
//
////    MLNavigationController * nav = (MLNavigationController *)(self.navigationController);
////    nav.canDragBack = YES;
//}


#pragma mark - readyToRelease
- (void)returnToParent:(id)sender
{
    [playContainerView_ endBackgroundTask];
    [self readyToRelease];
    //    [super returnToParent:sender];
}
- (void)readyToRelease
{
    //避免卡住UI
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        [[AudioCenter shareAudioCenter] stopAudioController];
    ////        [[AudioCenter shareAudioCenter] setAudioSessionForPlayBack];
    //    });
    
    //    [mediaEditManager_ setCacheDataBetweenWindows:nil sample:nil];
    //    [MediaEditManager shareObject].CurrentMTV = nil;
    //    [MediaEditManager shareObject].CurrentSample = nil;
    
    [playContainerView_ clearPlayBackinfo];
    //    [[UIApplication sharedApplication]endReceivingRemoteControlEvents];
    //    [self resignFirstResponder];
    
    _instanceDetailItem = nil;
    
    [self stopCacheMTV:nil];
    [playContainerView_ pause];
    [playContainerView_ readyToRelease];
    ////    if (mplayer_) {
    ////        [self removePlayerInThread];
    ////    }
    ////    if(leaderPlayer_)
    ////    {
    ////        [leaderPlayer_ stop];
    ////        leaderPlayer_ = nil;
    ////    }
    ////    [progressView_ readyToRelease];
    ////    [playPannel_ readyToRelease];
    ////
    //    if(commentManager_)
    //    {
    //        [commentManager_ stopCommentTimer];
    //        [commentManager_ readyToRelease];
    //        commentManager_ = nil;
    //    }
    //    [super readyToRelease];
}
- (void)dealloc
{
    NSLog(@"music detail deallocated.");
    [self readyToRelease];
    PP_SUPERDEALLOC;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - alertview
//- (void)snAlertView:(SNAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if(alertView.tag==3001)
//    {
//        if(buttonIndex ==alertView.cancelButtonIndex){
//            //        [[UIApplication sharedApplication] openURL:
//            //         [NSURL URLWithString:UIApplicationOpenSettingsURLString]];
//            //            prefs:root=WIFI
//            //            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
//            //            [self setup:nil];
//            //下次再出现，还需要提醒
//            [[UserManager sharedUserManager] enableNotickeFor3G];
//            [UserManager sharedUserManager].currentSettings.DownloadVia3G = NO;
//            [self stopCacheMTV:nil];
//            [self pauseItem:nil];
//            [self hidePlayerWaitingView];
//        }else{
//
//            //30分钟内不再提示
//            [UserManager sharedUserManager].currentSettings.DownloadVia3G = YES;
//            [[UserManager sharedUserManager] disableNotickeFor3G];
//
//            [self playItem:nil seconds:-1];
//        }
//    }
//    //    else if(alertView.tag==1001 && buttonIndex != alertView.cancelButtonIndex)
//    //    {
//    //
//    //    }
//    //    else if(alertView.tag==1002 && buttonIndex != alertView.cancelButtonIndex)
//    //    {
//    //
//    //    }
//
//}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag==4001 && actionSheet.cancelButtonIndex != buttonIndex)
    {
        UIActionSheet * act = [[UIActionSheet alloc]initWithTitle:@"请选择举报的理由"
                                                         delegate:self
                                                cancelButtonTitle:EDIT_CANCEL
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:REPORTREASON, nil];
        act.tag = 4002;
        [act showInView:self.view];
    }
    else if(actionSheet.tag==4002 && actionSheet.cancelButtonIndex != buttonIndex)
    {
        NSArray * reasonList = [[UserManager sharedUserManager]getReportReasonList];
        if(buttonIndex >=0 && buttonIndex <reasonList.count)
        {
            NSString * reason = [reasonList objectAtIndex:buttonIndex];
            [self doReport:0 reason:reason];
        }
        else
        {
            [self doReport:0 reason:@"Unkown"];
        }
    }
}
- (void)reportMtv:(id)sender
{
    //    NSString * msg = [NSString stringWithFormat:@"您确认要举报此内容吗？",otherUserInfo_.NickName?otherUserInfo_.NickName:@""];
    //    SNAlertView * alertView = [[SNAlertView alloc]initWithTitle:@"提示信息"
    //                                                        message:msg
    //                                                       delegate:self
    //                                              cancelButtonTitle:EDIT_CANCEL
    //                                              otherButtonTitles:EDIT_OK,nil];
    //    alertView.tag = 1001;
    //    [alertView show];
    //    alertView = nil;
    //    ReportContentVC * vc = [[ReportContentVC alloc]initWithNibName:nil bundle:nil];
    //    vc.mtvItem = [self getCurrentMTV];
    //    [self.navigationController pushViewController:vc animated:YES];
    //    vc = nil;
    //    NSArray * reasonList = [[UserManager sharedUserManager]getReportReasonList];
    UIActionSheet * act = [[UIActionSheet alloc]initWithTitle:@"您确定要举报该内容吗？"
                                                     delegate:self
                                            cancelButtonTitle:EDIT_CANCEL
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:EDIT_OK, nil];
    act.tag = 4001;
    [act showInView:self.view];
}
- (void)doReport:(int)type reason:(NSString *)reason
{
    ReportInfo * ri = [ReportInfo new];
    //    if(type==1)
    //    {
    //        ri.ObjectType = (int)HCObjectTypeComment;
    //        ri.ObjectID = self.commentItem.QAID;
    //        ri.UrlString = @"";
    //        ri.TargetNickName = self.commentItem.UserName;
    //        ri.TargetUserID = self.commentItem.UserID;
    //    }
    //    else
    //    {
    //    MTV * mtv = [self getCurrentMTV];
    //    ri.ObjectType = (int)HCObjectTypeMTV;
    //    ri.ObjectID = mtv.MTVID;
    //    ri.UrlString = mtv.DownloadUrl;
    //    ri.TargetNickName = mtv.Author;
    //    ri.TargetUserID = mtv.UserID;
    //    //    }
    //    ri.NickName = [UserManager sharedUserManager].currentUser.NickName;
    //    ri.UserID = [UserManager sharedUserManager].currentUser.UserID;
    //    ri.ReportReason = reason;
    //    //    int tag = (int)reasonIndicator_.tag +1000;
    //    //    if(tag >=3000)
    //    //    {
    //    //        UILabel * lbl = (UILabel *)[reasonView_ viewWithTag:tag];
    //    //        if(lbl)
    //    //        {
    //    //            ri.ReportReason = lbl.text;
    //    //        }
    //    //    }
    //    ri.Message = @"";//reasonMore_.text;
    //
    //    NSString * msg =  @"提交举报信息失败，请稍后重试!";
    //    CMD_CREATEN(cmd,ReportItem);
    //    cmd.data = ri;
    //    cmd.CMDCallBack = ^(HCCallbackResult * result)
    //    {
    //        if(result.Code==0)
    //        {
    //            //            [self returnToParent:nil];
    //        }
    //        else
    //        {
    //            NSString * newMsg = msg;
    //            if(result.Msg && result.Msg.length>0)
    //            {
    //                newMsg = [NSString stringWithFormat:@"%@\n%@",msg,result.Msg];
    //            }
    //            SNAlertView * alertView = [[SNAlertView alloc]initWithTitle:MSG_ERROR
    //                                                                message:newMsg
    //                                                               delegate:nil
    //                                                      cancelButtonTitle:EDIT_OK
    //                                                      otherButtonTitles:nil];
    //            [alertView show];
    //            alertView = nil;
    //        }
    //    };
    //    if(![cmd sendCMD])
    //    {
    //        SNAlertView * alertView = [[SNAlertView alloc]initWithTitle:MSG_ERROR message:msg delegate:nil cancelButtonTitle:EDIT_OK otherButtonTitles:nil];
    //        [alertView show];
    //        alertView = nil;
    //    }
}
//#pragma mark - pan moving
//- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer
//{
//    if(![progressView_ isFullScreen]) return;
//    isCanMove_ = YES;
//
//    CGPoint touchPoint = [recoginzer locationInView:self.view];
//    if(isCanMove_)
//    {
//        [self moveWithPan:touchPoint state:recoginzer.state];
//    }
//}
//
//- (void)moveWithPan:(CGPoint)point  state:(UIGestureRecognizerState)state
//{
//    CGPoint touchPoint = point;// [recoginzer locationInView:KEY_WINDOW];
//
//    if (state == UIGestureRecognizerStateBegan)
//    {
//        [self beginMoving:point];
//    }
//    else if (state == UIGestureRecognizerStateEnded){
//        [self moveDone:point];
//        return;
//        // cancal panning, alway move to left side automatically
//    }else if (state == UIGestureRecognizerStateCancelled){
//        return;
//    }
//
//    if (isMoving_ && objectMovingID_>=0) {
//        [self moveTrackObjectInView:touchPoint viewID:objectMovingID_];
//    }
//    else if(!isMoving_ && objectMovingID_<0)
//    {
//        NSInteger currentTag = [self locationViewMoving:point];
//        if(currentTag>0)
//        {
//            [self beginMoving:point];
//        }
//    }
//}
//- (void)    beginMoving:(CGPoint)point
//{
//    objectMovingID_ = [self locationViewMoving:point];
//    if(objectMovingID_<0)
//    {
//        isMoving_ = NO;
//        return;
//    }
//
//    NSLog(@"begin move...");
//
//    if(mplayer_ && mplayer_.playing)
//    {
//        needPlaying_ = YES;
//        [self pauseItem:nil];
//    }
//    else
//    {
//        needPlaying_ = NO;
//    }
//
//    touchPointStart_ = point;
//    if(objectMovingID_ == TAG_SCROLLRECT)
//    {
//        lastSecondsBeMoving_ = CMTimeGetSeconds([mplayer_ durationWhen]);
//    }
//
//    isMoving_ = YES;
//}
//- (void)moveDone:(CGPoint)point
//{
//    if(!isMoving_) return;
//    NSLog(@"-----------move done---%d------",objectMovingID_);
//    if(objectMovingID_ == TAG_SCROLLRECT)
//    {
//        objectMovingID_ = -1;
//        isMoving_ = NO;
//        if(needPlaying_)
//        {
//            [self playItem:nil seconds:-1];
//        }
//        return;
//    }
//}
//- (void)    moveTrackObjectInView:(CGPoint)touchPoint viewID:(NSInteger)objectMovedTagID
//{
//    if(isMoving_==NO) return;
//
//    if(objectMovedTagID == TAG_SCROLLRECT)
//    {
//        CGFloat targetPosx = touchPoint.x - touchPointStart_.x;
//        CGFloat progressLength = [progressView_ getProgressWidth];
//        if(progressLength <=0) return;
//        CGFloat seconds = targetPosx / progressLength * [progressView_ totalSeconds];
//        [mplayer_ seek:seconds + lastSecondsBeMoving_ accurate:YES];
//
//        // refresh comment
//        CGFloat commentSeconds = seconds + lastSecondsBeMoving_;
//        if(commentSeconds < 0) commentSeconds = 0;
//        else if(commentSeconds >= mplayer_.getSecondsEnd) commentSeconds = 0;
//        if (mplayer_) {
//            [mplayer_ refreshCommentsView:commentSeconds];
//        }
//    }
//}
//- (NSInteger)locationViewMoving:(CGPoint)point
//{
//    CGRect scrollRect = CGRectMake(0, 40, config_.Height, config_.Width - 120);
//    if (!currentMtv_.IsLandscape) {
//        scrollRect = CGRectMake(0, 40, config_.Width, config_.Height - 80);
//    }
//
//    if(CGRectContainsPoint(scrollRect, point))
//    {
//        return TAG_SCROLLRECT;
//    }
//    return -1;
//}
@end
