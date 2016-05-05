//
//  WTPlayerTopPannel.m
//  maiba
//
//  Created by HUANGXUTAO on 15/12/24.
//  Copyright © 2015年 seenvoice.com. All rights reserved.
//

#import "WTPlayerTopPannel.h"
#import <hccoren/base.h>
#import <HCBaseSystem/VDCManager.h>
#import <HCBaseSystem/User_WT.h>
#import <HCBaseSystem/UpDown.h>
#import <HCBaseSystem/CMD_LikeOrNot.h>
#import <hccoren/UIView+extension.h>
#import <HCMVManager/MTVUploader.h>
#import <HCMVManager/MTV.h>
#import <HCMVManager/vdcManager_full.h>
#import "player_config.h"


@implementation WTPlayerTopPannel
@synthesize delegate;
//,progressDelegate;
@synthesize MTVItem;
@synthesize SampleItem;
@synthesize rightMenuContainer = rightMenuContainer_;
//@synthesize useGuidAudio;
- (void)setDefaultSets
{
    self.ShowCommentsButton = YES;
    self.ShowGuideAudio = NO;
    self.ShowLikes = YES;
    self.ShowMore = YES;
    self.ShowReturn = YES;
    self.ShowTitle = YES;
    self.ShowShare = NO;
    self.ShowCache = NO;
    self.ShowEdit = YES;
    self.ShowPreview = NO;
    self.ShowResing = NO;
    self.ShowCommentSwitch = YES;
    _isCommentsShow = YES;
    isPlayMode_ = YES;
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
- (instancetype)initWithPara:(CGRect)frame playMode:(BOOL)isPlayMode
{
    if(self = [self initWithFrame:frame])
    {
        [self setPannelMode:isPlayMode];
//        if(!isBuild_)
//        {
//            [self buildViews:frame];
//        }
//        else
//        {
//            [self changeFrame:frame];
//        }
    }
    return self;
}
- (void)setPannelMode:(BOOL)isPlay
{
    if(isPlayMode_==isPlay) return;
    isPlayMode_ = isPlay;
    if(isPlayMode_)
    {
        [self setDefaultSets];
    }
    else
    {
        self.ShowCommentsButton = NO;
        self.ShowGuideAudio = NO;
        self.ShowLikes = NO;
        self.ShowMore = YES;
        self.ShowReturn = YES;
        self.ShowTitle = YES;
        self.ShowShare = NO;
        self.ShowCache = YES;
        self.ShowResing = NO;
        self.ShowPreview = NO;
        self.ShowCommentSwitch = NO;
        _isCommentsShow = NO;
    }
    if(!isBuild_)
        [self buildViews:self.frame];
    else
        [self changeFrame:self.frame];
    
}
- (void)setCanPreview:(BOOL)canPreview
{
    if(canPreview)
    {
        self.ShowPreview = YES;
        self.ShowResing = YES;
        self.ShowCache = NO;
    }
    else
    {
        self.ShowPreview = NO;
        self.ShowResing = NO;
        self.ShowCache = YES;
    }
    [self buildViews:self.frame];
}
- (void)setUseGuidAudio:(BOOL)puseGuidAudio
{
    [leaderSwitch_ setOn:puseGuidAudio];
}
- (BOOL)getUseGuidAudio
{
    return leaderSwitch_.isOn;
}
- (void)clearViews
{
    for (UIView * v in self.subviews) {
        [v removeFromSuperview];
    }
    {
        if(rightMenuContainer_)
        {
            [rightMenuContainer_ removeFromSuperview];
            rightMenuContainer_ = nil;
        }
        bgView_ = nil;
        returnButton_ = nil;
        leaderButton_ = nil;;
        likeButton_ = nil;;
        cacheButton_= nil;
        shareButton_= nil;
        
        commentButton_= nil;
        moreButton_= nil;
        returnButton_= nil;
        previewButton_= nil;
        resingButton_= nil;
        cancelPreviewButton_= nil;
        
        reportButton_ = nil;
        
        titleLabel_= nil;
        
        likeTitle_= nil;
        cacheTitle_= nil;
        shareTitle_= nil;
        commentTitle_= nil;
        
        
        rightMenuArrow_= nil;
        editButton_= nil;
        barrageButton_= nil;
        shareButton2_= nil;
        
        redDot_= nil;
        progressTime_= nil;
    }
}

- (void)buildViews:(CGRect)frame
{
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    CGFloat left = 0;
    CGFloat top = (height - 40)/2.0f;
    
    UIFont * textFont = FONT_STANDARD(15);
    NSDictionary *attributes = @{NSFontAttributeName: textFont};
    
    if(!bgView_){
        bgView_ = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
        //        bgView_.backgroundColor =   COLOR_CF;
        //        bgView_.alpha = 0.4;
        [self addSubview:bgView_];
        
        gradientLayer_ = [self buildVerticalGradientLayer:NO];
        gradientLayer_.frame = bgView_.bounds;
        [bgView_.layer addSublayer:gradientLayer_];
    }
    else
    {
        bgView_.frame = CGRectMake(0, 0, width, height);
        gradientLayer_.frame = bgView_.bounds;
    }
    //return
    if(self.ShowReturn){
        if(!returnButton_)
        {
            returnButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
            returnButton_.frame = CGRectMake(left, top, 40, 40);
            [returnButton_ setImage:[UIImage imageNamed:@"HCPlayer.bundle/play_return.png"] forState:UIControlStateNormal];
            [returnButton_ addTarget:self action:@selector(returnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:returnButton_];
        }
        else
        {
            returnButton_.frame = CGRectMake(left, top, 40, 40);
        }
        left += 40;
    }
    //title
    if(self.ShowTitle ){
        if(!titleLabel_)
        {
            titleLabel_ = [[UILabel alloc]initWithFrame:CGRectMake(left, 0, width-200, height)];
            titleLabel_.text = @"";
            titleLabel_.font = textFont;
            titleLabel_.textAlignment = NSTextAlignmentLeft;
            titleLabel_.textColor = [UIColor whiteColor];
            titleLabel_.backgroundColor = [UIColor clearColor];
            titleLabel_.shadowColor = COLOR_SHADOW;
            titleLabel_.shadowOffset = SHADOW_SIZE;
            [self addSubview:titleLabel_];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(returnClicked:)];
            titleLabel_.userInteractionEnabled = YES;
            [titleLabel_ addGestureRecognizer:tap];
            PP_RELEASE(tap);
        }
        else
        {
            titleLabel_.frame = CGRectMake(left, 0, width-200, height);
        }
    }
    
    if(isPlayMode_==NO) //增加取消预览按钮
    {
        if(!cancelPreviewButton_)
        {
            cancelPreviewButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
            cancelPreviewButton_.frame = CGRectMake(10, top, 40, 40);
            [cancelPreviewButton_ setImage:[UIImage imageNamed:@"HCPlayer.bundle/get_back.png"] forState:UIControlStateNormal];
            [cancelPreviewButton_ addTarget:self action:@selector(cancelPreview:) forControlEvents:UIControlEventTouchUpInside];
            cancelPreviewButton_.hidden = YES;
            [self addSubview:cancelPreviewButton_];
        }
        else
        {
            cancelPreviewButton_.frame = CGRectMake(10, top, 40, 40);
        }
    }
    
    //显示中间的进度时间
    if(isPlayMode_==NO)
    {
        NSString * commentsStr = [CommonUtil getTimeStringOfTimeInterval:currentSeconds_];
        UIFont * font = FONT_STANDARD(13);
        CGSize textSize = [commentsStr sizeWithAttributes:@{NSFontAttributeName:font}];
        textSize.width += 14;
        
        left = (self.frame.size.width - textSize.width)/2.0f;
        if(!redDot_)
        {
            redDot_ = [[UIView alloc] initWithFrame:CGRectMake(left, (self.frame.size.height - 6)/2.0f, 6, 6)];
            redDot_.backgroundColor = COLOR_BO;
            redDot_.layer.cornerRadius = 3;
            redDot_.hidden = YES;
            [self addSubview:redDot_];
        }
        else
        {
            redDot_.frame =CGRectMake(left, (self.frame.size.height - 6)/2.0f, 6, 6);
        }
        left += 10;
        if(!progressTime_)
        {
            progressTime_ = [[UILabel alloc] initWithFrame:CGRectMake(left, (self.frame.size.height- textSize.height)/2.0f, textSize.width, textSize.height)];
            progressTime_.font = font;
            progressTime_.shadowColor = COLOR_SHADOW;
            progressTime_.shadowOffset = SHADOW_SIZE;
            progressTime_.textAlignment = NSTextAlignmentLeft;
            progressTime_.textColor = [UIColor whiteColor];
            progressTime_.backgroundColor = [UIColor clearColor];
            progressTime_.text = @"00:00";
            progressTime_.hidden = YES;
            [self addSubview:progressTime_];
        }
        else
        {
            progressTime_.frame = CGRectMake(left, (self.frame.size.height- textSize.height)/2.0f, textSize.width, textSize.height);
        }
    }
    
    left = width - 10 ;
    
    if(self.ShowMore){
        left -= 40;
        if(!moreButton_)
        {
            moreButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
            moreButton_.frame = CGRectMake(left, top, 40, 40);
            [moreButton_ setImage:[UIImage imageNamed:@"HCPlayer.bundle/play_more_white"] forState:UIControlStateNormal];
            [moreButton_ setImage:[UIImage imageNamed:@"HCPlayer.bundle/play_more_yellow"] forState:UIControlStateSelected];
            //        [moreButton_ addTarget:self action:@selector(changeRightMenuState:) forControlEvents:UIControlEventTouchUpInside];
            //        [moreButton_ setImage:[UIImage imageNamed:@"HCPlayer.bundle/more.png"] forState:UIControlStateNormal];
            [moreButton_ addTarget:self action:@selector(moreClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:moreButton_];
        }
        else
        {
            moreButton_.frame = CGRectMake(left, top, 40, 40);
        }
    }
    if(self.ShowShare){
        left -= 40;
        if(!shareButton_)
        {
            shareButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
            shareButton_.frame = CGRectMake(left, top, 40, 40);
            [shareButton_ setImage:[UIImage imageNamed:@"HCPlayer.bundle/playpannel_share_icon.png"] forState:UIControlStateNormal];
            [shareButton_ setImage:[UIImage imageNamed:@"HCPlayer.bundle/playpannel_share_sel_icon.png"] forState:UIControlStateSelected];
            [shareButton_ addTarget:self action:@selector(shareMtv:) forControlEvents:UIControlEventTouchUpInside];
            
            UILabel * lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 40 - 16, 40, 15)];
            lable.font = FONT_STANDARD(10);
            lable.text = @"分享";
            lable.textColor = COLOR_CA;
            lable.backgroundColor = [UIColor clearColor];
            lable.textAlignment = NSTextAlignmentCenter;
            [shareButton_ addSubview:lable];
            shareTitle_ = lable;
            [self addSubview:shareButton_];
        }
        else
        {
            shareButton_.frame = CGRectMake(left, top, 40, 40);
        }
    }
    
    if(self.ShowPreview)
    {
        left -= 40;
        if(!previewButton_)
        {
            previewButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
            previewButton_.frame = CGRectMake(left, top, 40, 40);
            [previewButton_ setImage:[UIImage imageNamed:@"HCPlayer.bundle/preview.png"] forState:UIControlStateNormal];
            //            [previewButton_ setImage:[UIImage imageNamed:@"HCPlayer.bundle/preview.png"] forState:UIControlStateSelected];
            [previewButton_ addTarget:self action:@selector(previewClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:previewButton_];
        }
        else
        {
            previewButton_.frame = CGRectMake(left, top, 40, 40);
        }
    }
    if(self.ShowResing)
    {
        left -= 40;
        if(!resingButton_)
        {
            resingButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
            resingButton_.frame = CGRectMake(left, top, 40, 40);
            [resingButton_ setImage:[UIImage imageNamed:@"HCPlayer.bundle/repeat.png"] forState:UIControlStateNormal];
            //            [resingButton_ setImage:[UIImage imageNamed:@"HCPlayer.bundle/repeat.png"] forState:UIControlStateSelected];
            [resingButton_ addTarget:self action:@selector(resingClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:resingButton_];
        }
        else
        {
            resingButton_.frame = CGRectMake(left, top, 40, 40);
        }
    }
    //comments
    if(self.ShowCommentsButton){
        NSString * commentsStr = @"0000";
        CGSize textSize = [commentsStr sizeWithAttributes:attributes];
        textSize.width = MAX(40,textSize.width + 5);
        left -= 10 + textSize.width ;
        if(!commentTitle_){
            commentTitle_ = [[UILabel alloc]initWithFrame:CGRectMake(left, (height - textSize.height)/2.0f, textSize.width, textSize.height)];
            commentTitle_.text = @"";
            commentTitle_.font = textFont;
            commentTitle_.textAlignment = NSTextAlignmentLeft;
            commentTitle_.textColor = [UIColor whiteColor];
            commentTitle_.backgroundColor = [UIColor clearColor];
            commentTitle_.shadowColor = COLOR_SHADOW;
            commentTitle_.shadowOffset = SHADOW_SIZE;
            [self addSubview:commentTitle_];
        }
        else
        {
            commentTitle_.frame = CGRectMake(left, (height - textSize.height)/2.0f, textSize.width, textSize.height);
        }
        left -= 40;
        if(!commentButton_){
            
            commentButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
            commentButton_.frame = CGRectMake(left, top, 40, 40);
            [commentButton_ setImage:[UIImage imageNamed:@"HCPlayer.bundle/play_comment.png"] forState:UIControlStateNormal];
            [commentButton_ addTarget:self action:@selector(showCommentsOrNot:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:commentButton_];
        }
        else
        {
            commentButton_.frame = CGRectMake(left, top, 40, 40);
        }
    }
    
    //support
    if(self.ShowLikes){
        NSString * commentsStr = @"0000";
        CGSize textSize = [commentsStr sizeWithAttributes:attributes];
        textSize.width = MAX(40,textSize.width + 5);
        left -= 10 + textSize.width ;
        if(!likeTitle_){
            likeTitle_ = [[UILabel alloc]initWithFrame:CGRectMake(left, (height - textSize.height)/2.0f, textSize.width, textSize.height)];
            likeTitle_.text = @"";
            likeTitle_.font = textFont;
            likeTitle_.textAlignment = NSTextAlignmentLeft;
            likeTitle_.textColor = [UIColor whiteColor];
            likeTitle_.backgroundColor = [UIColor clearColor];
            likeTitle_.shadowColor = COLOR_SHADOW;
            likeTitle_.shadowOffset = SHADOW_SIZE;
            [self addSubview:likeTitle_];
        }
        else
        {
            likeTitle_.frame = CGRectMake(left, (height - textSize.height)/2.0f, textSize.width, textSize.height);
        }
        left -= 40;
        if(!likeButton_){
            
            likeButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
            likeButton_.frame = CGRectMake(left, top, 40, 40);
            [likeButton_ setImage:[UIImage imageNamed:@"HCPlayer.bundle/videolove_icon.png"] forState:UIControlStateNormal];
            [likeButton_ setImage:[UIImage imageNamed:@"HCPlayer.bundle/videolove2_icon.png"] forState:UIControlStateSelected];
            [likeButton_ addTarget:self action:@selector(likeMtv:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:likeButton_];
        }
        else
        {
            likeButton_.frame = CGRectMake(left, top, 40, 40);
        }
    }
    
    
    if(!leaderSwitch_)
    {
        //leaderSwitch_ = [[SevenSwitch alloc]initWithFrame:CGRectMake(left, height/2.0 - 10, 90, 20)];
        leaderSwitch_.onText = @"导唱";
        leaderSwitch_.onTextColor = COLOR_CF;
        leaderSwitch_.offText = @"伴奏";
        leaderSwitch_.offTextColor = COLOR_CC;
        leaderSwitch_.borderColor = COLOR_CL;//[UIColor] [UIImage imageNamed:@"HCPlayer.bundle/switch_icon.png"];
        leaderSwitch_.isRounded = YES;
        leaderSwitch_.hidden = NO;
        //        leaderSwitch_.onColor = COLOR_CL;
        //        leaderSwitch_.activeColor = COLOR_CL;
        //        leaderSwitch_.inactiveColor = COLOR_CL;
        leaderSwitch_.knobColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HCPlayer.bundle/switch_icon.png"]];
        NSLog(@"leader switch frame:%@",NSStringFromCGRect(leaderSwitch_.frame));
        [leaderSwitch_ setOn:YES];
        [leaderSwitch_ setup];
        
        [self addSubview:leaderSwitch_];
        
        [leaderSwitch_ addTarget:self action:@selector(openOrCloseLeader:) forControlEvents:UIControlEventValueChanged];
    }
    else
    {
        leaderSwitch_.frame = CGRectMake(left, height/2.0 - 10, 90, 20);
    }
    if(self.ShowGuideAudio){
        left -= 90 +10;
        leaderSwitch_.hidden = NO;
    }
    else
    {
        leaderSwitch_.hidden = YES;
    }
    
    if(![UserManager sharedUserManager].isForReivew && self.ShowCache)
    {
        
        if(self.ShowBigCache)
        {
            left -= 85;
            if(!cacheContainer_)
            {
                cacheContainer_ = [[UIView alloc] initWithFrame:CGRectMake(left, 10, 85, 40)];
                [self addSubview:cacheContainer_];
                
                cacheIcon_ = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
                cacheIcon_.image = [UIImage imageNamed:@"HCPlayer.bundle/play_cache.png"];
                [cacheContainer_ addSubview:cacheIcon_];
                
                cacheProgressLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(35, 10, 45, 10)];
                cacheProgressLabel_.text = @"缓存";
                cacheProgressLabel_.font = [UIFont systemFontOfSize:12];
                cacheProgressLabel_.textColor = [UIColor whiteColor];
                cacheProgressLabel_.shadowOffset = SHADOW_SIZE;
                cacheProgressLabel_.shadowColor = COLOR_SHADOW;
                [cacheContainer_ addSubview:cacheProgressLabel_];
                
                cacheGesture_ = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cacheMtv:)];
                [cacheContainer_ addGestureRecognizer:cacheGesture_];
            }
            else
            {
                cacheContainer_.frame = CGRectMake(left, 10, 85, 40);
            }
            cacheButton_.hidden = YES;
            cacheContainer_.hidden = NO;
        }
        else
        {
            left -= 40;
            if(!cacheButton_)
            {
                cacheButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
                cacheButton_.frame = CGRectMake(left, top, 40, 40);
                [cacheButton_ setImage:[UIImage imageNamed:@"HCPlayer.bundle/playpannel_cache_icon.png"] forState:UIControlStateNormal];
                [cacheButton_ setImage:[UIImage imageNamed:@"HCPlayer.bundle/playpannel_cache_sel_icon.png"] forState:UIControlStateSelected];
                [cacheButton_ addTarget:self action:@selector(cacheMtv:) forControlEvents:UIControlEventTouchUpInside];
                
                UILabel * lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 40 - 16, 40, 15)];
                lable.font = FONT_STANDARD(10);
                lable.text = @"--";
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
            }
            else
            {
                cacheButton_.frame = CGRectMake(left, top, 40, 40);
            }
            cacheButton_.hidden = NO;
            cacheContainer_.hidden = YES;
        }
        
    }
    else
    {
        cacheButton_.hidden = YES;
        cacheContainer_.hidden = YES;
    }
    if(!userHeadPortrait_)
    {
//        left -= 40
//        userHeadPortrait_ = [[UIWebImageViewN alloc] initWithFrame:CGRectMake(144, 0, 30, 30)];
//        userHeadPortrait_.isFill_ = YES;
//        userHeadPortrait_.keepScale_ = YES;
//        userHeadPortrait_.layer.cornerRadius = userHeadPortrait_.bounds.size.height/2;
//        userHeadPortrait_.layer.masksToBounds = YES;
//        userHeadPortrait_.layer.borderWidth = 1;
//        userHeadPortrait_.layer.borderColor = [[UIColor grayColor] CGColor];
//        [rightButtonsContainer_ addSubview:userHeadPortrait_];
        
        
//        if(mtv.UserID==userInfo_.UserID)
//        {
//            if (userInfo_.HeadPortrait && userInfo_.HeadPortrait.length > 0)
//            {
//                [userHeadPortrait_ setImageWithURLString:userInfo_.HeadPortrait width:30 height:30 mode:1 placeholderImageName:HEADPORTRAIT];
//            }
//            else
//            {
//                userHeadPortrait_.image = [UIImage imageNamed:HEADPORTRAIT];
//            }
//        }
//        else
//        {
//            if (mtv.HeadPortrait && mtv.HeadPortrait.length > 0)
//            {
//                [userHeadPortrait_ setImageWithURLString:mtv.HeadPortrait width:30 height:30 mode:1 placeholderImageName:HEADPORTRAIT];
//            }
//            else
//            {
//                userHeadPortrait_.image = [UIImage imageNamed:HEADPORTRAIT];
//            }
//        }
    }
    [self buildMenuViews];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveCacheStatus:) name:NT_CACHEPROGRESS object:nil];
    isBuild_ = YES;
}
- (void)changeFrame:(CGRect)frame
{
    self.frame = frame;
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    CGFloat left = 0;
    CGFloat top = (height - 40)/2.0f;
    
    UIFont * textFont = FONT_STANDARD(15);
    NSDictionary *attributes = @{NSFontAttributeName: textFont};
    
    {
        bgView_.frame = CGRectMake(0, 0, width, height);
        gradientLayer_.frame = bgView_.bounds;
    }
    //return
    if(self.ShowReturn){
        returnButton_.frame = CGRectMake(left, top, 40, 40);
        left += 40;
    }
    else
    {
        if(returnButton_.hidden==NO) returnButton_.hidden = YES;
    }
    //title
    if(self.ShowTitle){
        CGSize textSize = [titleLabel_.text sizeWithAttributes:attributes];
        textSize.width = MAX(40,textSize.width + 5);
        titleLabel_.frame = CGRectMake(left, 0, textSize.width, height);
    }
    else
    {
        if(titleLabel_.hidden==NO) titleLabel_.hidden = YES;
    }
    
    //显示中间的进度时间
    if(isPlayMode_==NO)
    {
        NSString * commentsStr = [CommonUtil getTimeStringOfTimeInterval:currentSeconds_];
        UIFont * font = FONT_STANDARD(13);
        CGSize textSize = [commentsStr sizeWithAttributes:@{NSFontAttributeName:font}];
        textSize.width += 14;
        left = (self.frame.size.width - textSize.width)/2.0f;
        if(redDot_)
        {
            redDot_.frame = CGRectMake(left, (self.frame.size.height - 6)/2.0f, 6, 6);
        }
        left += 10;
        if(progressTime_)
        {
            progressTime_.frame = CGRectMake(left, (self.frame.size.height- textSize.height)/2.0f, textSize.width, textSize.height);
        }
    }
    left = width - 10 ;
    
    if(self.ShowMore){
        left -= 40;
        moreButton_.frame = CGRectMake(left, top, 40, 40);
    }
    else
    {
        if(moreButton_.hidden==NO) moreButton_.hidden = YES;
    }
    if(self.ShowShare){
        left -= 40;
        shareButton_.frame = CGRectMake(left, top, 46, 46);
    }
    else
    {
        if(shareButton_.hidden==NO) shareButton_.hidden = YES;
    }
    //comments
    if(self.ShowCommentsButton){
        NSString * commentsStr = commentTitle_.text;
        CGSize textSize = [commentsStr sizeWithAttributes:attributes];
        textSize.width = MAX(40,textSize.width + 5);
        left -= 10 + textSize.width ;
        {
            commentTitle_.frame = CGRectMake(left, (height - textSize.height)/2.0f, textSize.width, textSize.height);
        }
        {
            left -= 40;
            commentButton_.frame = CGRectMake(left, top, 40, 40);
        }
    }
    
    //support
    if(self.ShowLikes){
        NSString * commentsStr = likeTitle_.text;
        CGSize textSize = [commentsStr sizeWithAttributes:attributes];
        textSize.width = MAX(40,textSize.width + 5);
        left -= 10 + textSize.width ;
        {
            likeTitle_.frame = CGRectMake(left, (height - textSize.height)/2.0f, textSize.width, textSize.height);
        }
        {
            left -= 40;
            likeButton_.frame = CGRectMake(left, top, 40, 40);
        }
    }
    else
    {
        if(likeTitle_.hidden==NO) likeTitle_.hidden = YES;
        if(likeButton_.hidden==NO) likeButton_.hidden = YES;
    }
    
    if(self.ShowGuideAudio){
        left -= 90 +10;
        leaderSwitch_.frame = CGRectMake(left, height/2.0 - 10, 90, 20);
    }
    {
        if(leaderSwitch_.hidden==NO) leaderSwitch_.hidden = YES;
    }
    if(![UserManager sharedUserManager].isForReivew && self.ShowCache)
    {
        
        if(self.ShowBigCache)
        {
            left -= 85;
            cacheContainer_.frame = CGRectMake(left, 10, 85, 40);
            cacheButton_.hidden = YES;
            cacheContainer_.hidden = NO;
        }
        else
        {
            left -= 40;
            cacheButton_.frame = CGRectMake(left, top, 40, 40);
            cacheButton_.hidden = NO;
            cacheContainer_.hidden = YES;
        }
    }
    else
    {
        cacheButton_.hidden = YES;
        cacheContainer_.hidden = YES;
    }
}

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
#pragma mark - events
- (void)hideGuidAudio
{
    self.ShowGuideAudio = NO;
    leaderButton_.hidden = YES;
    leaderSwitch_.hidden = YES;
}
- (void)showGuidAudio
{
    self.ShowGuideAudio = YES;
    leaderButton_.hidden = NO;
    leaderSwitch_.hidden = NO;
}
- (void)hideCommentButton
{
    self.ShowCommentsButton = NO;
    commentButton_.hidden = YES;
}
- (void)showCommentButton
{
    self.ShowCommentsButton = YES;
    commentButton_.hidden = NO;
}
- (void)hideCacheButton
{
    self.ShowCache = NO;
    cacheButton_.hidden = YES;
    cacheTitle_.hidden = YES;
}
- (void)showCacheButton
{
    self.ShowCache = YES;
    cacheButton_.hidden = NO;
    cacheTitle_.hidden = NO;
}

