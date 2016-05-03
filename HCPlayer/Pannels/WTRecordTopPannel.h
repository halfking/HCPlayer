//
//  WTRecordTopPannel.h
//  maiba
//
//  Created by HUANGXUTAO on 16/3/31.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <hccoren/base.h>
#import <HCBaseSystem/VDCItem.h>
#import <HCMVManager/MTVUploader.h>
#import <HCMVManager/MTV.h>
#import <HCBaseSystem/SNAlertView.h>
#import "WTVideoPlayerProgressView.h"

@class WTRecordTopPannel;

@protocol WTRecordTopPannelDelegate <NSObject>
@optional
- (BOOL)recordPannel:(WTRecordTopPannel *)pannelView cacheCompleted:(VDCItem *)item;
- (BOOL)recordPannel:(WTRecordTopPannel *)pannelView cacheCancelled:(VDCItem *)item;
- (BOOL)recordPannel:(WTRecordTopPannel *)pannelView cacheStatusChanged:(NSString *)fileName speed:(CGFloat)downloadSpeed;
- (BOOL)recordPannel:(WTRecordTopPannel *)pannelView cacheNoNetwork:(BOOL)show;
- (BOOL)recordPannel:(WTRecordTopPannel *)pannelView cacheCheckNetwork:(BOOL)show;
- (BOOL)recordPannel:(WTRecordTopPannel *)pannelView preview:(BOOL)preview;
- (BOOL)recordPannel:(WTRecordTopPannel *)pannelView back:(BOOL)back;
- (BOOL)recordPannel:(WTRecordTopPannel *)pannelView singCompleted:(BOOL)completed;
//- (BOOL)recordPannel:(WTRecordTopPannel *)pannelView resing:(BOOL)resing;
- (BOOL)recordPannel:(WTRecordTopPannel *)pannelView editMtv:(BOOL)edit;
- (BOOL)recordPannel:(WTRecordTopPannel *)pannelView resingMtv:(BOOL)resing;
//- (BOOL)recordPannel:(WTRecordTopPannel *)pannelView upload:(BOOL)upload;
- (BOOL)recordPannel:(WTRecordTopPannel *)pannelView cancelPreview:(BOOL)cancel;
- (BOOL)recordPannel:(WTRecordTopPannel *)pannelView uploadCompleted:(MTV *)item;
- (BOOL)recordPannel:(WTRecordTopPannel *)pannelView beginUpload:(MTV *)item;
@end
@interface WTRecordTopPannel : UIView<MTVUploadderDelegate,SNAlertViewDelegate>
{
    int recordMode_;
    BOOL isBuild_;
    BOOL isStoppedDownloadAuto_;//正在下载，是否因为切到后台导致停止
    BOOL isCaching_;    //是否正在下载
    BOOL isUploading_;  //是否正在上传
    BOOL isStoppedUploadAuto_;
    
    UIView * bgView_;
    CAGradientLayer *gradientLayer_;
    
    NSString * cacheUrlString_;
    
    UIView * cacheContainer_;
    UILabel * cacheProgressLabel_;
    UITapGestureRecognizer * cacheGesture_;
    UIImageView * cacheIcon_;
    
    //buttons
    UIButton * previewBtn_;
    UIButton * resingBtn_;
    UIButton * returnBtn_;
    UIButton * cancelPreivewBtn_;
    UIButton * completedBtn_;
    
    UIView * recordTimePannel_;
    UIView * redDot_;
    UILabel * playProgress_;
    NSTimer *redDotTimer_;
    CGFloat lastRecordTime_;//上次刷新时的时间，防止刷新过度
    
    UILabel * title_;
    
    UILabel * speedLabel_;
    UILabel * speedDescLabel_;
    NSTimer * hideSpeedTimer_;
    
    UIView * progressView_;
    UIImageView * uploadIcon_;
    UILabel * uploadProgressLabel_;
    BOOL uoploadNeedShow_;
    NSTimer * uploadProgressHideTimer_;
    
    BOOL isUploadMtvQuering_;
    
    UILabel * earPhoneRemindLabel_; //显示耳机提醒
//    BOOL canShowHeadsetNotice_; //是否可以显示
    
    NSString * totalDurationString_;//04:32 etc.
    
    BOOL needRefresh_;
}
@property (nonatomic,PP_WEAK) NSObject <WTRecordTopPannelDelegate> * delegate;
@property (nonatomic,PP_STRONG,readonly) MTV * MTVItem;
@property (nonatomic,PP_STRONG,readonly) MTV * SampleItem;
@property (nonatomic,PP_STRONG,readonly) VDCItem * localVDCItem;
@property (nonatomic,assign) BOOL canShowSpeed;
@property (nonatomic,assign) BOOL needShowProgress;
@property (nonatomic,assign) BOOL isUploadingSuspended;

@property (nonatomic,assign) BOOL showUploadBtn;
@property (nonatomic,assign) BOOL showResingBtn;
@property (nonatomic,assign) BOOL showPreviewBtn;
@property (nonatomic,assign) BOOL showCacheBtn;
@property (nonatomic,assign) BOOL showBackBtn;
@property (nonatomic,assign) BOOL showCancelPreviewBtn;
@property (nonatomic,assign) BOOL showTitle;
@property (nonatomic,assign) BOOL showRecordTimePannel;
@property (nonatomic,assign) BOOL showCompletedBtn;

- (instancetype)initWithPara:(CGRect)frame recordMode:(BOOL)recordMode;

- (void) setMTVItem:(MTV *)MTVItem sample:(MTV*)sampleItem;
- (void) setLocalVDCItem:(VDCItem*)item;

- (void)setPannelMode:(int)recordMode;
- (void)setSingCompletedMode;
//- (void)setCanPreview:(BOOL)canPreview;

- (void)changeFrame:(CGRect)frame;
- (void)buildViews:(CGRect)frame;

- (void)setCurrentTime:(CGFloat)seconds;
- (void)setTotalDuration:(CGFloat)seconds;
- (void)showCachingStatus:(NSNotification *)notification;
- (void)hideCachingStatus:(NSTimer *)timer;

- (void)showUseHeadsetNotice;
- (void)hideUseHeadsetNotice;

- (void)stopCacheMTV;//:(NSString *)url;

- (void)hideWithAnimates:(BOOL)animates;

- (void)cancelPreviewClick:(id)sender;
- (void)showCacheStatus:(int)isDownloading hidden:(int)isHidden percent:(CGFloat)percent animates:(BOOL)animates;
//- (BOOL)canShowProgress:(MTV *)item userID:(int)userID;

- (void)willEnterbackground;
- (void)didBecomeActive;
- (void)readyToRelease;
@end
