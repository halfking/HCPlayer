//
//  WTRecordTopPannel.m
//  maiba
//
//  Created by HUANGXUTAO on 16/3/31.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import "WTRecordTopPannel.h"
#import <HCBaseSystem/SevenSwitch.h>
#import <HCBaseSystem/UpDown.h>
#import <HCBaseSystem/VDCItem.h>
#import <HCBaseSystem/User_WT.h>
#import <HCBaseSystem/SNAlertView.h>
#import <HCMVManager/MTV.h>
#import <HCMVManager/MTVUploader.h>
#import <HCMVManager/vdcManager_full.h>
#import <hccoren/UIView+extension.h>
#import <HCAudioUnit/AudioCenterNew.h>
#import "WTVideoPlayerProgressView.h"

#import "WTRecordTopPannel(Upload).h"
#import "player_config.h"

@implementation WTRecordTopPannel
@synthesize delegate = delegate_;
//,progressDelegate;
@synthesize MTVItem = mtvItem_;
@synthesize SampleItem = sampleItem_;
@synthesize localVDCItem = localVdcItem_;
@synthesize canShowSpeed = canShowSpeed_;
@synthesize needShowProgress = needShowProgress_;
//@synthesize rightMenuContainer = rightMenuContainer_;

- (void)setDefaultSets
{
    recordMode_ = 0;
    isStoppedUploadAuto_ = NO;
    isStoppedDownloadAuto_ = NO;
    isCaching_ = NO;
    isUploading_ = NO;
    lastRecordTime_ = 0;
    needRefresh_ = YES;
    [self setButtonsShowWithStatus:0];
}
- (void)setButtonsShowWithStatus:(int)status //0 not begin /1 recording /2 pause /3 completed /4 preview
{
    if(status==0)
    {
        self.showTitle = YES;
        self.showBackBtn = YES;
        self.showCacheBtn = YES;
        self.showResingBtn = NO;
        self.showPreviewBtn = NO;
        self.showUploadBtn = NO;
        self.showRecordTimePannel = NO;
        self.showCancelPreviewBtn = NO;
        self.showCompletedBtn = NO;
    }
    else if(status==1)
    {
        self.showTitle = NO;
        self.showBackBtn = NO;
        self.showCacheBtn = NO;
        self.showResingBtn = NO;
        self.showPreviewBtn = NO;
        self.showUploadBtn = NO;
        self.showRecordTimePannel = YES;
        self.showCancelPreviewBtn = NO;
        self.showCompletedBtn = NO;
    }
    else if(status==2)
    {
        self.showTitle = YES;
        self.showBackBtn = YES;
        self.showCacheBtn = NO;
        self.showResingBtn = YES;
        self.showPreviewBtn = YES;
        self.showUploadBtn = NO;
        self.showRecordTimePannel = NO;
        self.showCancelPreviewBtn = NO;
        self.showCompletedBtn = NO;
    }
    else if(status ==3)
    {
        self.showTitle = YES;
        self.showBackBtn = YES;
        self.showCacheBtn = NO;
        self.showResingBtn = YES;
        self.showPreviewBtn = YES;
        self.showUploadBtn = YES;
        self.showRecordTimePannel = NO;
        self.showCancelPreviewBtn = NO;
        self.showCompletedBtn = NO;
    }
    else if(status==4)
    {
        self.showTitle = NO;
        self.showBackBtn = NO;
        self.showCacheBtn = NO;
        self.showResingBtn = YES;
        self.showPreviewBtn = NO;
        self.showUploadBtn = NO;
        self.showRecordTimePannel = NO;
        self.showCancelPreviewBtn = YES;
        self.showCompletedBtn = NO;
    }
    else if(status==5)
    {
        self.showTitle = YES;
        self.showBackBtn = YES;
        self.showCacheBtn = NO;
        self.showResingBtn = NO;
        self.showPreviewBtn = NO;
        self.showUploadBtn = NO;
        self.showRecordTimePannel = NO;
        self.showCancelPreviewBtn = NO;
        self.showCompletedBtn = YES;
    }
    else
    {
        self.showTitle = YES;
        self.showBackBtn = YES;
        self.showCacheBtn = NO;
        self.showResingBtn = NO;
        self.showPreviewBtn = NO;
        self.showUploadBtn = NO;
        self.showRecordTimePannel = NO;
        self.showCancelPreviewBtn = NO;
        self.showCompletedBtn = NO;
    }
}
- (id)init
{
    if(self = [super init])
    {
        isBuild_ = NO;
        [self setDefaultSets];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        isBuild_ = NO;
        [self setDefaultSets];
        if(!isBuild_)
        {
            [self buildViews:frame];
        }
        else
        {
            [self changeFrame:frame];
        }
    }
    return self;
}
- (instancetype)initWithPara:(CGRect)frame recordMode:(BOOL)recordMode
{
    if(self = [self initWithFrame:frame])
    {
        [self setPannelMode:recordMode];
    }
    return self;
}
- (void)setSingCompletedMode
{
    [self setPannelMode:5];
}
- (void)setPannelMode:(int)recordMode //0 not begin ,   1 recording, 2 pause,  3 completed,  4 preview,  5 completed, 6 hide buttons
{
    if(recordMode_==recordMode && !needRefresh_) return;
    needRefresh_ = NO;
    recordMode_ = recordMode;
    
    if(recordMode_ == 0)
    {
        [self setDefaultSets];
    }
    else
    {
        [self setButtonsShowWithStatus:recordMode];
    }
    //审核时不能出现缓存按钮
    if([UserManager sharedUserManager].isForReivew||(localVdcItem_ && localVdcItem_.downloadBytes> localVdcItem_.contentLength && localVdcItem_.contentLength>0) || recordMode_!=0)
    {
        self.showCacheBtn = NO;
    }
    else
    {
        self.showCacheBtn = YES;
    }
    if(recordMode==1)
    {
        self.showRecordTimePannel = YES;
    }
    else
    {
        self.showRecordTimePannel = NO;
        lastRecordTime_ = 0;
    }
    if(!isBuild_)
        [self buildViews:self.frame];
    else
        [self changeFrame:self.frame];
    
    if(recordMode==1)
    {
        if (redDotTimer_) {
            [redDotTimer_ invalidate];
            redDotTimer_ = nil;
        }
        redDotTimer_ = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(redDotAnimate:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:redDotTimer_ forMode:NSRunLoopCommonModes];
        [self bringSubviewToFront:redDot_];
        [self bringSubviewToFront:playProgress_];
    }
    else
    {
        if(redDotTimer_)
        {
            [redDotTimer_ invalidate];
            redDotTimer_ = nil;
        }
    }
    if(recordMode==1) //when recording,check headset status
    {
        if ([[AudioCenterNew shareAudioCenter]isUseBuildinSpeaker]) {
            [self showUseHeadsetNotice];
        }
        else
        {
            [self hideUseHeadsetNotice];
        }
    }
    else
    {
        [self hideUseHeadsetNotice];
    }
}
- (void)changeFrame:(CGRect)frame
{
    CGFloat left = 5;
    CGFloat top = 5;
    CGFloat right = 0;
    CGFloat width = frame.size.width;
    CGFloat titleWidth = 0;
    CGFloat titleTop = 0;
    
    bgView_.frame = CGRectMake(0, 0, width, frame.size.height);
    gradientLayer_.frame = bgView_.bounds;
    
    if(returnBtn_)
    {
        returnBtn_.frame = CGRectMake(left, top, 40, 40);
        returnBtn_.hidden = !self.showBackBtn;
    }
    if(cancelPreivewBtn_)
    {
        cancelPreivewBtn_.frame = CGRectMake(left, top+5, 45, 30);
        cancelPreivewBtn_.hidden = !self.showCancelPreviewBtn;
    }
    
    right = width - 45 - 15;
    
    if(completedBtn_)
    {
        completedBtn_.frame = CGRectMake(right, top+5, 45, 30);
        completedBtn_.hidden = !self.showCompletedBtn;
        if(self.showCompletedBtn)
            right -= 45;
    }
    if(resingBtn_)
    {
        resingBtn_.frame = CGRectMake(right, top+5, 45, 30);
        resingBtn_.hidden = !self.showResingBtn;
        if(self.showResingBtn)
            right -= 45;
    }
    if(previewBtn_)
    {
        previewBtn_.frame  = CGRectMake(right, top+5, 45, 30);
        previewBtn_.hidden = !self.showPreviewBtn;
    }
    
    if(redDot_){
        UIFont * font = FONT_STANDARD(13);
        NSString * text = @"00:00/00:00 ";
        CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName:font}];
        CGFloat left = (width - textSize.width)/2.0f;
        titleTop = (self.frame.size.height - textSize.height)/2.0f-1;
        
        redDot_.frame = CGRectMake(left, (self.frame.size.height -6)/2.0f, 6, 6);
        redDot_.hidden = !self.showRecordTimePannel;
        
        left += 10;
        
        playProgress_.frame = CGRectMake(left, titleTop, textSize.width+2, textSize.height+2);
        playProgress_.hidden = !self.showRecordTimePannel;
        
        titleWidth = left - 45;
    }
    //审核时不能出现缓存按钮
    //    if(![UserManager sharedUserManager].isForReivew)
    //    {
    //        [self showCacheStatus:0 hidden:0 percent:0 animates:NO];
    //    }
    
    if(title_)
    {
        title_.frame = CGRectMake(45, titleTop, titleWidth,frame.size.height - titleTop * 2);
        title_.hidden = !self.showTitle;
        title_.text = mtvItem_.Title?mtvItem_.Title:sampleItem_.Title;
    }
    
    if(cacheContainer_)
    {
        cacheContainer_.hidden = !self.showCacheBtn;
    }
}
- (void)buildViews:(CGRect)frame
{
    CGFloat left = 5;
    CGFloat top = 5;
    CGFloat right = 0;
    CGFloat width = frame.size.width;
    CGFloat titleWidth = 0;
    CGFloat titleTop = 0;
    
    //    if(!bgView_){
    //        bgView_ = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, frame.size.height)];
    //        //        bgView_.backgroundColor = [UIColor yellowColor];
    //        bgView_.backgroundColor =   COLOR_CF;
    //        bgView_.alpha = 0.4;
    //        [self addSubview:bgView_];
    //
    //        gradientLayer_ = [self buildVerticalGradientLayer:NO];
    //        gradientLayer_.frame = bgView_.bounds;
    //        [bgView_.layer addSublayer:gradientLayer_];
    //    }
    //    else
    //    {
    //        bgView_.frame = CGRectMake(0, 0, width, frame.size.height);
    //        gradientLayer_.frame = bgView_.bounds;
    //    }
    
    if(!returnBtn_)
    {
        returnBtn_  = [[UIButton alloc] initWithFrame:CGRectMake(left, top, 40, 40)];
        [returnBtn_ setImage:[UIImage imageNamed:@"return.png"] forState:UIControlStateNormal];
        //        [setupButton_ setImage:[UIImage imageNamed:@"return.png"] forState:UIControlStateSelected];
        [returnBtn_ addTarget:self action:@selector(returnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:returnBtn_];
        returnBtn_.hidden = !self.showBackBtn;
    }
    else
    {
        returnBtn_.hidden = !self.showBackBtn;
    }
    if(!cancelPreivewBtn_)
    {
        cancelPreivewBtn_  = [[UIButton alloc] initWithFrame:CGRectMake(left, top+5, 45, 30)];
        [cancelPreivewBtn_ setImage:[UIImage imageNamed:@"get_back.png"] forState:UIControlStateNormal];
        //        [setupButton_ setImage:[UIImage imageNamed:@"return.png"] forState:UIControlStateSelected];
        [cancelPreivewBtn_ addTarget:self action:@selector(cancelPreviewClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:cancelPreivewBtn_];
        cancelPreivewBtn_.hidden = !self.showCancelPreviewBtn;
    }
    else
    {
        cancelPreivewBtn_.hidden = !self.showCancelPreviewBtn;
    }
    
    right = width - 45 - 15;
    if(!completedBtn_)
    {
        completedBtn_  = [[UIButton alloc] initWithFrame:CGRectMake(right, top, 45, 30)];
        [completedBtn_ setImage:[UIImage imageNamed:@"next.png"] forState:UIControlStateNormal];
        //        [setupButton_ setImage:[UIImage imageNamed:@"return.png"] forState:UIControlStateSelected];
        [completedBtn_ addTarget:self action:@selector(completedClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:completedBtn_];
        completedBtn_.hidden = !self.showCompletedBtn;
        if(self.showCompletedBtn)
            right -= 45;
    }
    else
    {
        completedBtn_.hidden = !self.showCompletedBtn;
        if(self.showCompletedBtn)
            right -= 45;
    }
    if(!resingBtn_)
    {
        resingBtn_  = [[UIButton alloc] initWithFrame:CGRectMake(right, top, 45, 30)];
        [resingBtn_ setImage:[UIImage imageNamed:@"repeat.png"] forState:UIControlStateNormal];
        //        [setupButton_ setImage:[UIImage imageNamed:@"return.png"] forState:UIControlStateSelected];
        [resingBtn_ addTarget:self action:@selector(resingClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:resingBtn_];
        resingBtn_.hidden = !self.showResingBtn;
        if(self.showResingBtn)
            right -= 45;
    }
    else
    {
        resingBtn_.hidden = !self.showResingBtn;
        if(self.showResingBtn)
            right -= 45;
    }
    if(!previewBtn_)
    {
        previewBtn_  = [[UIButton alloc] initWithFrame:CGRectMake(right, top, 45, 30)];
        [previewBtn_ setImage:[UIImage imageNamed:@"audition.png"] forState:UIControlStateNormal];
        //        [setupButton_ setImage:[UIImage imageNamed:@"return.png"] forState:UIControlStateSelected];
        [previewBtn_ addTarget:self action:@selector(previewClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:previewBtn_];
        previewBtn_.hidden = !self.showPreviewBtn;
    }
    else
    {
        previewBtn_.hidden = !self.showPreviewBtn;
    }
    
    if(!redDot_){
        UIFont * font = FONT_STANDARD(13);
        NSString * text = @"00:00/00:00 ";
        CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName:font}];
        CGFloat left = (width - textSize.width)/2.0f;
        titleTop = (self.frame.size.height - textSize.height)/2.0f-1;
        
        redDot_ = [[UIView alloc] initWithFrame:CGRectMake(left, (self.frame.size.height -6)/2.0f, 6, 6)];
        redDot_.backgroundColor = COLOR_BO;
        redDot_.layer.cornerRadius = 3;
        redDot_.hidden = !self.showRecordTimePannel;
        [self addSubview:redDot_];
        
        left += 10;
        
        playProgress_ = [[UILabel alloc] initWithFrame:CGRectMake(left, titleTop, textSize.width+2, textSize.height)];
        playProgress_.font = font;
        playProgress_.shadowColor = COLOR_SHADOW;
        playProgress_.shadowOffset = SHADOW_SIZE;
        playProgress_.textAlignment = NSTextAlignmentLeft;
        playProgress_.textColor = [UIColor whiteColor];
        playProgress_.text = text;
        playProgress_.hidden = !self.showRecordTimePannel;
        [self addSubview:playProgress_];
        
        titleWidth = left - 50;
    }
    else
    {
        titleWidth = playProgress_.frame.origin.x - 50;
        titleTop = playProgress_.frame.origin.y;
        redDot_.hidden = !self.showRecordTimePannel;
        playProgress_.hidden = !self.showRecordTimePannel;
    }
    if(!title_)
    {
        title_ = [[UILabel alloc] initWithFrame:CGRectMake(45, titleTop, titleWidth,frame.size.height - titleTop * 2)];
        title_.font =  FONT_STANDARD(13);
        title_.shadowColor = COLOR_SHADOW;
        title_.shadowOffset = SHADOW_SIZE;
        title_.textAlignment = NSTextAlignmentLeft;
        title_.textColor = [UIColor whiteColor];
        title_.hidden = !self.showTitle;
        title_.text = mtvItem_.Title?mtvItem_.Title:sampleItem_.Title;
        [self addSubview:title_];
    }
    else
    {
        title_.hidden = !self.showTitle;
        title_.text = mtvItem_.Title?mtvItem_.Title:sampleItem_.Title;
    }
    [self showCacheStatus:0 hidden:0 percent:0 animates:NO];
    isBuild_ = YES;
}
#pragma mark - event
- (void)completedClick:(id)sender
{
    BOOL ret = YES;
    if(self.delegate && [self.delegate respondsToSelector:@selector(recordPannel:singCompleted:)])
    {
        ret = [self.delegate recordPannel:self singCompleted:YES];
    }
    //    if(ret)
    //    {
    //        [self setPannelMode:5];
    //    }
}
- (void)previewClick:(id)sender
{
    BOOL ret = YES;
    if(self.delegate && [self.delegate respondsToSelector:@selector(recordPannel:preview:)])
    {
        ret = [self.delegate recordPannel:self preview:YES];
    }
    if(ret)
    {
        [self setPannelMode:4];
    }
}
- (void)cancelPreviewClick:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(recordPannel:cancelPreview:)])
    {
        [self.delegate recordPannel:self cancelPreview:YES];
    }
}
- (void)returnClick:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(recordPannel:back:)])
    {
        [self.delegate recordPannel:self back:YES];
    }
}
- (void)resingClick:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(recordPannel:resingMtv:)])
    {
        [self.delegate recordPannel:self resingMtv:YES];
    }
}

