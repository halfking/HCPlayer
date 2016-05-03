//
//  WTPlayerControlPannel.h
//  maiba
//
//  Created by HUANGXUTAO on 15/12/23.
//  Copyright © 2015年 seenvoice.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <hccoren/base.h>
#import <HCBaseSystem/SevenSwitch.h>
#import <HCMVManager/MTV.h>
#import <HCBaseSystem/VDCItem.h>
#import "WTVideoPlayerProgressView.h"

@class WTPlayerControlPannel;

@protocol WTPlayerControlPannelDelegate <NSObject>
@optional
- (void)videoPannel:(WTPlayerControlPannel *)pannelView guideChanged:(BOOL)isGuide;
- (void)videoPannel:(WTPlayerControlPannel *)pannelView likeIt:(BOOL)isLike;
- (void)videoPannel:(WTPlayerControlPannel *)pannelView doCache:(BOOL)cache;
- (void)videoPannel:(WTPlayerControlPannel *)pannelView doShare:(CGFloat)seconds;
- (void)videoPannel:(WTPlayerControlPannel *)pannelView showComments:(BOOL)show;
- (void)videoPannel:(WTPlayerControlPannel *)pannelView editComments:(BOOL)show;
- (void)videoPannel:(WTPlayerControlPannel *)pannelView didReturn:(BOOL)isReturn;
- (void)videoPannel:(WTPlayerControlPannel *)pannelView showMore:(BOOL)isMore;
- (void)videoPannel:(WTPlayerControlPannel *)pannelView editMtv:(BOOL)edit;
- (void)videoPannel:(WTPlayerControlPannel *)pannelView resingMtv:(BOOL)resing;
- (void)videoPannel:(WTPlayerControlPannel *)pannelView previewMtv:(BOOL)preview;
- (void)videoPannel:(WTPlayerControlPannel *)pannelView cancelPreview:(BOOL)cancel;
- (void)videoPannel:(WTPlayerControlPannel *)pannelView reportMtv:(BOOL)report;
@end

@interface WTPlayerControlPannel : UIView
{
    BOOL isBuild_;
    VDCItem * localVDCItem_;
    
    UIView * bgView_;
    
    SevenSwitch * leaderSwitch_;
    UIButton * leaderButton_;
    UIButton * likeButton_;
    UIButton * cacheButton_;
    UIButton * shareButton_;
    
    UIButton * reportButton_;
    UILabel * reportTitle_;
    
    UILabel * likeTitle_;
    UILabel * cacheTitle_;
    UILabel * shareTitle_;
}
@property (nonatomic,PP_WEAK) id <WTPlayerControlPannelDelegate>  delegate;
@property (nonatomic,assign) BOOL canShowCacheStatus;
//@property (nonatomic,PP_WEAK) NSObject <WTVideoPlayerProgressDelegate> * progressDelegate;
@property (nonatomic,PP_STRONG,readonly) MTV * MTVItem;
@property (nonatomic,PP_STRONG,readonly) MTV * SampleItem;
@property (nonatomic,assign,setter=setUseGuidAudio:,getter=getUseGuidAudio) BOOL UseGuidAudio;
- (void) setMTVItem:(MTV *)MTVItem sample:(MTV*)sampleItem;
- (void) setUseGuidAudio:(BOOL)useGuideAudio;
- (BOOL) getUseGuidAudio;
- (void) refreshGuidAudio;

- (void) changeFrame:(CGRect)frame;
- (void) hideGuidAudio;
- (void) showGuidAudio;
- (void) readyToRelease;
- (void) showCacheStatus;
- (void) showLikeStatus;

@end
