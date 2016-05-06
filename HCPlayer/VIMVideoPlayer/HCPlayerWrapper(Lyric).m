//
//  WTVideoPlayerView(Lyric).m
//  maiba
//
//  Created by HUANGXUTAO on 16/1/6.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import "HCPlayerWrapper(Lyric).h"
#import <hccoren/UIView+extension.h>
#import "CommentViewManager.h"
#import "UICommentListView.h"
#import "UICommentsPopView.h"

#import "LyricView.h"

@implementation HCPlayerWrapper(Lyric)
//- (CGFloat) showLyricForPlayItem:(MTV *)item seconds:(CGFloat)seconds
//{
//    if(!lyricView_)
//    {
//        self init
//    }
//    [self initLyricInThread:item.Lyric];
//    float lastLrcTime = -1;
//    if(mplayer_ && [mplayer_ isCurrentMTV:item])
//    {
//        if(item.SampleID>0 && item.MTVID==0 && !hasPan_)
//        {
//            lastLrcTime = [self getPlayBeginSeconds:seconds];
//
//            if(lastLrcTime>0)
//            {
//                needCountDown_ = YES;
//            }
//        }
//    }
//    else if(item.MTVID>0)
//    {
//        [self resetCommentsView];
//    }
//    else //无mplayer时
//    {
//        if(seconds>0 && item.SampleID>0 && item.MTVID==0)
//        {
//            lastLrcTime = seconds;
//        }
//    }
//    if (hasPan_ && needAutoPlay_ && !isSeekedToBlank_) {
//        needCountDown_ = YES;
//    }
//    return lastLrcTime;
//}
- (void)showLyric:(NSString *)lyric singleLine:(BOOL)singleLine container:(UIView *)container
{
    if([NSThread isMainThread])
    {
        CGFloat height = 90;
        if (lyricView_) {
            [lyricView_ setLyric:lyric singleRowShow:singleLine];
            [lyricView_ didPlayingWithSecond:0];
            if(container)
            {
                [self resetLyricFrame:container.frame];
            }
            else
            {
                [self resetLyricFrame:self.frame];
            }
        }
        else
        {
            CGRect containerFrame = self.frame;
            if(container)
            {
                containerFrame = container.frame;
            }
            CGRect frame = CGRectMake((containerFrame.size.width - 400)/2.0f, containerFrame.size.height - 12 - height, 400, height);
            if(frame.origin.x <10)
            {
                frame.size.width -= (10 - frame.origin.x )*2;
                frame.origin.x = 10;
            }
            lyricView_= [[LyricView alloc] initWithFrame:frame lyric:lyric singleRowShow:singleLine];
            if(container)
            {
                [container addSubview:lyricView_];
            }
            else
            {
                [self addSubview:lyricView_];
            }
            lyricView_.backgroundColor = [UIColor clearColor];
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self showLyric:lyric singleLine:singleLine container:container];
                       });
    }
}
- (void)resetLyricFrame:(CGRect)containerFrame
{
    
    if([NSThread isMainThread])
    {
        CGRect frame = CGRectMake((containerFrame.size.width - 400)/2.0f, containerFrame.size.height - 12 - self.frame.size.height, 400, self.frame.size.height);
        if(frame.origin.x <10)
        {
            frame.size.width -= (10 - frame.origin.x )*2;
            frame.origin.x = 10;
        }
        lyricView_.frame = frame;
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self resetLyricFrame:containerFrame];
                       });
    }
}
- (void)showLyric
{
    if([NSThread isMainThread])
    {
        if(lyricView_)
        {
            lyricView_.hidden = NO;
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self showLyric];
                       });
    }
    
}
- (void)hideLyric
{
    if([NSThread isMainThread])
    {
        if(lyricView_)
        {
            lyricView_.hidden = YES;
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self hideLyric];
                       });
    }
    
}
- (void)removeLyric
{
    if([NSThread isMainThread])
    {
        [lyricView_ removeFromSuperview];
        lyricView_= nil;
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self removeLyric];
                       });
    }
}