#pragma mark - cache
- (void)setLocalVDCItem:(VDCItem *)item
{
    if(localVdcItem_!=item)
    {
        localVdcItem_ = item;
        if(isBuild_)
        {
            [self setPannelMode:recordMode_];
            [self changeFrame:self.frame];
        }
    }
}
- (void)stopCacheMTV//:(NSString *)url
{
    [[VDCManager shareObject] stopDownload:nil];
    
}
- (void)showCachingStatus:(NSNotification*)notification
{
    if(!notification.userInfo) return;
    if(!canShowSpeed_)
    {
        if(speedDescLabel_ && !speedDescLabel_.hidden) speedDescLabel_.hidden = YES;
        if(speedLabel_ && !speedLabel_.hidden ) speedLabel_.hidden = YES;
        [self setPannelMode:recordMode_];
        return;
    }
    else
    {
        self.showUploadBtn = NO;
        self.showRecordTimePannel = NO;
        [self changeFrame:self.frame];
    }
    CGFloat left = (self.frame.size.width - 100)/2.0f;
    CGFloat top = (self.frame.size.height - 30) / 2.0f;
    
    CGFloat downloadSpeed = [[notification.userInfo objectForKey:@"speed"]floatValue];
    NSString * downloadFile = [notification.userInfo objectForKey:@"file"];
    
    //    NSLog(@"speed:%.1f file:%@",downloadSpeed,downloadFile);
    if(!speedLabel_)
    {
        speedLabel_ = [[UILabel alloc]initWithFrame:CGRectMake(left, top, 100, 12)];
        speedLabel_.font = FONT_STANDARD(11);
        speedLabel_.backgroundColor = [UIColor clearColor];
        speedLabel_.textColor = [UIColor whiteColor];
        speedLabel_.textAlignment = NSTextAlignmentCenter;
        speedLabel_.shadowColor = [UIColor darkGrayColor];
        speedLabel_.shadowOffset = CGSizeMake(1, 1);
        speedLabel_.alpha = 0.8;
        [self addSubview:speedLabel_];
    }
    else if(speedLabel_.hidden)
    {
        speedLabel_.hidden = NO;
    }
    [self bringSubviewToFront:speedLabel_];
    
    if(!speedDescLabel_)
    {
        speedDescLabel_ = [[UILabel alloc]initWithFrame:CGRectMake(left, top + 15, 150, 12)];
        speedDescLabel_.font = FONT_STANDARD(11);
        speedDescLabel_.backgroundColor = [UIColor clearColor];
        speedDescLabel_.textColor = [UIColor whiteColor];
        speedDescLabel_.textAlignment = NSTextAlignmentRight;
        speedDescLabel_.shadowColor = [UIColor darkGrayColor];
        speedDescLabel_.shadowOffset = CGSizeMake(1, 1);
        speedDescLabel_.alpha = 0.8;
        [self addSubview:speedDescLabel_];
    }
    else if(speedDescLabel_.hidden)
    {
        speedDescLabel_.hidden = NO;
    }
    
    [self bringSubviewToFront:speedDescLabel_];
    
    if(downloadSpeed>=0)
    {
        speedLabel_.text = [NSString stringWithFormat:@"%.1fKB/S",downloadSpeed];
        if(downloadSpeed>=50)
        {
            speedDescLabel_.text = @"MV正在加载中";
        }
        else
        {
            speedDescLabel_.text = @"您当前的网络不稳定";
        }
    }
    else if((downloadSpeed>=-1.1 && downloadSpeed<=-0.9) || downloadSpeed==-4)
    {
        if(downloadFile && [speedDescLabel_.text isEqualToString:downloadFile]) return;
        
        speedDescLabel_.text = downloadFile;
        speedLabel_.text = @"";
        if(hideSpeedTimer_)
        {
            [hideSpeedTimer_ invalidate];
            hideSpeedTimer_ = nil;
        }
        hideSpeedTimer_ = [NSTimer scheduledTimerWithTimeInterval:2
                                                           target:self
                                                         selector:@selector(hideCachingStatus:)
                                                         userInfo:nil
                                                          repeats:NO];
    }
    else if(downloadSpeed>=-2.1 && downloadSpeed<=-1.9)
    {
        speedDescLabel_.text = downloadFile;
        if(hideSpeedTimer_)
        {
            [hideSpeedTimer_ invalidate];
            hideSpeedTimer_ = nil;
        }
        hideSpeedTimer_ = [NSTimer scheduledTimerWithTimeInterval:3
                                                           target:self
                                                         selector:@selector(hideCachingStatus:)
                                                         userInfo:nil
                                                          repeats:NO];
        
    }
    else
    {
        speedLabel_.text = @"";
        speedDescLabel_.text = @"";
    }
    
    if(progressView_ && progressView_.hidden==NO)
    {
        [self bringSubviewToFront:progressView_];
    }
}
- (void)hideCachingStatus:(NSTimer *)timer
{
    if(!speedLabel_ || speedLabel_.hidden) return;
    [timer invalidate];
    timer = nil;
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       [UIView animateWithDuration:0.3 animations:^(void)
                        {
                            speedLabel_.alpha =0;
                            speedDescLabel_.alpha = 0;
                        }completion:^(BOOL completed)
                        {
                            if(speedLabel_)
                            {
                                speedLabel_.hidden = YES;
                                speedLabel_.alpha = 0.8;
                            }
                            if(speedDescLabel_)
                            {
                                speedDescLabel_.hidden = YES;
                                speedDescLabel_.alpha = 0.8;
                            }
                            
                        }];
                   });
}
#pragma mark - ear notice
- (void)showUseHeadsetNotice
{
    if(!earPhoneRemindLabel_)
    {
        earPhoneRemindLabel_ = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - 300)/2, self.frame.size.height - 15, 300, 13)];
        earPhoneRemindLabel_.text = @"建议使用耳麦消除杂音";
        earPhoneRemindLabel_.textColor = [UIColor whiteColor];
        earPhoneRemindLabel_.alpha = 0.5;
        earPhoneRemindLabel_.font = [UIFont systemFontOfSize:12];
        earPhoneRemindLabel_.textAlignment = NSTextAlignmentCenter;
        earPhoneRemindLabel_.shadowOffset = SHADOW_SIZE;
        earPhoneRemindLabel_.shadowColor = COLOR_SHADOW;
        [self addSubview:earPhoneRemindLabel_];
        earPhoneRemindLabel_.hidden = YES;
    }
    earPhoneRemindLabel_.hidden = NO;
    [self bringSubviewToFront:earPhoneRemindLabel_];
}
- (void)hideUseHeadsetNotice
{
    earPhoneRemindLabel_.hidden = YES;
}