- (void)setMTVItem:(MTV *)item sample:(MTV *)sampleItem
{
    MTVItem = item;
    SampleItem = sampleItem;
    
    if([NSThread isMainThread])
    {
        //        if(!isBuild_||(self.ShowMore && !rightMenuContainer_))
        //        {
        //            [self buildViews:self.frame];
        //        }
        [self buildViews:self.frame];
        if(self.ShowTitle)
        {
            titleLabel_.text = MTVItem.Title;
        }
        if(MTVItem.UserID == [UserManager sharedUserManager].userID)
        {
            BOOL isUpload = [[MTVUploader sharedMTVUploader]isMtvUploaded:MTVItem];
            if(!isUpload)
            {
                self.ShowLikes = NO;
            }
        }
        if(self.ShowLikes)
        {
            likeTitle_.text = [NSString stringWithFormat:@"%ld",(long)MTVItem.LikeCount];
            if(MTVItem.IsLike)
            {
                likeButton_.selected = YES;
            }
            else
            {
                likeButton_.selected = NO;
            }
        }
        else
        {
            
        }
        
        
        if(self.ShowShare)
        {
            shareTitle_.text = [NSString stringWithFormat:@"%ld",(long)MTVItem.ShareCount];
            shareButton_.titleLabel.text = [NSString stringWithFormat:@"%ld",(long)MTVItem.ShareCount];
        }
        if(self.ShowCache && ![UserManager sharedUserManager].isForReivew)
        {
            if(!localVDCItem_)
                localVDCItem_ = [[VDCManager shareObject]getVDCItemByMtv:MTVItem urlString:nil];
            
            [self showCacheStatus];
            
            //            if(localVDCItem_.AudioUrl && localVDCItem_.AudioUrl.length>2)
            //            {
            //                leaderSwitch_.hidden = NO;
            //                [leaderSwitch_ setOn:YES];
            //            }
            //            else
            //            {
            //                [leaderSwitch_ setOn:NO];
            //                leaderSwitch_.hidden = YES;
            //            }
        }
        [self refreshGuidAudio];
        //        if(MTVItem.SampleID<=0)
        //        {
        //            self.ShowGuideAudio = NO;
        //            leaderSwitch_.hidden = YES;
        //        }
        if(self.ShowCommentsButton)
        {
            commentTitle_.text = [NSString stringWithFormat:@"%ld",(long)MTVItem.CommentCount];
        }
        VDCItem * localVdcItem_  = [[VDCManager shareObject]getVDCItemByMtv:MTVItem urlString:nil];
        if(localVdcItem_.isDownloading)
        {
            if(![[UserManager sharedUserManager]isForReivew])
            {
         
            __weak WTPlayerTopPannel * weakSelf = self;
            localVdcItem_.progressCall = ^(VDCItem * item){
                CGFloat percent = item.contentLength>0?(CGFloat)item.downloadBytes/item.contentLength:0;
                [weakSelf setCacheStatus:YES textColor:cacheProgressLabel_.textColor text:cacheProgressLabel_.text percent:percent];
            };
            localVdcItem_.downloadedCall = ^(VDCItem * vdcItem,BOOL completed,VDCTempFileInfo * tempFile)
            {
                if (completed) {
                    [weakSelf setCacheCompleted:YES];
                }
            };
            }
        }
        else if(localVdcItem_.downloadBytes > localVdcItem_.contentLength && localVdcItem_.contentLength>0)
        {
            [self setCacheCompleted:YES];
        }
        
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self setMTVItem:MTVItem sample:sampleItem];
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
    
    if([UserManager sharedUserManager].isForReivew) return;
    if([NSThread isMainThread])
    {
        if(!localVDCItem_)
        {
            cacheButton_.selected = NO;
            cacheTitle_.text = @"缓存";
            cacheTitle_.textColor = [UIColor whiteColor];
            cacheTitle_.alpha = 1;
            cacheButton_.alpha = 1;
            return;
        }
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
            //            NSString * title = [NSString stringWithFormat:@"%.1f%%",percent];
            //            cacheTitle_.text = title;
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
- (void)setCacheStatus:(BOOL)caching textColor:(UIColor*)color text:(NSString *)text percent:(CGFloat)percent
{
    if(self.ShowBigCache)
    {
        if(percent>0)
        {
            if (percent <= 0.01) {
                cacheProgressLabel_.text = @"缓存";
            }
            else{
                cacheProgressLabel_.text = [NSString stringWithFormat:@"%d%%", (int)percent];
            }
        }
        cacheProgressLabel_.alpha = 1;
        cacheIcon_.alpha = 1;
        cacheGesture_.enabled = YES;
    }
    if(caching)
    {
        if(self.ShowBigCache)
        {
            cacheIcon_.image = [UIImage imageNamed:@"HCPlayer.bundle/play_cacheing"];
            cacheProgressLabel_.textColor = color?color:COLOR_BA;
            if(text)
            {
                cacheProgressLabel_.text = text;
            }
        }
        else
        {
            [cacheButton_ setSelected:YES];
        }
    }
    else
    {
        if(self.ShowBigCache)
        {
            cacheIcon_.image = [UIImage imageNamed:@"HCPlayer.bundle/play_cache"];
            cacheProgressLabel_.textColor = color?color:[UIColor whiteColor];
            if(text)
            {
                cacheProgressLabel_.text = text;
            }
        }
        else
        {
            [cacheButton_ setSelected:NO];
        }
    }
}
- (void)setCacheCompleted:(BOOL)animates
{
    if(!self.ShowBigCache)
    {
        [cacheButton_ setSelected:NO];
        cacheTitle_.text = @"100%";
    }
    else
    {
        cacheProgressLabel_.text = @"已缓存";
        cacheProgressLabel_.textColor = [UIColor whiteColor];
        cacheGesture_.enabled = NO;
        cacheIcon_.image = [UIImage imageNamed:@"HCPlayer.bundle/play_cache_gray"];
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
}
- (void)setDotSplash:(BOOL)canSplash
{
    isDotSplash_ = canSplash;
    if(!isDotSplash_)
    {
        redDot_.hidden = YES;
    }
    else
    {
        redDot_.hidden = NO;
    }
}
- (void)setPlaySeconds:(CGFloat)seconds
{
    if([NSThread isMainThread])
    {
        if(seconds<0) seconds = 0;
        NSString * secondsString = [CommonUtil getTimeStringOfTimeInterval:seconds];
        if(progressTime_)
        {
            UIFont * font = FONT_STANDARD(13);
            CGSize textSize = [secondsString sizeWithAttributes:@{NSFontAttributeName:font}];
            if(textSize.width>progressTime_.frame.size.width)
            {
                CGRect frame = progressTime_.frame;
                frame.size.width = textSize.width + 5;
                progressTime_.frame = frame;
            }
            progressTime_.text = secondsString;
            if(isDotSplash_)
            {
                if((int)seconds%2==0)
                {
                    [UIView animateWithDuration:0.5 animations:^(void)
                     {
                         redDot_.alpha = 0;
                     }];
                }
                else
                {
                    [UIView animateWithDuration:0.5 animations:^(void)
                     {
                         redDot_.alpha = 1;
                     }];
                }
            }
            if(progressTime_.hidden)
            {
                progressTime_.hidden = NO;
            }
            if(redDot_.hidden)
            {
                redDot_.hidden = NO;
            }
        }
        currentSeconds_ = seconds;
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self setPlaySeconds:seconds];
                       });
    }
}
- (void)setCommentCount:(int)commentCount
{
    if(self.ShowCommentsButton)
    {
        commentTitle_.text = [NSString stringWithFormat:@"%d",(int)commentCount];
    }
}
#pragma mark - events
- (void)reportMtv:(id)sender
{
    if(delegate && [delegate respondsToSelector:@selector(videoPannel:reportMtv:)])
    {
        [delegate videoPannel:nil reportMtv:YES];
    }
}
- (void)cancelPreview:(id)sender
{
    previewButton_.hidden = NO;
    cancelPreviewButton_.hidden = YES;
    returnButton_.hidden = NO;
    titleLabel_.hidden = NO;
    moreButton_.hidden = NO;
    
    if(delegate && [delegate respondsToSelector:@selector(videoPannel:cancelPreview:)])
    {
        [delegate videoPannel:nil cancelPreview:YES];
    }
}
- (void)previewClick:(id)sender
{
    cancelPreviewButton_.hidden = NO;
    returnButton_.hidden = YES;
    titleLabel_.hidden = YES;
    moreButton_.hidden = YES;
    resingButton_.hidden = NO;
    previewButton_.hidden = YES;
    if(delegate && [delegate respondsToSelector:@selector(videoPannel:previewMtv:)])
    {
        [delegate videoPannel:nil previewMtv:YES];
    }
}
- (void)resingClick:(id)sender
{
    if(delegate && [delegate respondsToSelector:@selector(videoPannel:resingMtv:)])
    {
        [delegate videoPannel:nil resingMtv:YES];
    }
}
- (void)openOrCloseLeader:(id)sender
{
    if(delegate && [delegate respondsToSelector:@selector(videoPannel:guideChanged:)])
    {
        [delegate videoPannel:nil guideChanged:leaderSwitch_.isOn];
    }
}
- (void)moreClicked:(id)sender
{
    if(delegate && [delegate respondsToSelector:@selector(videoPannel:showMore:)])
    {
        [delegate videoPannel:nil showMore:YES];
    }
    else
    {
        [self changeRightMenuState:nil];
    }
}
- (void)likeMtv:(id)sender
{
    
    if(delegate && [delegate respondsToSelector:@selector(videoPannel:likeIt:)])
    {
        [delegate videoPannel:nil likeIt:likeButton_.selected];
    }
    else if(MTVItem && (MTVItem.MTVID>0||MTVItem.SampleID>0))
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
        cacheButton_.alpha = 1.0f;
        cacheTitle_.alpha = 1.0f;
        cacheTitle_.textColor = [UIColor whiteColor];
    }
    else
    {
        cacheButton_.selected = YES;
        
        if(delegate && [delegate respondsToSelector:@selector(videoPannel:doCache:)])
        {
            [delegate videoPannel:nil doCache:cacheButton_.selected];
        }
        else
        {
            VDCManager * vdcManager = [VDCManager shareObject];
            
            
            NSString *  url = [MTVItem getDownloadUrlOpeated:ReachableViaWiFi userID:[UserManager sharedUserManager].currentUser.UserID];
            
            NSString * audioUrl = MTVItem.AudioRemoteUrl;
            
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
- (void)shareMtv:(id)sender
{
    if(delegate && [delegate respondsToSelector:@selector(videoPannel:doShare:)])
    {
        [delegate videoPannel:nil doShare:shareButton_.selected];
    }
}
- (void)showCommentsOrNot:(id)sender
{
    if(delegate && [delegate respondsToSelector:@selector(videoPannel:editComments:)])
    {
        [delegate videoPannel:nil editComments:YES];
    }
}
- (void)returnClicked:(id)sender
{
    if(delegate && [delegate respondsToSelector:@selector(videoPannel:didReturn:)])
    {
        [delegate videoPannel:nil didReturn:YES];
    }
}
- (BOOL)getIsCommentsShow
{
    if(barrageButton_)
        _isCommentsShow = barrageButton_.selected;
    return _isCommentsShow;
}
- (void)setIsCommentsShow:(BOOL)pisCommentsShow
{
    _isCommentsShow = pisCommentsShow;
    if(barrageButton_)
    {
        [barrageButton_ setSelected:_isCommentsShow];
    }
}
#pragma mark -
#pragma mark - show menu
- (void)changeRightMenuState:(id)sender
{
    if (!moreButton_.selected) {
        [self showRightMenu:nil];
    }
    else{
        [self hideRightMenu:nil animates:YES];
    }
}

- (void)showRightMenu:(id)sender
{
    [moreButton_ setSelected:YES];
    //    UIViewController * rootVC = [self traverseResponderChainForUIViewController];
    //    CGRect rootFrame = rootVC.view.bounds;
    if(!self.superview) return;
    CGRect rootFrame = self.frame.size.width > self.superview.frame.size.width?self.frame:self.superview.frame;
    if(!rightMenuContainer_)
    {
        [self buildMenuViews];
    }
    else if(!rightMenuContainer_.superview)
    {
        if(self.superview)
        {
            [self.superview addSubview:rightMenuContainer_];
        }
    }
    [rightMenuContainer_.superview bringSubviewToFront:rightMenuContainer_];
    
    NSLog(@"self frame:%@",NSStringFromCGRect(self.frame));
    
    //因为横屏，但没有真正横屏，则用Height
    if (self.MTVItem.UserID == [UserManager sharedUserManager].currentUser.UserID ) {
        [UIView animateWithDuration:0.2 animations:^{
            CGFloat top = 4;
            rightMenuContainer_.frame = CGRectMake(rootFrame.size.width - 90, 50, 90, 147);
            rightMenuArrow_.frame = CGRectMake(0, 0, 90, 4);
            if(editButton_ && self.ShowEdit)
            {
                editButton_.frame = CGRectMake(0, top, 90, 41);
                editButton_.hidden = NO;
                top += 41;
            }
            if(self.ShowCommentSwitch)
            {
                barrageButton_.frame = CGRectMake(0, top, 90, 41);
                barrageButton_.hidden = NO;
                top += 41;
            }
            if(!self.ShowShare && !self.ShowPreview) //用户在唱的时候，不能够显示分享
            {
                shareButton2_.frame = CGRectMake(0, top, 90, 41);
                shareButton2_.hidden = NO;
                top += 41;
            }
            NSLog(@"rightmenu:%@",NSStringFromCGRect(rightMenuContainer_.frame));
            //            reportButton_.frame = CGRectMake(0, top, 90, 41);
        }];
    }
    else{
        [UIView animateWithDuration:0.2 animations:^{
            rightMenuContainer_.frame = CGRectMake(rootFrame.size.width - 90, 45, 90, 86);
            rightMenuArrow_.frame = CGRectMake(0, 0, 90, 4);
            CGFloat top = 4;
            if(editButton_)
            {
                editButton_.hidden = YES;
            }
            if(self.ShowCommentSwitch)
            {
                barrageButton_.frame = CGRectMake(0, top, 90, 41);
                barrageButton_.hidden =NO;
                top += 41;
            }
            if(!self.ShowShare)
            {
                shareButton2_.frame = CGRectMake(0, top, 90, 41);
                shareButton2_.hidden = NO;
                top += 41;
            }
            //            reportButton_.frame = CGRectMake(0, top, 90, 41);
            
            NSLog(@"right %@",NSStringFromCGRect(rightMenuContainer_.frame));
        }];
    }
    [barrageButton_ setSelected:_isCommentsShow];
}

- (void)hideRightMenu:(id)sender animates:(BOOL)animates
{
    if (moreButton_.selected) {
        [moreButton_ setSelected:NO];
        //        UIViewController * rootVC = [self traverseResponderChainForUIViewController];
        //        CGRect rootFrame = rootVC.view.bounds;
        if(!self.superview) return;
        CGRect rootFrame = self.frame.size.width > self.superview.frame.size.width?self.frame:self.superview.frame;
        if(animates)
        {
            [UIView animateWithDuration:0.2 animations:^{
                //因为横屏，但没有真正横屏，则用Height
                rightMenuContainer_.frame = CGRectMake(rootFrame.size.width - 25, 45, 0, 0);
                rightMenuArrow_.frame = CGRectMake(0, 0, 0, 0);
                if(editButton_)
                    editButton_.frame = CGRectMake(0, 0, 0, 0);
                barrageButton_.frame = CGRectMake(0, 0, 0, 0);
                shareButton2_.frame = CGRectMake(0, 0, 0, 0);
                //                                reportButton_.frame = CGRectMake(0, 0, 0, 0);
            }];
        }
        else
        {
            rightMenuContainer_.frame = CGRectMake(rootFrame.size.width - 25, 45, 0, 0);
            rightMenuArrow_.frame = CGRectMake(0, 0, 0, 0);
            if(editButton_)
                editButton_.frame = CGRectMake(0, 0, 0, 0);
            barrageButton_.frame = CGRectMake(0, 0, 0, 0);
            shareButton2_.frame = CGRectMake(0, 0, 0, 0);
            //                                            reportButton_.frame = CGRectMake(0, 0, 0, 0);
        }
    }
}
- (void)buildMenuViews
{
    //    UIViewController * rootVC = [self traverseResponderChainForUIViewController];
    if(!self.superview) return;
//    CGRect rootFrame = self.superview.frame;
    CGRect rootFrame = self.frame.size.width > self.superview.frame.size.width?self.frame:self.superview.frame;
    //因为横屏，但没有真正横屏，则用Height
    {
        rightMenuContainer_ = [[UIView alloc] initWithFrame:CGRectMake(rootFrame.size.width - 25, 50, 0, 0)];
        rightMenuContainer_.clipsToBounds = YES;
//        rightMenuContainer_.backgroundColor = [UIColor redColor];
//        if(self.superview)
//        {
//            if(self.superview.superview)
//            {
//                [self.superview.superview addSubview:rightMenuContainer_];
//            }
//            else
//            {
                [self.superview addSubview:rightMenuContainer_];
//            }
//        }
        rightMenuArrow_ = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 4)];
        rightMenuArrow_.image = [UIImage imageNamed:@"HCPlayer.bundle/triangle"];
        [rightMenuContainer_ addSubview:rightMenuArrow_];
        
        
        editButton_ = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 90, 40)];
        [editButton_ setImage:[UIImage imageNamed:@"HCPlayer.bundle/bianji"] forState:UIControlStateNormal];
        [editButton_ addTarget:self action:@selector(clickEditButton:) forControlEvents:UIControlEventTouchUpInside];
        [rightMenuContainer_ addSubview:editButton_];
        editButton_.hidden = YES;
        
        barrageButton_ = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 90,40)];
        [barrageButton_ setImage:[UIImage imageNamed:@"HCPlayer.bundle/tanmu2"] forState:UIControlStateNormal];
        [barrageButton_ setImage:[UIImage imageNamed:@"HCPlayer.bundle/tanmu"] forState:UIControlStateSelected];
        [barrageButton_ addTarget:self action:@selector(showOrHideBarrage:) forControlEvents:UIControlEventTouchUpInside];
        barrageButton_.selected = YES;
        [rightMenuContainer_ addSubview:barrageButton_];
        barrageButton_.hidden = YES;
        
        shareButton2_ = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 90, 40)];
        [shareButton2_ setImage:[UIImage imageNamed:@"HCPlayer.bundle/fenxiang"] forState:UIControlStateNormal];
        [shareButton2_ addTarget:self action:@selector(shareMtv:) forControlEvents:UIControlEventTouchUpInside];
        [rightMenuContainer_ addSubview:shareButton2_];
        shareButton2_.hidden = YES;
        //        rightMenuContainer_.backgroundColor = [UIColor yellowColor];
        //        rightMenuContainer_.userInteractionEnabled = YES;
        //        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTap:)];
        //        [rightMenuContainer_ addGestureRecognizer:tap];
        
        //        reportButton_ = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        //        [reportButton_ setImage:[UIImage imageNamed:@"HCPlayer.bundle/report_hover_full"] forState:UIControlStateNormal];
        //        [reportButton_ addTarget:self action:@selector(reportMtv:) forControlEvents:UIControlEventTouchUpInside];
        //        [rightMenuContainer_ addSubview:reportButton_];
        
    }
    if(_isCommentsShow)
    {
        [barrageButton_ setSelected:YES];
    }
    if(self.superview)
    {
        [self.superview addSubview:rightMenuContainer_];
    }
}
//- (void)didTap:(UIGestureRecognizer *)tap
//{
//    NSLog(@"tapped");
//}
- (void)showOrHideBarrage:(id)sender
{
    [self hideRightMenu:nil animates:YES];
    [barrageButton_ setSelected:!barrageButton_.selected];
    _isCommentsShow = barrageButton_.selected;
    if(delegate && [delegate respondsToSelector:@selector(videoPannel:showComments:)])
    {
        [delegate videoPannel:nil showComments:barrageButton_.isSelected];
    }
    
}
- (void)clickEditButton:(id)sender
{
    [self hideRightMenu:nil animates:YES];
    if(delegate && [delegate respondsToSelector:@selector(videoPannel:editMtv:)])
    {
        [delegate videoPannel:nil editMtv:YES];
    }
}
#pragma mark - showbuttons when play/pause
- (void)showButtonsWhenPause
{
    if([NSThread isMainThread])
    {
        //避免滑动中途卡顿  需要多线程处理
        //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //        if([[MTVUploader sharedMTVUploader]isMtvUploaded:MTVItem])
        //        {
        //            //            dispatch_async(dispatch_get_main_queue(), ^{
        //            //                likeButtonContainer_.alpha = 1;
        //            //                addBarageContainer_.alpha = 1;
        //            //            });
        //        }
        //        else
        //        {
        //            //            dispatch_async(dispatch_get_main_queue(), ^{
        //            //                likeButtonContainer_.alpha = 0.5;
        //            //                addBarageContainer_.alpha = 0.5;
        //            //            });
        //        }
        //    });
        if(MTVItem.MTVID > 0)
        {
            self.ShowResing = NO;
            self.ShowPreview = NO;
            self.ShowCache = YES;
            self.ShowMore = YES;
            //        resingButton_.hidden = YES;
            //        previewButton_.hidden = YES;
            //        cancelPreviewButton_.hidden = YES;
            //        if(self.ShowBigCache)
            //            cacheContainer_.hidden = NO;
            //        else
            //            cacheButton_.hidden = NO;
            //        moreButton_.hidden = NO;
        }
        else
        {
            if(cancelPreviewButton_.hidden==NO)
            {
                [self cancelPreview:nil];
            }
            else
            {
                self.ShowResing = YES;
                self.ShowPreview = YES;
                self.ShowCache = YES;
                self.ShowMore = NO;
                //        resingButton_.hidden = YES;
                //        previewButton_.hidden = NO;
                //        cancelPreviewButton_.hidden = YES;
                //        if(self.ShowBigCache)
                //            cacheContainer_.hidden = YES;
                //        else
                //            cacheButton_.hidden = YES;
                //        moreButton_.hidden = YES;
            }
        }
        [self buildViews:self.frame];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self showButtonsWhenPause];
                       });
    }
}
- (void)showButtonsWhenPlay
{
    if([NSThread isMainThread])
    {
        self.ShowResing = NO;
        self.ShowPreview = NO;
        self.ShowCache = NO;
        self.ShowMore = NO;
        
        [self buildViews:self.frame];
        
        //    resingButton_.hidden = YES;
        //    cancelPreviewButton_.hidden = YES;
        //    if(self.ShowBigCache)
        //    {
        //        cacheContainer_.hidden = YES;
        //    }
        //    else
        //    {
        //        cacheButton_.hidden = YES;
        //    }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self showButtonsWhenPlay];
                       });
    }
}
#pragma mark -
#pragma mark -dealloc
- (void)hideWithAnimates:(BOOL)animates
{
    if(!animates)
    {
        self.hidden = YES;
        [self hideRightMenu:nil animates:NO];
    }
    else
    {
        [UIView animateWithDuration:0.25 animations:^(void)
         {
             self.alpha = 0;
             [self hideRightMenu:nil animates:NO];
         }completion:^(BOOL finished)
         {
             self.hidden = YES;
             self.alpha = 1;
         }];
    }
}
- (BOOL)isRightMenuShow
{
    if (moreButton_.selected)
        return YES;
    else
        return NO;
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