#pragma mark - comments
- (void)initComments:(UIView *)container textContainer:(UIView *)textContainer inputTag:(int)inputTag objectType:(HCObjectType) objectType objectID:(long)objectID
{
    NSLog(@"comment view container frame = %@",NSStringFromCGRect(container.bounds));
    if(!commentManager_)
    {
        commentManager_ = [CommentViewManager new];
    }
    [commentManager_ setObject:objectType objectID:objectID];
//    if(!self.commentTextInput)
//    {
//        CGRect textFrame = self.frame;
//        if(textContainer)
//        {
//            textFrame = textContainer.frame;
//        }
//        textFrame.origin.y = textFrame.size.height *2;
//        textFrame.origin.x = (textFrame.size.width - 202)/2.0f;
//        textFrame.size.width = 202;
//        textFrame.size.height = 34;
//        
//        self.commentTextInput = [[UITextField alloc] initWithFrame:textFrame];
//        self.commentTextInput.tag = inputTag;
//        self.commentTextInput.borderStyle = UITextBorderStyleRoundedRect;
//        self.commentTextInput.returnKeyType = UIReturnKeySend;
//        self.commentTextInput.enabled = YES;
//        self.commentTextInput.delegate = [self traverseResponderChainForUIViewController];
//        if(textContainer)
//           [textContainer addSubview:self.commentTextInput];
//        else
//            [self addSubview:self.commentTextInput];
//    }
    if(!commentListView_)
    {
        CGRect frame = self.frame;
        if(container)
        {
            frame = container.bounds;
        }
        frame.origin.x = 0;
        frame.origin.y = 50;
        frame.size.height -= 100;
        commentManager_.showType = CommentShowTypePop;
        commentListView_ = [commentManager_ createCommentsView:frame];
        commentListView_.hidden = YES;
        //commentListView_.backgroundColor = [UIColor yellowColor];
        if(container)
            [container addSubview:commentListView_];
        else
            [self addSubview:commentListView_];
    }
    [self refreshComment];
}
- (void)resetCommentsFrame:(CGRect)commentFamre container:(UIView *)container textContainer:(UIView *)textContainer
{
//    if(self.commentTextInput)
//    {
//        CGRect textFrame = self.frame;
//        if(textContainer)
//        {
//            textFrame = textContainer.frame;
//        }
//        textFrame.origin.y = textFrame.size.height *2;
//        textFrame.origin.x = (textFrame.size.width - 202)/2.0f;
//        textFrame.size.width = 202;
//        textFrame.size.height = 34;
//        
//        self.commentTextInput.frame = textFrame;
//    }
    if(commentListView_)
    {
//        CGRect frame = self.frame;
//        if(container)
//        {
//            frame = container.bounds;
//        }
//        frame.origin.x = 0;
//        frame.origin.y = 50;
//        frame.size.height -= 100;
        CGRect frame = commentFamre;
        frame.origin.x = 0;
        frame.origin.y = 50;
        frame.size.height -= 100;
        commentListView_.frame = frame;
        
        if(container) {
            if (commentListView_.superview == container)
                [container bringSubviewToFront:commentListView_];
            else
                [container addSubview:commentListView_];
        }
        else {
            if (commentListView_.superview == self)
                [self bringSubviewToFront:commentListView_];
            else
                [self addSubview:commentListView_];
        }
        [self refreshComment];
    }
}
- (void)showComments
{
    if(!commentListView_ || commentListView_.hidden==NO) return;
    [self switchCommentsShowHide:YES];
}
- (void)hideComments
{
    if(!commentListView_ || commentListView_.hidden) return;
    [self switchCommentsShowHide:NO];
}
- (void)resetComments
{
    if(commentManager_)
    {
        [commentManager_ stopCommentTimer];
        [commentManager_ reset];
    }
    if(commentListView_)
    {
        [commentListView_ reset];
    }
//    if(self.commentTextInput)
//    {
//        self.commentTextInput.text = @"";
//    }
}
- (void)removeComments
{
    if(commentManager_)
    {
        [commentManager_ stopCommentTimer];
        [commentManager_ readyToRelease];
        commentManager_ = nil;
    }
    if(commentListView_)
    {
        [commentListView_ removeFromSuperview];
        commentListView_ = nil;
    }
//    if(self.commentTextInput)
//    {
//        [self.commentTextInput removeFromSuperview];
//        self.commentTextInput = nil;
//    }
}

#pragma mark - comments details
- (void)refreshCommentsView:(CGFloat)durance
{
    if(!commentManager_) return;
    // 刷新评论到指定位置
//    [commentManager_ reset];
//    //        [commentManager_ setObject:HCObjectTypeMTV objectID:currentMtv_.MTVID];
//    [commentManager_ setCommentBeginWhen:durance];
//    [commentManager_ getComments:0 completed:^(int code,long commentsCount,NSString * qaguid,NSString * msg)
//     {
//         if(code==0 && commentListView_)
//         {
//             [self switchCommentsShowHide:!commentListView_.hidden];
//         }
//     }];
    
    [commentManager_ refreshCommentsView:durance reloadNow:YES completed:^(int code) {
        if (code == 0 && commentListView_) {
            [self switchCommentsShowHide:!commentListView_.hidden];
        }
    }];
}

//- (void)refreshComment
//{
//    CGFloat durance = 0;
//    CMTime cTime = self.durationWhen;
//    if(CMTIME_IS_VALID(cTime))
//    {
//        durance = CMTimeGetSeconds(cTime);
//    }
//    durance = (int)durance; // 保留时间为0时的情况
//    [self refreshCommentsView:durance];
//    NSLog(@"refreshCommentsView: %.1f",durance);
//}
- (void)refreshComment
{
    CGFloat durance = CMTimeGetSeconds(mplayer_.durationWhen);
    
    if (!(durance>0)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self refreshComment];
        });
    }
    else
    {
        durance = (int)durance; // 保留时间为0时的情况
        [self refreshCommentsView:durance];
        NSLog(@"refreshCommentsView: %.1f",durance);
    }
}

-(void)switchCommentsShowHide:(BOOL)Show
{
    if ([NSThread isMainThread]) {
        if(!Show) // 隐藏
        {
            commentListView_.hidden = YES;
            [commentManager_ stopCommentTimer];
        }
        else // 显示
        {
            commentListView_.hidden = NO;
            [commentManager_ startCommentTimer];
        }
        NSLog(@"listview frame:%@ hidden:%d",NSStringFromCGRect(commentListView_.frame),commentListView_.hidden);
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self switchCommentsShowHide:Show];
        });
        
    }
}

#pragma mark - comment check
- (BOOL)canShowComment
{
//    canShowComments_ = maxPannel_.isCommentsShow || commentSwitch_.isOn;
//    return canShowComments_;
    return NO;
}
- (BOOL)isMaxWindowPlay
{
//    return (currentPlayerHeight_ >= playerHeightMax_);
    return NO;
}
- (void)showOrHideComment:(id)sender
{
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
}
@end