#pragma mark - record time
- (void)setCurrentTime:(CGFloat)seconds
{
    if(seconds < 0.15)
        return;
    if(fabs(seconds - lastRecordTime_) < 0.5) return;
    
    playProgress_.text = [NSString stringWithFormat:@"%@/%@",[CommonUtil getTimeStringOfTimeInterval:seconds],totalDurationString_];
    
    lastRecordTime_ = seconds;
}
- (void)setTotalDuration:(CGFloat)seconds
{
    if(seconds>0)
    {
        sampleItem_.Durance = seconds;
        totalDurationString_ = [CommonUtil getTimeStringOfTimeInterval:seconds];
    }
}
#pragma mark - cache2

- (void)changeCacheMTVState:(id)sender
{
    if(!localVdcItem_)
    {
        localVdcItem_ = [[VDCManager shareObject]getVDCItemByMtv:sampleItem_ urlString:nil];
    }
    if (localVdcItem_.isDownloading) {
        [self stopCacheMTV];
    }
    else{
        needShowProgress_ = YES;
        [self cacheMTV:localVdcItem_.remoteUrl isNoticed:NO];
    }
}

- (void)cacheMTV:(NSString *)url isNoticed:(BOOL)isNoticed
{
    NetworkStatus  status = [MTVUploader sharedMTVUploader].networkStatus;
    long userID = [UserManager sharedUserManager].userID;
    
    if(!isNoticed
       && status == ReachableViaWWAN
       &&  [[UserManager sharedUserManager]canShowNotickeFor3G])
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(recordPannel:cacheCheckNetwork:)])
        {
            [self.delegate recordPannel:self cacheCheckNetwork:YES];
        }
        return;
    }
    if(!url||url.length==0)
    {
        url = [mtvItem_ getDownloadUrlOpeated:status userID:userID];
    }
    
    VDCManager * vdcManager = [VDCManager shareObject];
    
    NSString * audioUrl = nil;
    //下载导唱的数据
    
    if([self currentItemIsSample] ||mtvItem_.UserID==userID)
    {
        audioUrl = mtvItem_.AudioRemoteUrl;
    }
    
    NSString *title = [NSString stringWithFormat:@"%@  (%@)",mtvItem_.Title,mtvItem_.Author];
    [vdcManager downloadUrl:url audioUrl:audioUrl title:title isAudio:NO urlReady:^(VDCItem * vdcItem,NSURL * videoUrl)
     {
         localVdcItem_ = vdcItem;
         if(localVdcItem_.contentLength>0)
         {
             [self showCacheStatus:1
                            hidden:0
                           percent:localVdcItem_.downloadBytes * 1.0/localVdcItem_.contentLength
                          animates:NO];
         }
         canShowSpeed_ = NO;
     }
                   progress:^(VDCItem *vdcItem) {
                       if (needShowProgress_) {
                           //                           NSLog(@"%llu / %llu",vdcItem.downloadBytes,vdcItem.contentLength);
                           [self setCacheButtonStateWithVDCItemInThread:vdcItem withAnimation:YES];
                       }
                   } completed:^(VDCItem *vdcItem, BOOL completed, VDCTempFileInfo *tempFile) {
                       if (completed) {
                           [self setCacheButtonStateWithVDCItemInThread:vdcItem withAnimation:YES];
                       }
                   }];
}

