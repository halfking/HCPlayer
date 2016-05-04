//
//  WTPlayerControlPannel.m
//  maiba
//
//  Created by HUANGXUTAO on 15/12/23.
//  Copyright © 2015年 seenvoice.com. All rights reserved.
//

#import "WTPlayerControlPannel.h"
#import <HCMVManager/vdcManager_full.h>
#import <hccoren/base.h>
#import <HCBaseSystem/cmd_wt.h>
#import <HCBaseSystem/User_WT.h>
#import <HCBaseSystem/CMD_LikeOrNot.h>
#import "player_config.h"


@implementation WTPlayerControlPannel
@synthesize delegate;
//,progressDelegate;
@synthesize MTVItem;
@synthesize SampleItem;
//@synthesize useGuidAudio;
- (id)init
{
    if(self = [super init])
    {
        self.canShowCacheStatus = NO;
        isBuild_ = NO;
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.canShowCacheStatus = NO;
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
- (void)setUseGuidAudio:(BOOL)puseGuidAudio
{
    //    _UseGuidAudio = puseGuidAudio;
    if(leaderSwitch_.hidden && puseGuidAudio)
        leaderSwitch_.hidden = NO;
    [leaderSwitch_ setOn:puseGuidAudio];
}
- (BOOL)getUseGuidAudio
{
    return leaderSwitch_.isOn;
}
- (void)buildViews:(CGRect)frame
{
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    CGFloat left = 15;
    CGFloat top = height - 46;
    
    {
        bgView_ = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
        bgView_.backgroundColor = COLOR_CG;
        bgView_.alpha = 0.6;
        [self addSubview:bgView_];
    }
    {
        leaderSwitch_ = [[SevenSwitch alloc]initWithFrame:CGRectMake(left, height/2.0 - 10, 80, 20)];
        leaderSwitch_.onText = @"导唱";
        leaderSwitch_.onTextColor = COLOR_CG;
        leaderSwitch_.offText = @"伴奏";
        leaderSwitch_.offTextColor = COLOR_CC;
        leaderSwitch_.borderColor = COLOR_CL;//[UIColor] [UIImage imageNamed:@"switch_icon.png"];
        leaderSwitch_.isRounded = YES;
        leaderSwitch_.hidden = NO;
        //        leaderSwitch_.onColor = COLOR_CL;
        //        leaderSwitch_.activeColor = COLOR_CL;
        //        leaderSwitch_.inactiveColor = COLOR_CL;
        leaderSwitch_.knobColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"switch_icon.png"]];
        NSLog(@"leader switch frame:%@",NSStringFromCGRect(leaderSwitch_.frame));
        [leaderSwitch_ setOn:YES];
        [leaderSwitch_ setup];
        
        [self addSubview:leaderSwitch_];
        
        [leaderSwitch_ addTarget:self action:@selector(openOrCloseLeader:) forControlEvents:UIControlEventValueChanged];
        
        //        leaderButton_ = [[UIButton alloc] initWithFrame:CGRectMake(left, top, 65, 30)];
        //        [leaderButton_ setImage:[UIImage imageNamed:@"singclose"] forState:UIControlStateNormal];
        //        [leaderButton_ setImage:[UIImage imageNamed:@"singopen"] forState:UIControlStateSelected];
        //        [leaderButton_ addTarget:self action:@selector(openOrCloseLeader:) forControlEvents:UIControlEventTouchUpInside];
        //        leaderButton_.titleLabel.font = FONT_STANDARD(10);
        //        leaderButton_.titleLabel.textColor = COLOR_CA;
        //        //        leaderButton_.hidden = YES;
        //        [self addSubview:leaderButton_];
    }
    //    left = width - 50 *2 - 45;
    left = width - 50;
//    {
//        reportButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
//        reportButton_.frame = CGRectMake(left, top, 46, 46);
//        [reportButton_ setImage:[UIImage imageNamed:@"report_hover"] forState:UIControlStateNormal];
//        [reportButton_ setImage:[UIImage imageNamed:@"report_hover"] forState:UIControlStateSelected];
//        [reportButton_ addTarget:self action:@selector(reportMtv:) forControlEvents:UIControlEventTouchUpInside];
//        
//        UILabel * lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 46 - 20, 46, 15)];
//        lable.font = FONT_STANDARD(10);
//        lable.text = @"分享";
//        lable.textColor = COLOR_CA;
//        lable.backgroundColor = [UIColor clearColor];
//        lable.textAlignment = NSTextAlignmentCenter;
//        [reportButton_ addSubview:lable];
//        reportTitle_ = lable;
//        //
//        //        [shareButton_ setTitle:@"456" forState:UIControlStateNormal];
//        //
//        //        shareButton_.titleLabel.font = FONT_STANDARD(10);
//        //        shareButton_.titleLabel.textColor = COLOR_CA;
//        ////        shareButton_.titleEdgeInsets = UIEdgeInsetsMake(20, 0, 0, 0);
//        [self addSubview:reportButton_];
//        left -= 50;
//
//    }
    {
        shareButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
        shareButton_.frame = CGRectMake(left, top, 46, 46);
        [shareButton_ setImage:[UIImage imageNamed:@"playpannel_share_icon.png"] forState:UIControlStateNormal];
        [shareButton_ setImage:[UIImage imageNamed:@"playpannel_share_sel_icon.png"] forState:UIControlStateSelected];
        [shareButton_ addTarget:self action:@selector(shareMtv:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel * lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 46 - 20, 46, 15)];
        lable.font = FONT_STANDARD(10);
        lable.text = @"分享";
        lable.textColor = COLOR_CA;
        lable.backgroundColor = [UIColor clearColor];
        lable.textAlignment = NSTextAlignmentCenter;
        [shareButton_ addSubview:lable];
        shareTitle_ = lable;
        //
        //        [shareButton_ setTitle:@"456" forState:UIControlStateNormal];
        //
        //        shareButton_.titleLabel.font = FONT_STANDARD(10);
        //        shareButton_.titleLabel.textColor = COLOR_CA;
        ////        shareButton_.titleEdgeInsets = UIEdgeInsetsMake(20, 0, 0, 0);
        [self addSubview:shareButton_];
        left -= 50;
    }
    
    if(![UserManager sharedUserManager].isForReivew)
    {
        cacheButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
        cacheButton_.frame = CGRectMake(left, top, 46, 46);
        [cacheButton_ setImage:[UIImage imageNamed:@"playpannel_cache_icon.png"] forState:UIControlStateNormal];
        [cacheButton_ setImage:[UIImage imageNamed:@"playpannel_cache_sel_icon.png"] forState:UIControlStateSelected];
        [cacheButton_ addTarget:self action:@selector(cacheMtv:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel * lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 46 - 20, 46, 15)];
        lable.font = FONT_STANDARD(10);
        lable.text = @"缓存";
        lable.textColor = COLOR_CA;
        lable.backgroundColor = [UIColor clearColor];
        lable.textAlignment = NSTextAlignmentCenter;
        [cacheButton_ addSubview:lable];
        cacheTitle_ = lable;
        
        //        [cacheButton_ setTitle:@"324" forState:UIControlStateNormal];
        //        cacheButton_.titleLabel.font = FONT_STANDARD(10);
        //        cacheButton_.titleLabel.textColor = COLOR_CA;
        ////        cacheButton_.titleEdgeInsets = UIEdgeInsetsMake(20, 0, 0, 0);
        [self addSubview:cacheButton_];
        left -= 50;
    }
    {
        likeButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
        likeButton_.frame = CGRectMake(left, top, 46, 46);
        [likeButton_ setImage:[UIImage imageNamed:@"playpannel_love_icon.png"] forState:UIControlStateNormal];
        [likeButton_ setImage:[UIImage imageNamed:@"playpannel_love_sel_icon.png"] forState:UIControlStateSelected];
        [likeButton_ addTarget:self action:@selector(likeMtv:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel * lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 46 - 20, 46, 15)];
        lable.font = FONT_STANDARD(10);
        lable.text = @"2133";
        lable.textColor = COLOR_CA;
        lable.backgroundColor = [UIColor clearColor];
        lable.textAlignment = NSTextAlignmentCenter;
        [likeButton_ addSubview:lable];
        likeTitle_ = lable;
        
        //        [likeButton_ setTitle:@"253" forState:UIControlStateNormal];
        //        likeButton_.titleLabel.font = FONT_STANDARD(10);
        //                likeButton_.titleLabel.textColor = COLOR_CA;
        ////        likeButton_.titleEdgeInsets = UIEdgeInsetsMake(20, 0, 0, 0);
        [self addSubview:likeButton_];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveCacheStatus:) name:NT_CACHEPROGRESS object:nil];
    isBuild_ = YES;
}
- (void)changeFrame:(CGRect)frame
{
    self.frame = frame;
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    CGFloat left = 15;
    CGFloat top = height - 46 - 5;
    bgView_.frame = CGRectMake(0, 0, width, height);
    
    leaderSwitch_.frame = CGRectMake(left, height/2.0 - 10, 90, 20);
    NSLog(@"leader switch frame:%@",NSStringFromCGRect(leaderSwitch_.frame));
    //    {
    //        leaderButton_.frame = CGRectMake(left, top, 65, 30);
    //    }
    left = width - 50 ;
    
    {
        shareButton_.frame = CGRectMake(left, top, 46, 46);
        left -= 50;
    }
    if(![UserManager sharedUserManager].isForReivew)
    {
        cacheButton_.frame = CGRectMake(left, top, 46, 46);
        left -= 50;
    }
    
    {
        likeButton_.frame = CGRectMake(left, top, 46, 46);
    }
}
- (void) setMTVItem:(MTV *)item sample:(MTV*)sampleItem
{
    MTVItem = item;
    SampleItem = sampleItem;
    
    if([NSThread isMainThread])
    {
        if(!isBuild_)
        {
            [self buildViews:self.frame];
        }
        likeTitle_.text = [NSString stringWithFormat:@"%ld",(long)MTVItem.LikeCount];
        //        likeButton_.titleLabel.text = [NSString stringWithFormat:@"%d",mtvItem.LikeCount];
        if(MTVItem.IsLike)
        {
            likeButton_.selected = YES;
        }
        else
        {
            likeButton_.selected = NO;
        }
        localVDCItem_ = nil;
        //        if(!localVDCItem_)
        localVDCItem_ = [[VDCManager shareObject]getVDCItemByMtv:MTVItem urlString:nil];
        
        [self showCacheStatus];
        
        [self refreshGuidAudio];
        //        shareTitle_.text = [NSString stringWithFormat:@"%d",MTVItem.ShareCount];
        
        //        shareButton_.titleLabel.text = [NSString stringWithFormat:@"%d",MTVItem.ShareCount];
        
        //        NSLog(@"leader switch frame:%@",NSStringFromCGRect(leaderSwitch_.frame));
        [self setNeedsDisplay];
        
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self setMTVItem:item sample:sampleItem];
                       });
    }
    
}
- (void)refreshGuidAudio
{
    if([NSThread isMainThread])
    {
        if(MTVItem.SampleID>0)
        {
            if(MTVItem.AudioRemoteUrl && MTVItem.AudioRemoteUrl.length>2)
            {
                if(MTVItem.MTVID==0)
                {
                    leaderSwitch_.hidden = NO;
                    [leaderSwitch_ setOn:YES];
                }
                else if(SampleItem && SampleItem.SampleID>0)
                {
                    //如果URL与Sample相同，表示该用户只有伴奏与唱过的录音，因此默认要显示
                    if([MTVItem.DownloadUrl720 isEqualToString:SampleItem.DownloadUrl720])
                    {
                        leaderSwitch_.hidden = YES;
                        [leaderSwitch_ setOn:YES];
                    }
                    else //有合成的MTV，则不需要导唱
                    {
                        leaderSwitch_.hidden = YES;
                        [leaderSwitch_ setOn:NO];
                    }
                }
                else
                {
                    leaderSwitch_.hidden = YES;
                    [leaderSwitch_ setOn:NO];
                }
            }
            else
            {
                [leaderSwitch_ setOn:NO];
                leaderSwitch_.hidden = YES;
            }
        }
        else
        {
            leaderSwitch_.hidden = YES;
            [leaderSwitch_ setOn:NO];
        }
        [self openOrCloseLeader:nil];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self refreshGuidAudio];
                       });
        
    }
}
- (void)recieveCacheStatus:(NSNotification *)notification
{
    VDCItem * item = notification.object;
    if(!self.canShowCacheStatus) return;
    
    if(!MTVItem) return;
    if(!localVDCItem_)
        localVDCItem_ = [[VDCManager shareObject]getVDCItemByMtv:MTVItem urlString:nil];
    if(!localVDCItem_) return;
    if(item == localVDCItem_ || [item.key isEqualToString:localVDCItem_.key])
    {
        [self showCacheStatus];
        
    }
}
- (void)showCacheStatus
{
    //    if(!localVDCItem_) return;
    if([UserManager sharedUserManager].isForReivew) return;
    if(!self.canShowCacheStatus) return;
    if([NSThread isMainThread])
    {
        if(!localVDCItem_)
        {
            cacheButton_.selected = NO;
            cacheTitle_.text = @"缓存";
            cacheTitle_.textColor = [UIColor whiteColor];
            cacheButton_.alpha = 1;
            cacheTitle_.alpha = 1;
        }
        else
        {
            if(localVDCItem_.isDownloading)
            {
                cacheButton_.selected = YES;
                cacheTitle_.textColor = COLOR_BA;
            }
            else
            {
                cacheButton_.selected = NO;
                cacheTitle_.textColor = [UIColor whiteColor];
            }
            if(localVDCItem_.contentLength>0)
            {
                CGFloat percent = localVDCItem_.downloadBytes * 100.0/localVDCItem_.contentLength;
                if(percent>100) percent = 100;
                
                //            [cacheButton_ setTitle:title forState:UIControlStateNormal];
                //            [cacheButton_ setTitleColor:COLOR_CA forState:UIControlStateNormal];
                //            cacheButton_.titleLabel.text = [NSString stringWithFormat:@"%.1f%%",localVDCItem_.downloadBytes * 100.0/localVDCItem_.contentLength];
                if(percent>=100)
                {
                    cacheButton_.selected = NO;
                    
                    cacheTitle_.text = @"已缓存";
                    cacheButton_.alpha = 0.6;
                    cacheTitle_.alpha = 0.6;
                }
                else
                {
                    NSString * title = [NSString stringWithFormat:@"%.0f%%",percent];
                    cacheTitle_.text = title;
                    
                    cacheButton_.alpha = 1;
                    cacheTitle_.alpha = 1;
                }
            }
            else
            {
                cacheTitle_.text = @"缓存";
                cacheTitle_.textColor = [UIColor whiteColor];
                cacheButton_.alpha = 1;
                cacheTitle_.alpha = 1;
            }
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self showCacheStatus];
                       });
    }
}
- (void)showLikeStatus
{
    MTVItem.IsLike = !MTVItem.IsLike;
    if(MTVItem.IsLike) {
        MTVItem.LikeCount ++;
    } else {
        MTVItem.LikeCount --;
        if(MTVItem.LikeCount <0) MTVItem.LikeCount = 0;
    }
    [self showLikeCount];
    //爱心动画
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.values = @[@(0.1),@(1.0),@(1.5)];
    animation.keyTimes = @[@(0.0),@(0.5),@(0.8),@(1.0)];
    animation.calculationMode = kCAAnimationLinear;
    [likeButton_.layer addAnimation:animation forKey:@"SHOW"];
}
- (void)showLikeCount
{
    if([NSThread isMainThread])
    {
        NSString * title = [NSString stringWithFormat:@"%ld",(long)MTVItem.LikeCount];
        likeTitle_.text = title;
        likeButton_.selected = MTVItem.IsLike;
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self showLikeCount];
                       });
    }
}
#pragma mark - events
- (void)openOrCloseLeader:(id)sender
{
    //    if (leaderButton_.ison) {
    //        [leaderButton_ setSelected:NO];
    //    }
    //    else{
    //        [leaderButton_ setSelected:YES];
    //    }
    //    _UseGuidAudio = leaderSwitch_.isOn;
    if(delegate && [delegate respondsToSelector:@selector(videoPannel:guideChanged:)])
    {
        [delegate videoPannel:self guideChanged:leaderSwitch_.isOn];
    }
}
- (void)likeMtv:(id)sender
{
    if(delegate && [delegate respondsToSelector:@selector(videoPannel:likeIt:)])
    {
        [delegate videoPannel:self likeIt:likeButton_.selected];
    }
    else if (MTVItem && (MTVItem.MTVID>0||MTVItem.SampleID>0))
    {
        MTV * item = MTVItem;
        CMD_CREATE(cmd, LikeOrNot, @"LikeOrNot");
        
        if(MTVItem.MTVID>0)
        {
            cmd.MtvID = item.MTVID;
        }
        else
        {
            cmd.MtvID = item.SampleID;
            cmd.ObjectType = HCObjectTypeSample;
        }
        cmd.ObjectUserID = item.UserID;
        cmd.IsLike = !item.IsLike;
        NSLog(@"%d", (int)item.LikeCount);
        cmd.CMDCallBack = ^(HCCallbackResult * result)
        {
            if(result.Code==0)
            {
                [self showLikeStatus];
            }
        };
        [cmd sendCMD];
    }
}