- (void)setCacheButtonStateWithVDCItem:(VDCItem *)item withAnimation:(BOOL)animate
{
    if([UserManager sharedUserManager].isForReivew) return;
    
    if (![NSThread mainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setCacheButtonStateWithVDCItemInThread:item withAnimation:animate];
        });
    }
    else{
        [self setCacheButtonStateWithVDCItemInThread:item withAnimation:animate];
    }
}

- (void)setCacheButtonStateWithVDCItemInThread:(VDCItem *)item withAnimation:(BOOL)animate
{
    float percent;
    if (item.contentLength == 0) {
        percent = 0;
    }
    else{
        percent = 100 * (float)item.downloadBytes / (float)item.contentLength;
    }
    if (percent >= 99.9) {
        [self showCacheStatus:2 hidden:-1 percent:percent animates:YES];
    }
    else{
        [self showCacheStatus:(int)item.isDownloading hidden:-1 percent:percent animates:NO];
    }
}

- (void)showCacheStatus:(int)isDownloading hidden:(int)isHidden percent:(CGFloat)percent animates:(BOOL)animates
{
    BOOL justBuild = NO;
    if(isDownloading>=0||isHidden>=0)
    {
        if(!cacheContainer_)
        {
            justBuild = YES;
            //            cacheContainer_ = [[UIView alloc] initWithFrame:CGRectMake(FULLSCREEN_WIDTH - 80, 10, 85, 30)];
            //            [self.view addSubview:cacheContainer_];
            CGRect frame = CGRectMake(self.frame.size.width - 80, 0, 85, 30);
            frame.origin.y = (self.frame.size.height - frame.size.height)/2.0f;
            cacheContainer_ = [[UIView alloc] initWithFrame:frame];
            //            cacheContainer_.backgroundColor = [UIColor yellowColor];
            [self addSubview:cacheContainer_];
            
            cacheIcon_ = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            cacheIcon_.image = [UIImage imageNamed:@"cache"];
            [cacheContainer_ addSubview:cacheIcon_];
            
            cacheProgressLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(35, 10, 45, 10)];
            cacheProgressLabel_.text = @"缓存";
            cacheProgressLabel_.font = [UIFont systemFontOfSize:12];
            cacheProgressLabel_.textColor = [UIColor whiteColor];
            cacheProgressLabel_.shadowOffset = SHADOW_SIZE;
            cacheProgressLabel_.shadowColor = COLOR_SHADOW;
            [cacheContainer_ addSubview:cacheProgressLabel_];
            
            cacheGesture_ = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeCacheMTVState:)];
            [cacheContainer_ addGestureRecognizer:cacheGesture_];
        }
    }
    if(isDownloading==0 && !justBuild)  //没有下载
    {
        cacheIcon_.image = [UIImage imageNamed:@"cache"];
        cacheProgressLabel_.text = @"缓存";
        cacheProgressLabel_.textColor = [UIColor whiteColor];
        cacheProgressLabel_.alpha = 1;
        cacheIcon_.alpha = 1;
        cacheGesture_.enabled = YES;
    }
    else if(isDownloading==1) //正在下载
    {
        cacheIcon_.image = [UIImage imageNamed:@"cacheing"];
        cacheProgressLabel_.textColor = COLOR_BA;
        if (percent>=0) {
            cacheProgressLabel_.text = [NSString stringWithFormat:@"%d%%", (int)percent];
        }
        cacheProgressLabel_.alpha = 1;
        cacheIcon_.alpha = 1;
        cacheGesture_.enabled = YES;
        
        //        if (percent <= 0.01 && !item.isDownloading) {
        //            cacheProgressLabel_.text = @"缓存";
        //        }
        //        else{
        //            cacheProgressLabel_.text = [NSString stringWithFormat:@"%d%%", (int)percent];
        //        }
        //        cacheProgressLabel_.alpha = 1;
        //        cacheIcon_.alpha = 1;
        //        cacheGesture_.enabled = YES;
        //        if (item.isDownloading) {
        //            cacheIcon_.image = [UIImage imageNamed:@"cacheing"];
        //            cacheProgressLabel_.textColor = COLOR_BA;
        //        }
        //        else{
        //            cacheIcon_.image = [UIImage imageNamed:@"cache"];
        //            cacheProgressLabel_.textColor = [UIColor whiteColor];
        //        }
        
    }
    else if(isDownloading==2) //下载完成
    {
        cacheProgressLabel_.text = @"已缓存";
        cacheProgressLabel_.textColor = [UIColor whiteColor];
        cacheGesture_.enabled = NO;
        cacheIcon_.image = [UIImage imageNamed:@"Cache_gray"];
        if (cacheProgressLabel_.alpha == 1 && animates) {
            cacheProgressLabel_.alpha = 0.5;
            [UIView animateWithDuration:0.5 animations:^{
                cacheProgressLabel_.alpha = 0;
                cacheIcon_.alpha = 0;
            }];
        }
        else{
            cacheProgressLabel_.alpha = 0;
            cacheIcon_.alpha = 0;
        }
    }
    if(isHidden==1)
    {
        if(!cacheContainer_.hidden)
            cacheContainer_.hidden = YES;
    }
    else if(isHidden==0)
    {
        if(cacheContainer_.hidden)
            cacheContainer_.hidden = NO;
    }
}
#pragma mark - data set get
- (BOOL)currentItemIsSample
{
    return!mtvItem_ ||  mtvItem_.MTVID == 0;
}
- (void)setCanShowSpeed:(BOOL)canShowSpeed
{
    canShowSpeed_ = canShowSpeed;
}
- (void)setMTVItem:(MTV *)MTVItem sample:(MTV *)sampleItem
{
    mtvItem_ = MTVItem;
    sampleItem_ = sampleItem;
    
    localVdcItem_  = [[VDCManager shareObject]getVDCItemByMtv:sampleItem_ urlString:nil];
    needRefresh_ = YES;
    if(isBuild_)
    {
        [self setPannelMode:recordMode_];
        if(recordMode_==0)
        {
            CGFloat percent = localVdcItem_.contentLength>0?localVdcItem_.downloadBytes * 1.0f/localVdcItem_.contentLength:0;
            [self showCacheStatus:localVdcItem_.isDownloading hidden:0 percent:percent animates:YES];
        }
    }
    if(sampleItem && sampleItem.Durance>0)
    {
        totalDurationString_ = [CommonUtil getTimeStringOfTimeInterval:sampleItem.Durance];
    }
    else
    {
        totalDurationString_ = @"--:--";
    }
    if(localVdcItem_.isDownloading)
    {
        if(![[UserManager sharedUserManager]isForReivew])
        {
            needShowProgress_ = YES;
        }
        __weak WTRecordTopPannel * weakSelf = self;
        localVdcItem_.progressCall = ^(VDCItem * item){
                [weakSelf setCacheButtonStateWithVDCItemInThread:item withAnimation:YES];
        };
        localVdcItem_.downloadedCall = ^(VDCItem * vdcItem,BOOL completed,VDCTempFileInfo * tempFile)
        {
            if (completed) {
                [weakSelf setCacheButtonStateWithVDCItemInThread:vdcItem withAnimation:YES];
            }
        };
    }
    else if(localVdcItem_.downloadBytes >= localVdcItem_.contentLength && localVdcItem_.contentLength>0)
    {
        [self showCacheStatus:2 hidden:1 percent:1 animates:NO];
    }
    
}
#pragma mark - dealloc
- (void)hideWithAnimates:(BOOL)animates
{
    if(!animates)
    {
        self.hidden = YES;
        //        [self hideRightMenu:nil animates:NO];
    }
    else
    {
        [UIView animateWithDuration:0.25 animations:^(void)
         {
             self.alpha = 0;
             //             [self hideRightMenu:nil animates:NO];
         }completion:^(BOOL finished)
         {
             self.hidden = YES;
             self.alpha = 1;
         }];
    }
}
- (BOOL)isRightMenuShow
{
    //    if (moreButton_.selected)
    //        return YES;
    //    else
    return NO;
}

- (void)willEnterbackground
{
    
    if(isCaching_)
    {
        isStoppedDownloadAuto_ = YES;
        [self stopCacheMTV];
        isCaching_ = NO;
    }
    if(isUploading_ && mtvItem_)
    {
        [[MTVUploader sharedMTVUploader]stopUploadMtv:mtvItem_];
        isStoppedUploadAuto_ = YES;
        isUploading_ = NO;
    }
}
- (void)didBecomeActive
{
    if([[MTVUploader sharedMTVUploader] canDownloadUpload])
    {
        if(isStoppedDownloadAuto_)
        {
            [self cacheMTV:cacheUrlString_ isNoticed:NO];
        }
        if(isStoppedUploadAuto_ && mtvItem_)
        {
            [[MTVUploader sharedMTVUploader]uploadMTV:mtvItem_];
        }
    }
}
- (void)addObserveres
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showCachingStatus:)
                                                 name:NT_CACHINGMESSAGE
                                               object:nil];
    //    [[NSNotificationCenter defaultCenter]addObserver:self
    //                                            selector:@selector(willEnterbackground:)
    //                                                name:UIApplicationWillResignActiveNotification
    //                                              object:nil];
    //    [[NSNotificationCenter defaultCenter]addObserver:self
    //                                            selector:@selector(didBecomeActive:)
    //                                                name:UIApplicationDidBecomeActiveNotification
    //                                              object:nil];
}
- (void)readyToRelease
{
    if(redDotTimer_)
    {
        [redDotTimer_ invalidate];
        redDotTimer_ = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)dealloc
{
    [self readyToRelease];
    PP_SUPERDEALLOC;
}
#pragma mark - some views
#pragma mark - alterview
//- (void)showNoticeForWWANForTag:(int)tagID
//{
//    if ([NSThread isMainThread]) {
//        [self pauseItem:nil];
//
//        SNAlertView *alert = [[SNAlertView alloc] initWithTitle:MSG_PROMPT
//                                                        message:@"您正在使用手机网络，是否继续加载视频？"
//                                                       delegate:self
//                                              cancelButtonTitle:@"暂停"
//                                              otherButtonTitles:@"继续加载", nil];
//        alert.tag = tagID;
//        [alert show:self.view];
//
//    }
//    else
//    {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self showNoticeForWWANForTag:tagID];
//        });
//    }
//}
//- (void)snAlertView:(SNAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//if(alertView.tag==3002)
//{
//    if(buttonIndex ==alertView.cancelButtonIndex){
//        //        [[UIApplication sharedApplication] openURL:
//        //         [NSURL URLWithString:UIApplicationOpenSettingsURLString]];
//        //            prefs:root=WIFI
//        //            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
//        //            [self setup:nil];
//
//        //下次再出现，还需要提醒
//        [[UserManager sharedUserManager] enableNotickeFor3G];
//        [UserManager sharedUserManager].currentSettings.DownloadVia3G = NO;
//
//        [self stopCacheMTV];
//        [self hideHUDView];
//        //下次再出现，还需要提醒
//        [[UserManager sharedUserManager]enableNotickeFor3G];
//
//    }else{
//        //30分钟内不再提示
//        [UserManager sharedUserManager].currentSettings.DownloadVia3G = YES;
//        [[UserManager sharedUserManager] disableNotickeFor3G];
//
//        [self cacheMTV:nil isNoticed:YES];
//    }
//}

#pragma mark - helper
- (CAGradientLayer *)buildVerticalGradientLayer:(BOOL)gradientDark
{
    //初始化渐变层
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    //gradientLayer.frame = view.bounds;
    //[view.layer addSublayer:gradientLayer];
    
    //设置渐变颜色方向
    if (gradientDark) {
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1);
    } else {
        gradientLayer.startPoint = CGPointMake(0, 1);
        gradientLayer.endPoint = CGPointMake(0, 0);
    }
    
    //设定颜色组
    gradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor,
                             (__bridge id)[UIColor colorWithWhite:0 alpha:0.5].CGColor];
    
    //设定颜色分割点
    gradientLayer.locations = @[@(0.0f) ,@(1.0f)];
    
    return gradientLayer;
}
- (void)redDotAnimate:(id)sender
{
    if (redDot_.alpha) {
        [UIView animateWithDuration:0.9 animations:^{
            redDot_.alpha = 0;
        }];
    }
    else{
        [UIView animateWithDuration:0.9 animations:^{
            redDot_.alpha = 1;
        }];
    }
}
- (void)snAlertView:(SNAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 4005)//数据保存失败
    {
        if(buttonIndex ==alertView.cancelButtonIndex)
        {
        }
        else
        {
            [self beginUpload];
        }
    }
}

@end