- (void)cacheMtv:(id)sender
{
    if(cacheButton_.selected)
    {
        cacheButton_.selected = NO;
        [[VDCManager shareObject]stopDownload:nil];
        self.canShowCacheStatus = NO;
        cacheButton_.alpha = 1.0f;
        cacheTitle_.alpha = 1.0f;
        cacheTitle_.textColor = [UIColor whiteColor];
    }
    else
    {
        cacheButton_.selected = YES;
        self.canShowCacheStatus = YES;
        if(delegate && [delegate respondsToSelector:@selector(videoPannel:doCache:)])
        {
            [delegate videoPannel:self doCache:cacheButton_.selected];
        }
        else
        {
            VDCManager * vdcManager = [VDCManager shareObject];
            
            
            NSString *  url = [MTVItem getDownloadUrlOpeated:ReachableViaWiFi userID:[UserManager sharedUserManager].currentUser.UserID];
            
            NSString * audioUrl = MTVItem.AudioRemoteUrl;
            
            if([HCFileManager isLocalFile:url])
            {
                localVDCItem_ = [vdcManager getVDCItemByMtv:MTVItem urlString:nil];
                [self showCacheStatus];
                return;
            }
            
            NSString *title = [NSString stringWithFormat:@"%@  (%@)",MTVItem.Title,MTVItem.Author];
            [vdcManager downloadUrl:url audioUrl:audioUrl title:title isAudio:NO urlReady:^(VDCItem * vdcItem,NSURL * videoUrl)
             {
                 localVDCItem_ = vdcItem;
                 [self showCacheStatus];
             }
                           progress:^(VDCItem *vdcItem) {
                               [self showCacheStatus];
                               
                           } completed:^(VDCItem *vdcItem, BOOL completed, VDCTempFileInfo *tempFile) {
                               if (completed) {
                                   [self showCacheStatus];
                               }
                           }];
            
        }
    }
    
}
- (void)reportMtv:(id)sender
{
    if(delegate && [delegate respondsToSelector:@selector(videoPannel:reportMtv:)])
    {
        [delegate videoPannel:self reportMtv:YES];
    }
}
- (void)shareMtv:(id)sender
{
    if(delegate && [delegate respondsToSelector:@selector(videoPannel:doShare:)])
    {
        [delegate videoPannel:self doShare:shareButton_.selected];
    }
}
- (void)hideGuidAudio
{
    leaderButton_.hidden = YES;
}
- (void)showGuidAudio
{
    leaderButton_.hidden = NO;
}
- (void)readyToRelease
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)dealloc
{
    [self readyToRelease];
    PP_SUPERDEALLOC;
}
@end
